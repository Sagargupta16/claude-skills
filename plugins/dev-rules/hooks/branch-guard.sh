#!/usr/bin/env bash
# branch-guard.sh - Warns when committing directly to main/master
# Hook event: PreToolCall (git commit)
#
# Checks the current branch and warns if committing directly to
# main or master instead of a feature branch.

set -euo pipefail

BRANCH=$(git branch --show-current 2>/dev/null || echo "")

if echo "$BRANCH" | grep -qE '^(main|master)$'; then
  echo "WARNING: You are committing directly to '$BRANCH'."
  echo "Consider creating a feature branch instead:"
  echo "  git checkout -b feat/your-feature"
  echo ""
  echo "Direct commits to $BRANCH skip PR review and CI checks."
  # Warning only - does not block (exit 0)
fi

exit 0
