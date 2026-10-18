#!/usr/bin/env bash
# Runs every hook this marketplace ships against a table of fixtures and checks
# what the hook decided. Run from anywhere: bash tests/hooks/run.sh
#
# Each case builds a real payload, pipes it into the hook on stdin the way
# Claude Code does, and runs it inside a scratch git repo so the hook sees real
# branches, staged blobs, commits and an upstream remote. A case expects one of
# three outcomes:
#
#   block  exit 2 with a reason on stderr (the call is stopped)
#   warn   exit 0 with a single {"systemMessage": ...} object on stdout
#   allow  exit 0 with nothing on stdout (no decision)
#
# Fake secrets are assembled at runtime from split strings, so this file never
# holds a literal token that a secret scanner (including secret-guard itself)
# would flag.
#
# Needs bash, git and jq. Exits 1 if any case fails.
#
#   bash tests/hooks/run.sh              test the hooks in this checkout
#   bash tests/hooks/run.sh --ref v5.2.0 test the hooks as they were at a git ref,
#                                        to see which cases an older release fails

set -uo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

for tool in git jq; do
  if ! command -v "$tool" &>/dev/null; then
    echo "ERROR: $tool is required to run the hook tests" >&2
    exit 1
  fi
done

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

REF=""
if [[ "${1:-}" = "--ref" ]]; then
  REF="${2:?--ref needs a git ref, for example v5.2.0}"
  mkdir -p "$WORK/ref"
  if ! git -C "$ROOT" archive "$REF" plugins | tar -x -C "$WORK/ref"; then
    echo "ERROR: could not read plugins/ at $REF" >&2
    exit 1
  fi
  ROOT="$WORK/ref"
  echo "Testing the hooks at $REF"
  echo ""
fi

HOOKS_DEV_RULES="$ROOT/plugins/dev-rules/hooks"
HOOK_SECRET="$HOOKS_DEV_RULES/secret-guard.sh"
HOOK_PUSH="$HOOKS_DEV_RULES/no-force-push.sh"
HOOK_BRANCH="$HOOKS_DEV_RULES/branch-guard.sh"
HOOK_LINT="$ROOT/plugins/git-advanced/hooks/commit-lint.sh"
HOOK_SYNC="$ROOT/plugins/oss-contrib/hooks/upstream-sync-check.sh"
HOOK_FORMAT="$ROOT/plugins/dev-workflow/hooks/auto-format.sh"

PASS=0
FAIL=0
declare -A HOOK_CASES=()

# Repeats a character N times, for building fake tokens of the right length.
rep() {
  local char="$1" count="$2"
  printf "%${count}s" "" | tr ' ' "$char"
  return 0
}

# Fake credentials, split so no line of this file matches a real pattern.
FAKE_AWS="AK""IA$(rep 7 16)"
FAKE_OPENAI="sk""-$(rep a 32)"
FAKE_OPENAI_PROJ="sk""-proj-$(rep b 24)_$(rep c 8)"
FAKE_ANTHROPIC="sk""-ant-api03-$(rep d 32)"
FAKE_GH_PAT="gh""p_$(rep e 36)"
FAKE_GH_OAUTH="gh""o_$(rep f 36)"
FAKE_GH_FINE="github""_pat_$(rep g 22)_$(rep h 20)"
FAKE_GITLAB="gl""pat-$(rep i 20)"
FAKE_SLACK="xo""xb-$(rep 1 12)-$(rep j 16)"
FAKE_PASSWORD="pass""word = 'hunter2'"
FAKE_PASSWORD_DQ="pass""word = \"x\""
FAKE_SECRET="sec""ret = 'abc'"
FAKE_KEY="-----BEGIN RSA PRIVATE"" KEY-----"
FAKE_MONGO="mongo""db+srv://app:s3cret@cluster0.example.net/db"
FAKE_PG="postgres""ql://app:s3cret@db.example.net:5432/app"

