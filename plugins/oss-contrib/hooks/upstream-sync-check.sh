#!/usr/bin/env bash
# upstream-sync-check.sh - Warns if fork is behind upstream before PR creation
# Hook event: PreToolUse, matcher Bash (registered in hooks/hooks.json)
#
# Checks if the current fork branch is behind the upstream default branch.
# Warns the user to rebase/merge before creating a PR. Never blocks.

set -euo pipefail

# Claude Code passes the tool call as JSON on stdin, not as arguments.
# Warn-only hook, so stay silent rather than nag when jq is unavailable.
command -v jq &>/dev/null || exit 0

INPUT=$(cat || true)
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT" 2>/dev/null || true)

# Only run before a PR is created. This hook sees every Bash call and the
# upstream fetch below is far too slow to do on all of them.
if ! grep -qE '\bgh\b.*\bpr\b.*\bcreate\b' <<<"$CMD"; then
  exit 0
fi

# Check if upstream remote exists
if ! git remote get-url upstream &>/dev/null; then
  exit 0  # Not a fork, skip
fi

# Fetch upstream (quiet, don't fail if offline)
git fetch upstream --quiet 2>/dev/null || exit 0

# Get the default upstream branch
UPSTREAM_BRANCH=$(git remote show upstream 2>/dev/null | grep "HEAD branch" | awk '{print $NF}')
if [ -z "$UPSTREAM_BRANCH" ]; then
  UPSTREAM_BRANCH="main"
fi

# Count commits behind upstream
BEHIND=$(git rev-list --count "HEAD..upstream/$UPSTREAM_BRANCH" 2>/dev/null || echo "0")

if [ "$BEHIND" -gt 0 ]; then
  echo "WARNING: Your branch is $BEHIND commit(s) behind upstream/$UPSTREAM_BRANCH."
  echo ""
  echo "Consider syncing before creating a PR:"
  echo "  git fetch upstream"
  echo "  git rebase upstream/$UPSTREAM_BRANCH"
  echo ""
  echo "This prevents merge conflicts and keeps your PR clean."
  # Warning only - does not block PR creation
fi

exit 0
