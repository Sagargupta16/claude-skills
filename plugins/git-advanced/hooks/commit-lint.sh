#!/usr/bin/env bash
# commit-lint.sh - Validates conventional commit message format
# Hook event: PostToolUse, matcher Bash (registered in hooks/hooks.json)
#
# Checks that commit messages follow conventional commit format:
# type: description (e.g., feat: add user auth)
# Valid types: feat, fix, refactor, docs, test, chore, style, perf, ci, build, revert

set -euo pipefail

# Claude Code passes the tool call as JSON on stdin, not as arguments.
# Warn-only hook, so stay silent rather than nag when jq is unavailable.
command -v jq &>/dev/null || exit 0

INPUT=$(cat || true)
EVENT=$(jq -r '.hook_event_name // empty' <<<"$INPUT" 2>/dev/null || true)
TOOL=$(jq -r '.tool_name // empty' <<<"$INPUT" 2>/dev/null || true)
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT" 2>/dev/null || true)

[ "$EVENT" = "PostToolUse" ] || exit 0
[ "$TOOL" = "Bash" ] || exit 0

# Only lint after a git commit -- this hook sees every Bash call. Splitting on
# shell separators first keeps `grep -rn "git commit" docs/` from matching,
# because that statement starts with grep, not git.
LINT=0
while IFS= read -r segment; do
  segment="${segment#"${segment%%[![:space:]]*}"}"
  [[ "$segment" =~ ^git([[:space:]]|$) ]] || continue
  grep -qE '(^|[[:space:]])commit([[:space:]]|$)' <<<"$segment" && LINT=1
done < <(tr ';|&\n' '\n' <<<"$CMD")

[ "$LINT" -eq 1 ] || exit 0

# Get the most recent commit message
MSG=$(git log -1 --pretty=%B 2>/dev/null || echo "")

if [ -z "$MSG" ]; then
  exit 0
fi

# Check for conventional commit format
# First line must be: type: description or type(scope): description
VALID_TYPES="feat|fix|refactor|docs|test|chore|style|perf|ci|build|revert"

FIRST_LINE=$(head -1 <<<"$MSG")

WARNINGS=""

if ! grep -qE "^($VALID_TYPES)(\(.+\))?: .+" <<<"$FIRST_LINE"; then
  WARNINGS+="Commit message does not follow conventional commit format."
  WARNINGS+=$'\n'"  Got: $FIRST_LINE"
  WARNINGS+=$'\n'"  Expected: type: description"
  WARNINGS+=$'\n'"  Types: feat, fix, refactor, docs, test, chore, style, perf, ci, build, revert"
  WARNINGS+=$'\n'"  Example: feat: add user authentication"
fi

# Check first line length
LINE_LEN=${#FIRST_LINE}
if [ "$LINE_LEN" -gt 72 ]; then
  [ -n "$WARNINGS" ] && WARNINGS+=$'\n'
  WARNINGS+="Commit message first line is $LINE_LEN chars (max 72)."
  WARNINGS+=$'\n'"  Keep the first line concise, use the body for details."
fi

# Warning only, never blocks. stdout on exit 0 reaches only the debug log, so a
# plain echo would warn nobody. `systemMessage` is the documented way to show
# the user a message. https://code.claude.com/docs/en/hooks#json-output
if [ -n "$WARNINGS" ]; then
  jq -n --arg msg "commit-lint: $WARNINGS" '{systemMessage: $msg}'
fi

exit 0