# Strings several cases share.
COMMIT_FEAT_X='git commit -m "feat: x"'
FORCE_MAIN="Force push to main"
LINT_FORMAT="does not follow conventional commit format"

payload_bash() {
  local event="$1" command="$2"
  jq -nc --arg e "$event" --arg c "$command" \
    '{hook_event_name: $e, tool_name: "Bash", tool_input: {command: $c}}'
  return 0
}

payload_file() {
  local event="$1" tool="$2" file="$3"
  jq -nc --arg e "$event" --arg t "$tool" --arg f "$file" \
    '{hook_event_name: $e, tool_name: $t, tool_input: {file_path: $f}}'
  return 0
}

# Fresh scratch repo on `main` with one commit, isolated from the user's git
# hooks and signing setup.
new_repo() {
  local dir="$WORK/$1"
  rm -rf "$dir"
  mkdir -p "$dir"
  git -C "$dir" init -q -b main
  git -C "$dir" config user.name "hook tests"
  git -C "$dir" config user.email "hooks@example.invalid"
  git -C "$dir" config commit.gpgsign false
  git -C "$dir" config core.hooksPath /dev/null
  git -C "$dir" config core.autocrlf false
  printf 'tracked\n' >"$dir/tracked.txt"
  git -C "$dir" add tracked.txt
  git -C "$dir" commit -q -m "chore: initial commit"
  REPO="$dir"
  return 0
}

# Puts the scratch repo back to its first commit with nothing staged.
reset_repo() {
  git -C "$REPO" checkout -q main 2>/dev/null
  git -C "$REPO" reset -q --hard
  git -C "$REPO" clean -qfd
  return 0
}

stage() {
  local file="$1" content="$2"
  printf '%s\n' "$content" >"$REPO/$file"
  git -C "$REPO" add -- "$file"
  return 0
}

