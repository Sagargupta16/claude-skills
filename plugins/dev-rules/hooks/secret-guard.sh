#!/usr/bin/env bash
# secret-guard.sh - Blocks commits containing potential secrets
# Hook event: PreToolUse, matcher Bash (registered in hooks/hooks.json)
#
# Scans what the commit will actually contain for patterns that indicate
# hardcoded secrets: API keys, tokens, passwords, connection strings, private
# keys. That is the staged content, plus every tracked modification when the
# command passes -a / --all, because those get staged by the commit itself.
# Exits 2 to block the commit if secrets are found (exit 1 would not block).

set -euo pipefail

# Claude Code passes the tool call as JSON on stdin, not as arguments.
if ! command -v jq &>/dev/null; then
  # stdout on exit 0 only reaches the debug log, so a plain echo would tell
  # nobody the guard is off. `systemMessage` is the documented way to show the
  # user a message. https://code.claude.com/docs/en/hooks#json-output
  printf '%s\n' '{"systemMessage":"secret-guard: jq is not on PATH, so this hook cannot read its input. Install jq to enable the guard."}'
  exit 0
fi

INPUT=$(cat || true)
EVENT=$(jq -r '.hook_event_name // empty' <<<"$INPUT" 2>/dev/null || true)
TOOL=$(jq -r '.tool_name // empty' <<<"$INPUT" 2>/dev/null || true)
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT" 2>/dev/null || true)

[ "$EVENT" = "PreToolUse" ] || exit 0
[ "$TOOL" = "Bash" ] || exit 0

# Pull out the statements that actually run `git commit`. Splitting on shell
# separators first keeps `grep -rn "git commit" docs/` from matching, because
# that statement starts with grep, not git.
COMMIT_SEGMENTS=()
while IFS= read -r segment; do
  segment="${segment#"${segment%%[![:space:]]*}"}"
  [[ "$segment" =~ ^git([[:space:]]|$) ]] || continue
  grep -qE '(^|[[:space:]])commit([[:space:]]|$)' <<<"$segment" || continue
  COMMIT_SEGMENTS+=("$segment")
done < <(tr ';|&\n' '\n' <<<"$CMD")

[ ${#COMMIT_SEGMENTS[@]} -gt 0 ] || exit 0

# `git commit -a` / `-am` stages every tracked modification, so the working-tree
# copies are part of this commit and have to be scanned too. Read the option
# tokens rather than the whole string, so a commit message that happens to
# contain "-a" does not trigger a scan of files this commit will not touch.
COMMIT_ALL=0
for segment in "${COMMIT_SEGMENTS[@]}"; do
  read -r -a tokens <<<"$segment"
  seen_commit=0
  skip_value=0
  for token in "${tokens[@]}"; do
    if [ "$skip_value" -eq 1 ]; then
      skip_value=0
      continue
    fi
    if [ "$seen_commit" -eq 0 ]; then
      [ "$token" = "commit" ] && seen_commit=1
      continue
    fi
    case "$token" in
      -m | --message | -F | --file | -c | --reedit-message | -C | --reuse-message | --author | --date | -S | --gpg-sign)
        skip_value=1
        ;;
      --all)
        COMMIT_ALL=1
        ;;
      --*) ;;
      -*)
        # A short-flag bundle: -a, -am and -va all stage tracked modifications.
        [[ "$token" == *a* ]] && COMMIT_ALL=1
        ;;
    esac
  done
done

# Patterns that indicate hardcoded secrets
PATTERNS=(
  'AKIA[0-9A-Z]{16}'                    # AWS access key
  'sk-[a-zA-Z0-9]{20,}'                 # OpenAI/Stripe secret key
  'ghp_[a-zA-Z0-9]{36}'                 # GitHub personal access token
  'gho_[a-zA-Z0-9]{36}'                 # GitHub OAuth token
  'glpat-[a-zA-Z0-9\-]{20}'            # GitLab personal access token
  'xox[bpors]-[a-zA-Z0-9\-]+'          # Slack token
  'password\s*=\s*["\x27][^"\x27]+'     # password = "..."
  'secret\s*=\s*["\x27][^"\x27]+'       # secret = "..."
  'PRIVATE KEY-----'                     # Private key block
  'mongodb(\+srv)?://[^/\s]+:[^/\s]+@'  # MongoDB connection string with creds
  'postgres://[^/\s]+:[^/\s]+@'         # Postgres connection string with creds
)

FOUND=0

report() {
  local label="$1" content="$2" pattern
  for pattern in "${PATTERNS[@]}"; do
    if grep -qE "$pattern" <<<"$content"; then
      if [ "$FOUND" -eq 0 ]; then
        echo "BLOCKED: Potential secrets detected in the content this commit would include:" >&2
        echo "" >&2
        FOUND=1
      fi
      echo "  $label matches: $pattern" >&2
    fi
  done
}

# Scan the staged blobs, not the working tree: a secret that was staged and then
# edited out of the working copy still lands in the commit. Filenames arrive
# NUL-separated so paths containing spaces survive.
while IFS= read -r -d '' file; do
  blob=$(git show ":$file" 2>/dev/null || true)
  [ -n "$blob" ] || continue
  report "$file (staged)" "$blob"
done < <(git diff --cached -z --name-only --diff-filter=d 2>/dev/null)

if [ "$COMMIT_ALL" -eq 1 ]; then
  while IFS= read -r -d '' file; do
    [ -f "$file" ] || continue
    report "$file (unstaged, staged by -a)" "$(cat -- "$file" 2>/dev/null || true)"
  done < <(git diff -z --name-only --diff-filter=d 2>/dev/null)
fi

if [ "$FOUND" -eq 1 ]; then
  # stderr is what Claude Code surfaces as the reason a call was blocked.
  echo "" >&2
  echo "Remove secrets from these files before committing." >&2
  echo "Use environment variables or .env files (gitignored) instead." >&2
  exit 2
fi

exit 0
