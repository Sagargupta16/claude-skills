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
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT" 2>/dev/null || true)

# Only lint after a git commit -- this hook sees every Bash call.
if ! grep -qE '\bgit\b.*\bcommit\b' <<<"$CMD"; then
  exit 0
fi

# Get the most recent commit message
MSG=$(git log -1 --pretty=%B 2>/dev/null || echo "")

if [ -z "$MSG" ]; then
  exit 0
fi

# Check for conventional commit format
# First line must be: type: description or type(scope): description
VALID_TYPES="feat|fix|refactor|docs|test|chore|style|perf|ci|build|revert"

FIRST_LINE=$(echo "$MSG" | head -1)

if ! echo "$FIRST_LINE" | grep -qE "^($VALID_TYPES)(\(.+\))?: .+"; then
  echo "WARNING: Commit message does not follow conventional commit format."
  echo "  Got: $FIRST_LINE"
  echo ""
  echo "  Expected: type: description"
  echo "  Types: feat, fix, refactor, docs, test, chore, style, perf, ci, build, revert"
  echo "  Example: feat: add user authentication"
  # Warning only - does not block
fi

# Check first line length
LINE_LEN=${#FIRST_LINE}
if [ "$LINE_LEN" -gt 72 ]; then
  echo "WARNING: Commit message first line is $LINE_LEN chars (max 72)."
  echo "  Keep the first line concise, use the body for details."
fi

exit 0