# check HOOK EXPECT NAME PAYLOAD [stdout-substring]
# Runs HOOK in $REPO with PAYLOAD on stdin and compares the outcome.
check() {
  local hook="$1" expect="$2" name="$3" input="$4" needle="${5:-}"
  local out rc got detail=""
  out=$(cd "$REPO" || exit 99; bash "$hook" <<<"$input" 2>"$WORK/stderr")
  rc=$?
  out=${out//$'\r'/}

  if [[ "$rc" -eq 2 ]]; then
    got=block
    [[ -s "$WORK/stderr" ]] || detail="exit 2 with an empty stderr"
  elif [[ "$rc" -eq 0 && -z "$out" ]]; then
    got=allow
  elif [[ "$rc" -eq 0 ]] && jq -e 'type == "object" and (.systemMessage | type == "string")' <<<"$out" &>/dev/null; then
    got=warn
  else
    got="rc=$rc"
    detail="stdout: ${out:0:120}"
  fi

  if [[ "$got" = "$expect" && -z "$detail" && -n "$needle" ]]; then
    local haystack="$out"
    [[ "$got" = block ]] && haystack=$(tr -d '\r' <"$WORK/stderr")
    [[ "$haystack" == *"$needle"* ]] || detail="output is missing: $needle"
  fi

  local label
  label=$(basename "$hook" .sh)
  HOOK_CASES[$label]=$((${HOOK_CASES[$label]:-0} + 1))
  if [[ "$got" = "$expect" && -z "$detail" ]]; then
    PASS=$((PASS + 1))
    printf 'PASS  %-20s %-5s  %s\n' "$label" "$expect" "$name"
  else
    FAIL=$((FAIL + 1))
    printf 'FAIL  %-20s %-5s  %s (got %s%s)\n' "$label" "$expect" "$name" "$got" "${detail:+, $detail}"
  fi
}

# --- secret-guard -----------------------------------------------------------

new_repo secrets
COMMIT=$(payload_bash PreToolUse 'git commit -m "feat: add client"')

secret_case() {
  local file="$1" content="$2" name="$3"
  reset_repo
  stage "$file" "$content"
  check "$HOOK_SECRET" block "$name" "$COMMIT" "$file (staged)"
  return 0
}

secret_case aws.py "KEY = \"$FAKE_AWS\"" "AWS access key"
secret_case openai.py "KEY = \"$FAKE_OPENAI\"" "OpenAI classic key"
secret_case openai_proj.py "KEY = \"$FAKE_OPENAI_PROJ\"" "OpenAI project key"
secret_case anthropic.py "KEY = \"$FAKE_ANTHROPIC\"" "Anthropic key"
secret_case gh_pat.sh "TOKEN=$FAKE_GH_PAT" "GitHub classic token"
secret_case gh_oauth.sh "TOKEN=$FAKE_GH_OAUTH" "GitHub OAuth token"
secret_case gh_fine.sh "TOKEN=$FAKE_GH_FINE" "GitHub fine-grained token"
secret_case gitlab.sh "TOKEN=$FAKE_GITLAB" "GitLab token"
secret_case slack.sh "TOKEN=$FAKE_SLACK" "Slack token"
secret_case settings.py "$FAKE_PASSWORD" "password in single quotes"
secret_case settings2.py "$FAKE_PASSWORD_DQ" "password in double quotes, value x"
secret_case config.py "$FAKE_SECRET" "secret in single quotes"
secret_case id_rsa "$FAKE_KEY" "private key block"
secret_case mongo.env "MONGO_URI=$FAKE_MONGO" "mongodb+srv URI with credentials"
secret_case pg.env "DATABASE_URL=$FAKE_PG" "postgresql URI with credentials"
secret_case "my notes.txt" "$FAKE_ANTHROPIC" "path with a space"

reset_repo
stage leak.py "KEY = \"$FAKE_ANTHROPIC\""
printf 'clean\n' >"$REPO/leak.py"
check "$HOOK_SECRET" block "staged blob scanned, not the cleaned working copy" "$COMMIT" "leak.py (staged)"

reset_repo
printf 'KEY = "%s"\n' "$FAKE_AWS" >>"$REPO/tracked.txt"
check "$HOOK_SECRET" block "git commit -am stages a tracked modification" \
  "$(payload_bash PreToolUse 'git commit -am "fix: tweak"')" "unstaged, staged by -a"
check "$HOOK_SECRET" block "git commit --all" \
  "$(payload_bash PreToolUse 'git commit --all -m "fix: tweak"')" "unstaged, staged by -a"
check "$HOOK_SECRET" allow "unstaged secret, plain git commit" "$COMMIT"
check "$HOOK_SECRET" allow "-a inside the message is not the flag" \
  "$(payload_bash PreToolUse 'git commit -m "-a note"')"

reset_repo
stage leak.py "KEY = \"$FAKE_ANTHROPIC\""
check "$HOOK_SECRET" block "commit after cd in a chain" \
  "$(payload_bash PreToolUse 'cd src && git commit -m "feat: x"')"
check "$HOOK_SECRET" block "commit on its own line" \
  "$(payload_bash PreToolUse $'git status\ngit commit -m "feat: x"')"
check "$HOOK_SECRET" allow "grep for the words git commit" \
  "$(payload_bash PreToolUse 'grep -rn "git commit" docs/')"
check "$HOOK_SECRET" allow "git status with a secret staged" \
  "$(payload_bash PreToolUse 'git status')"
check "$HOOK_SECRET" allow "PostToolUse event is ignored" \
  "$(payload_bash PostToolUse "$COMMIT_FEAT_X")"
check "$HOOK_SECRET" allow "non-Bash tool is ignored" \
  "$(jq -nc '{hook_event_name: "PreToolUse", tool_name: "Write", tool_input: {command: "git commit -m x"}}')"

clean_case() {
  local file="$1" content="$2" name="$3"
  reset_repo
  stage "$file" "$content"
  check "$HOOK_SECRET" allow "$name" "$COMMIT"
  return 0
}

clean_case notes.md "Rotate the key every 90 days." "plain prose"
clean_case styles.css ".task-list-item-checkbox { margin: 0 }" "CSS class containing sk-"
clean_case db.py "URL = 'postgres://localhost/app'" "postgres URI without credentials"
clean_case settings.py "$(printf 'pass''word = os.environ["DB_PASSWORD"]')" "password read from the environment"

# --- no-force-push ----------------------------------------------------------

new_repo pushes

push_case() {
  local expect="$1" command="$2" needle="${3:-}"
  check "$HOOK_PUSH" "$expect" "$command" "$(payload_bash PreToolUse "$command")" "$needle"
  return 0
}

push_case block "git push --force origin main" "$FORCE_MAIN"
push_case block "git push -f origin main"
push_case block "git push --force-with-lease origin main"
push_case block "git push origin +main"
push_case block "git push --force origin feat/x:main"
push_case block "git push --force origin refs/heads/main"
push_case block "git push --force origin HEAD" "$FORCE_MAIN"
push_case block "git push --force origin @"
push_case block "git push --force" "$FORCE_MAIN"
push_case block "git push -fu origin main"
push_case block "git push -o ci.skip --force origin main"
push_case block "git push --force --all" "every branch on the remote"
push_case block "git push --force origin master"
push_case block "git push --force origin production"
push_case block "git push --force origin release"
push_case block "git fetch origin; git push -f origin main"
push_case allow "git push origin main"
push_case allow "git push -u origin main"
push_case allow "git push origin HEAD"
push_case allow "git push -o ci.skip origin main"
push_case allow "git push --force origin feat/x"
push_case allow "git push --force origin main-backup"
push_case allow 'echo "never git push -f origin main here"'
push_case allow "git status"

git -C "$REPO" checkout -q -b feat/x
push_case allow "git push --force"
push_case allow "git push --force origin HEAD"
push_case allow "git push -fu origin feat/x"
push_case block "git push --force origin main" "$FORCE_MAIN"
git -C "$REPO" checkout -q main

# --- branch-guard -----------------------------------------------------------

new_repo branches
check "$HOOK_BRANCH" warn "commit on main" \
  "$(payload_bash PreToolUse "$COMMIT_FEAT_X")" "committing directly to 'main'"
check "$HOOK_BRANCH" allow "grep for git commit on main" \
  "$(payload_bash PreToolUse 'grep -rn "git commit" docs/')"
check "$HOOK_BRANCH" allow "PostToolUse event is ignored" \
  "$(payload_bash PostToolUse "$COMMIT_FEAT_X")"
git -C "$REPO" checkout -q -b master
check "$HOOK_BRANCH" warn "commit on master" \
  "$(payload_bash PreToolUse "$COMMIT_FEAT_X")" "committing directly to 'master'"
git -C "$REPO" checkout -q -b feat/x
check "$HOOK_BRANCH" allow "commit on a feature branch" \
  "$(payload_bash PreToolUse "$COMMIT_FEAT_X")"

# --- commit-lint ------------------------------------------------------------

new_repo lint
AFTER_COMMIT=$(payload_bash PostToolUse 'git commit -m "msg"')

lint_case() {
  local expect="$1" message="$2" needle="${3:-}"
  git -C "$REPO" commit -q --allow-empty -m "$message"
  check "$HOOK_LINT" "$expect" "$message" "$AFTER_COMMIT" "$needle"
  return 0
}

lint_case allow "feat: add user authentication"
lint_case allow "fix(api): handle empty body"
lint_case allow "feat!: drop the v1 api"
lint_case allow "fix(api)!: change the response shape"
lint_case allow "revert: undo the cache change"
lint_case warn "bad message here" "$LINT_FORMAT"
lint_case warn "feat!drop the colon" "$LINT_FORMAT"
lint_case warn "Feat: capitalised type" "$LINT_FORMAT"
lint_case warn "feature: unknown type" "$LINT_FORMAT"
git -C "$REPO" commit -q --allow-empty -m "feat: $(rep x 70)"
check "$HOOK_LINT" warn "76-char subject line" "$AFTER_COMMIT" "(max 72)"
check "$HOOK_LINT" allow "git status is not linted" "$(payload_bash PostToolUse 'git status')"
check "$HOOK_LINT" allow "PreToolUse event is ignored" "$(payload_bash PreToolUse 'git commit -m "x"')"

# --- upstream-sync-check ----------------------------------------------------

UPSTREAM="$WORK/upstream.git"
new_repo sync
git clone -q --bare "$REPO" "$UPSTREAM"
PR_CREATE=$(payload_bash PreToolUse 'gh pr create --fill')

check "$HOOK_SYNC" allow "no upstream remote" "$PR_CREATE"
git -C "$REPO" remote add upstream "$UPSTREAM"
check "$HOOK_SYNC" allow "branch level with upstream" "$PR_CREATE"

new_repo sync-ahead
git -C "$REPO" remote add origin "$UPSTREAM"
git -C "$REPO" fetch -q origin
git -C "$REPO" reset -q --hard origin/main
git -C "$REPO" commit -q --allow-empty -m "feat: upstream one"
git -C "$REPO" commit -q --allow-empty -m "feat: upstream two"
git -C "$REPO" push -q origin main
REPO="$WORK/sync"
check "$HOOK_SYNC" warn "branch 2 commits behind upstream" "$PR_CREATE" "2 commit(s) behind upstream/main"
check "$HOOK_SYNC" allow "gh pr list is not checked" "$(payload_bash PreToolUse 'gh pr list')"
check "$HOOK_SYNC" allow "echo of gh pr create" "$(payload_bash PreToolUse 'echo gh pr create')"

# --- auto-format ------------------------------------------------------------

new_repo format
STUBS="$WORK/stubs"
mkdir -p "$STUBS"
for stub in gofmt ruff npx; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$STUBS/$stub"
  chmod +x "$STUBS/$stub"
done
printf '#!/usr/bin/env bash\nexit 1\n' >"$STUBS/rustfmt"
chmod +x "$STUBS/rustfmt"

format_case() {
  local expect="$1" name="$2" file="$3" needle="${4:-}"
  local input
  input=$(payload_file PostToolUse Edit "$file")
  PATH="$STUBS:$PATH" check "$HOOK_FORMAT" "$expect" "$name" "$input" "$needle"
  return 0
}

printf 'package main\n' >"$REPO/main.go"
format_case warn "Go file, gofmt present" "$REPO/main.go" "via gofmt"
printf 'fn main() {}\n' >"$REPO/main.rs"
format_case allow "formatter exits non-zero" "$REPO/main.rs"
printf 'x = 1\n' >"$REPO/app.py"
printf '[lint]\n' >"$REPO/ruff.toml"
format_case warn "Python file with ruff.toml" "$REPO/app.py" "via ruff"
printf '{}\n' >"$REPO/.prettierrc"
printf '{"a":1}\n' >"$REPO/data.json"
format_case warn "JSON file with .prettierrc" "$REPO/data.json" "via npx"
printf 'hello\n' >"$REPO/notes.txt"
format_case allow "unknown extension" "$REPO/notes.txt"
format_case allow "file that does not exist" "$REPO/missing.go"
check "$HOOK_FORMAT" allow "payload with no file_path" \
  "$(payload_bash PostToolUse 'ls')"

# --- summary ----------------------------------------------------------------

echo ""
for label in secret-guard no-force-push branch-guard commit-lint upstream-sync-check auto-format; do
  printf '%-20s %3d cases\n' "$label" "${HOOK_CASES[$label]:-0}"
done
echo ""
echo "$((PASS + FAIL)) cases across ${#HOOK_CASES[@]} hooks: $PASS passed, $FAIL failed"

[[ "$FAIL" -eq 0 ]] || exit 1
