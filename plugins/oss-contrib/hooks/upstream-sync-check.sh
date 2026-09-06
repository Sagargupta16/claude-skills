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
EVENT=$(jq -r '.hook_event_name // empty' <<<"$INPUT" 2>/dev/null || true)
TOOL=$(jq -r '.tool_name // empty' <<<"$INPUT" 2>/dev/null || true)
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT" 2>/dev/null || true)

[ "$EVENT" = "PreToolUse" ] || exit 0
[ "$TOOL" = "Bash" ] || exit 0

# Only run before a PR is created. This hook sees every Bash call and the
# upstream fetch below is far too slow to do on all of them. Splitting on shell
# separators first keeps `grep -rn "gh pr create" docs/` from matching, because
# that statement starts with grep, not gh.
CHECK=0
while IFS= read -r segment; do
  segment="${segment#"${segment%%[![:space:]]*}"}"
  [[ "$segment" =~ ^gh([[:space:]]|$) ]] || continue
  grep -qE '(^|[[:space:]])pr([[:space:]]|$)' <<<"$segment" || continue
  grep -qE '(^|[[:space:]])create([[:space:]]|$)' <<<"$segment" && CHECK=1
done < <(tr ';|&\n' '\n' <<<"$CMD")

[ "$CHECK" -eq 1 ] || exit 0

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

# Warning only, never blocks PR creation. stdout on exit 0 reaches only the
# debug log, so a plain echo would warn nobody. `systemMessage` is the
# documented way to show the user a message.
# https://code.claude.com/docs/en/hooks#json-output
if [ "$BEHIND" -gt 0 ]; then
  MSG="upstream-sync-check: your branch is $BEHIND commit(s) behind upstream/$UPSTREAM_BRANCH."
  MSG+=$'\n'"Consider syncing before creating a PR:"
  MSG+=$'\n'"  git fetch upstream"
  MSG+=$'\n'"  git rebase upstream/$UPSTREAM_BRANCH"
  jq -n --arg msg "$MSG" '{systemMessage: $msg}'
fi

exit 0
