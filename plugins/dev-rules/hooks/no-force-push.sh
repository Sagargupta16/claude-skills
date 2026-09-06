#!/usr/bin/env bash
# no-force-push.sh - Blocks force pushes to protected branches
# Hook event: PreToolUse, matcher Bash (registered in hooks/hooks.json)
#
# Prevents accidental force pushes to main/master branches.
# Checks the command for --force or -f while a protected branch is checked out.
# Exits 2 to block (exit 1 would be treated as a non-blocking error).

set -euo pipefail

# Claude Code passes the tool call as JSON on stdin, not as arguments.
if ! command -v jq &>/dev/null; then
  echo "no-force-push: jq is not on PATH, so this hook cannot read its input. Install jq to enable the guard."
  exit 0
fi

INPUT=$(cat || true)
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT" 2>/dev/null || true)

# Only inspect git pushes -- this hook sees every Bash call.
if ! grep -qE '\bgit\b.*\bpush\b' <<<"$CMD"; then
  exit 0
fi

# Check if this is a force push.
# Match --force (also covers --force-with-lease / --force-if-includes) and the
# short flag -f as a standalone token, so flags like --follow-tags don't match.
if grep -qE '(--force|(^|[[:space:]])-f([[:space:]]|$))' <<<"$CMD"; then
  # Check if pushing to a protected branch
  BRANCH=$(git branch --show-current 2>/dev/null || echo "")
  if grep -qE '^(main|master|production|release)$' <<<"$BRANCH"; then
    # stderr is what Claude Code surfaces as the reason a call was blocked.
    {
      echo "BLOCKED: Force push to '$BRANCH' is not allowed."
      echo "Force pushing to protected branches can destroy team history and break CI."
      echo ""
      echo "If you need to update this branch, use:"
      echo "  git pull --rebase origin $BRANCH"
    } >&2
    exit 2
  fi
fi

exit 0
