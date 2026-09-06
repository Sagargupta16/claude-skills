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
EVENT=$(jq -r '.hook_event_name // empty' <<<"$INPUT" 2>/dev/null || true)
TOOL=$(jq -r '.tool_name // empty' <<<"$INPUT" 2>/dev/null || true)
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT" 2>/dev/null || true)

[ "$EVENT" = "PreToolUse" ] || exit 0
[ "$TOOL" = "Bash" ] || exit 0

# True when $CMD runs `git <subcommand>` as an actual command. Splitting on
# shell separators first keeps `grep -rn "git commit" docs/` from matching,
# because that statement starts with grep, not git.
runs_git_subcommand() {
  local sub="$1" segment
  while IFS= read -r segment; do
    segment="${segment#"${segment%%[![:space:]]*}"}"
    [[ "$segment" =~ ^git([[:space:]]|$) ]] || continue
    grep -qE "(^|[[:space:]])$sub([[:space:]]|\$)" <<<"$segment" && return 0
  done < <(tr ';|&\n' '\n' <<<"$CMD")
  return 1
}

runs_git_subcommand commit || exit 0

BRANCH=$(git branch --show-current 2>/dev/null || echo "")

if grep -qE '^(main|master)$' <<<"$BRANCH"; then
  # stdout on exit 0 only reaches the debug log, so a plain echo would warn
  # nobody. `systemMessage` is the documented way to show the user a message.
  # https://code.claude.com/docs/en/hooks#json-output
  jq -n --arg msg "branch-guard: you are committing directly to '$BRANCH'. Consider a feature branch instead: git checkout -b feat/your-feature" \
    '{systemMessage: $msg}'
fi

exit 0
