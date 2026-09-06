#!/usr/bin/env bash
# branch-guard.sh - Warns when committing directly to main/master
# Hook event: PreToolUse, matcher Bash (registered in hooks/hooks.json)
#
# Checks the current branch and warns if committing directly to
# main or master instead of a feature branch. Never blocks.

set -euo pipefail

# Claude Code passes the tool call as JSON on stdin, not as arguments.
# Warn-only hook, so stay silent rather than nag when jq is unavailable.
command -v jq &>/dev/null || exit 0

INPUT=$(cat || true)
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT" 2>/dev/null || true)

# Only warn on git commits -- this hook sees every Bash call.
if ! grep -qE '\bgit\b.*\bcommit\b' <<<"$CMD"; then
  exit 0
fi

BRANCH=$(git branch --show-current 2>/dev/null || echo "")

if grep -qE '^(main|master)$' <<<"$BRANCH"; then
  echo "WARNING: You are committing directly to '$BRANCH'."
  echo "Consider creating a feature branch instead:"
  echo "  git checkout -b feat/your-feature"
  echo ""
  echo "Direct commits to $BRANCH skip PR review and CI checks."
  # Warning only - does not block (exit 0)
fi

exit 0
