#!/usr/bin/env bash
# Shows the dev-rules and git-advanced hooks deciding on four commands Claude
# might run, inside a throwaway git repo. Nothing here is mocked: every line of
# output is what the hook printed and the exit code it returned.
#
#   bash scripts/demo.sh          print the transcript
#   bash scripts/demo.sh --json   print it as an svg-forge `typing` spec, which
#                                 is how docs/demo/hooks-demo-*.svg is rendered
#
# Needs bash, git and jq.

set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HOOKS="$ROOT/plugins/dev-rules/hooks"
LINT="$ROOT/plugins/git-advanced/hooks/commit-lint.sh"
MODE="${1:-text}"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
REPO="$WORK/app"
mkdir -p "$REPO"
git -C "$REPO" init -q -b main
git -C "$REPO" config user.name "demo"
git -C "$REPO" config user.email "demo@example.invalid"
git -C "$REPO" config commit.gpgsign false
git -C "$REPO" config core.hooksPath /dev/null
git -C "$REPO" config core.autocrlf false
printf 'print("hello")\n' >"$REPO/app.py"
git -C "$REPO" add app.py
git -C "$REPO" commit -q -m "feat: initial app"

# A fake Anthropic key, split so this file never holds a literal token.
FAKE_KEY="sk""-ant-api03-$(printf '%32s' '' | tr ' ' 'Q')"

LINES='[]'

# run COMMAND STEP...: plays COMMAND through each STEP in order, the way
# Claude Code would. A step is EVENT=HOOK (pipe the payload into that hook for
# that event) or commit=MESSAGE (make the commit, between PreToolUse and
# PostToolUse). Stops at the first block. Output lines are the hook's own words
# plus the exit code it returned.
run() {
  local cmd="$1"
  shift
  local step event hook payload out err rc name
  local -a outs=()
  local tone=ok
  for step in "$@"; do
    event="${step%%=*}"
    hook="${step#*=}"
    if [[ "$event" = "commit" ]]; then
      git -C "$REPO" commit -q -m "$hook"
      continue
    fi
    payload=$(jq -nc --arg e "$event" --arg c "$cmd" \
      '{hook_event_name: $e, tool_name: "Bash", tool_input: {command: $c}}')
    name=$(basename "$hook" .sh)
    set +e
    out=$(cd "$REPO" || exit 99; bash "$hook" <<<"$payload" 2>"$WORK/err")
    rc=$?
    set -e
    out=${out//$'\r'/}
    err=$(tr -d '\r' <"$WORK/err")
    if [[ "$rc" -eq 2 ]]; then
      while IFS= read -r line; do
        outs+=("$line")
      done < <(grep -v '^$' <<<"$err" | head -n 2)
      outs+=("$name: exit 2, Claude Code blocks the call")
      tone=warn
      break
    elif [[ -n "$out" ]]; then
      while IFS= read -r line; do
        outs+=("$line")
      done < <(jq -r '.systemMessage' <<<"$out" | tr -d '\r' | head -n 2)
      outs+=("$name: exit 0, the warning is shown and the call goes ahead")
      tone=muted
    fi
  done
  if [[ ${#outs[@]} -eq 0 ]]; then
    outs+=("every hook: exit 0, allowed")
  fi
  LINES=$(jq -c --arg c "$cmd" --arg t "$tone" '. + [{cmd: $c, out: $ARGS.positional, tone: $t}]' \
    --args "${outs[@]}" <<<"$LINES")
}

PRE=("PreToolUse=$HOOKS/secret-guard.sh" "PreToolUse=$HOOKS/no-force-push.sh" "PreToolUse=$HOOKS/branch-guard.sh")

# 1. Rewrite main's history.
run "git push --force origin main" "${PRE[@]}"

# 2. Commit a hardcoded key on a feature branch.
git -C "$REPO" checkout -q -b feat/client
printf 'ANTHROPIC_API_KEY = "%s"\n' "$FAKE_KEY" >"$REPO/client.py"
git -C "$REPO" add client.py
run 'git commit -m "feat: add api client"' "${PRE[@]}"

# 3. Read the key from the environment instead, with a lazy commit message.
printf 'import os\nANTHROPIC_API_KEY = os.environ["ANTHROPIC_API_KEY"]\n' >"$REPO/client.py"
git -C "$REPO" add client.py
run 'git commit -m "update stuff"' "${PRE[@]}" "commit=update stuff" "PostToolUse=$LINT"

# 4. Force pushing your own feature branch is fine.
run "git push --force origin feat/client" "${PRE[@]}"

if [[ "$MODE" = "--json" ]]; then
  jq -n --argjson lines "$LINES" '{title: "claude code: dev-rules hooks", prompt: "$", lines: $lines}'
  exit 0
fi

jq -r '.[] | "$ \(.cmd)", (.out[] | "    \(.)"), ""' <<<"$LINES"
