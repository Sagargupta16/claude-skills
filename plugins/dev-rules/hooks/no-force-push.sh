#!/usr/bin/env bash
# no-force-push.sh - Blocks force pushes to protected branches
# Hook event: PreToolCall (git push)
#
# Prevents accidental force pushes to main/master branches.
# Checks command arguments for --force or -f flags targeting protected branches.

set -euo pipefail

# Read the command from stdin or arguments
CMD="$*"

# Check if this is a force push
if echo "$CMD" | grep -qE '(--force|-f|--force-with-lease)'; then
  # Check if pushing to a protected branch
  BRANCH=$(git branch --show-current 2>/dev/null || echo "")
  if echo "$BRANCH" | grep -qE '^(main|master|production|release)$'; then
    echo "BLOCKED: Force push to '$BRANCH' is not allowed."
    echo "Force pushing to protected branches can destroy team history and break CI."
    echo ""
    echo "If you need to update this branch, use:"
    echo "  git pull --rebase origin $BRANCH"
    exit 1
  fi
fi

exit 0
