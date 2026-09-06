#!/usr/bin/env bash
# no-force-push.sh - Blocks force pushes to protected branches
# Hook event: PreToolUse, matcher Bash (registered in hooks/hooks.json)
#
# Inspects the branch the push would rewrite, not just the checked-out branch,
# so `git push --force origin main` from a feature branch is caught too. Also
# catches the `+refspec` form, which forces without a --force flag.
# Exits 2 to block (exit 1 would be treated as a non-blocking error).

set -euo pipefail

PROTECTED='^(main|master|production|release)$'

# Claude Code passes the tool call as JSON on stdin, not as arguments.
if ! command -v jq &>/dev/null; then
  # stdout on exit 0 only reaches the debug log, so a plain echo would tell
  # nobody the guard is off. `systemMessage` is the documented way to show the
  # user a message. https://code.claude.com/docs/en/hooks#json-output
  printf '%s\n' '{"systemMessage":"no-force-push: jq is not on PATH, so this hook cannot read its input. Install jq to enable the guard."}'
  exit 0
fi

INPUT=$(cat || true)
EVENT=$(jq -r '.hook_event_name // empty' <<<"$INPUT" 2>/dev/null || true)
TOOL=$(jq -r '.tool_name // empty' <<<"$INPUT" 2>/dev/null || true)
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT" 2>/dev/null || true)

[ "$EVENT" = "PreToolUse" ] || exit 0
[ "$TOOL" = "Bash" ] || exit 0

# Pull out the statements that actually run `git push`. Splitting on shell
# separators first keeps `echo "never git push -f here"` from matching, because
# that statement starts with echo, not git.
PUSH_SEGMENTS=()
while IFS= read -r segment; do
  segment="${segment#"${segment%%[![:space:]]*}"}"
  [[ "$segment" =~ ^git([[:space:]]|$) ]] || continue
  grep -qE '(^|[[:space:]])push([[:space:]]|$)' <<<"$segment" || continue
  PUSH_SEGMENTS+=("$segment")
done < <(tr ';|&\n' '\n' <<<"$CMD")

[ ${#PUSH_SEGMENTS[@]} -gt 0 ] || exit 0

CURRENT=$(git branch --show-current 2>/dev/null || echo "")

# Reports the branch a force push would rewrite, or nothing when the push is
# not forced or not aimed at a protected branch.
protected_target() {
  local segment="$1"
  local -a tokens
  read -r -a tokens <<<"$segment"

  local seen_push=0 force=0 everything=0 skip_value=0 remote_seen=0
  local -a refspecs=()
  local token
  for token in "${tokens[@]}"; do
    if [ "$skip_value" -eq 1 ]; then
      skip_value=0
      continue
    fi
    if [ "$seen_push" -eq 0 ]; then
      [ "$token" = "push" ] && seen_push=1
      continue
    fi
    case "$token" in
      --force | --force-with-lease | --force-with-lease=* | --force-if-includes | -f)
        force=1
        ;;
      --all | --mirror)
        everything=1
        ;;
      -o | --repo | --receive-pack | --exec | --push-option)
        skip_value=1
        ;;
      -*) ;;
      *)
        if [ "$remote_seen" -eq 0 ]; then
          remote_seen=1
        else
          refspecs+=("$token")
        fi
        ;;
    esac
  done

  [ "$seen_push" -eq 1 ] || return 0

  # `git push --force --all` and `--mirror` rewrite every branch, main included.
  if [ "$force" -eq 1 ] && [ "$everything" -eq 1 ]; then
    printf 'every branch on the remote'
    return 0
  fi

  # With no refspec, git pushes the checked-out branch.
  if [ ${#refspecs[@]} -eq 0 ]; then
    if [ "$force" -eq 1 ] && grep -qE "$PROTECTED" <<<"$CURRENT"; then
      printf '%s' "$CURRENT"
    fi
    return 0
  fi

  local refspec dest
  for refspec in "${refspecs[@]}"; do
    # A leading + forces that refspec on its own, with no --force flag.
    local plus=0
    if [[ "$refspec" == +* ]]; then
      plus=1
      refspec="${refspec#+}"
    fi
    [ "$force" -eq 1 ] || [ "$plus" -eq 1 ] || continue
    # src:dst pushes to dst; a bare refspec pushes to the same name.
    dest="${refspec##*:}"
    dest="${dest#refs/heads/}"
    if grep -qE "$PROTECTED" <<<"$dest"; then
      printf '%s' "$dest"
      return 0
    fi
  done
}

for segment in "${PUSH_SEGMENTS[@]}"; do
  TARGET=$(protected_target "$segment")
  [ -n "$TARGET" ] || continue
  # stderr is what Claude Code surfaces as the reason a call was blocked.
  {
    echo "BLOCKED: Force push to $TARGET is not allowed."
    echo "Force pushing to protected branches can destroy team history and break CI."
    echo ""
    echo "If you need to update that branch, use:"
    echo "  git pull --rebase origin <branch>"
  } >&2
  exit 2
done

exit 0
