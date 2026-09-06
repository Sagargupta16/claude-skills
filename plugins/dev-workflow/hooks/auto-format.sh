#!/usr/bin/env bash
# auto-format.sh - Runs project formatter after file writes
# Hook event: PostToolUse, matcher Write|Edit (registered in hooks/hooks.json)
#
# Detects the project's formatter (prettier, biome, black, ruff, gofmt,
# rustfmt, shfmt) and runs it on the changed file. Warns if formatting
# was applied but never blocks (exit 0 always).

set -euo pipefail

# Claude Code passes the tool call as JSON on stdin, not as arguments.
# Best-effort hook, so stay silent rather than nag when jq is unavailable.
command -v jq &>/dev/null || exit 0

INPUT=$(cat || true)
FILE=$(jq -r '.tool_input.file_path // empty' <<<"$INPUT" 2>/dev/null || true)

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

# Detect file extension
EXT="${FILE##*.}"

format_with() {
  local cmd="$1"
  shift
  if command -v "$cmd" &>/dev/null; then
    # stdout on exit 0 reaches only the debug log, so a plain echo would tell
    # nobody. `systemMessage` is the documented way to show the user a message.
    # The formatter's own chatter is discarded because Claude Code requires the
    # hook's stdout to hold nothing but the JSON object.
    # https://code.claude.com/docs/en/hooks#json-output
    "$cmd" "$@" >/dev/null 2>&1 &&
      jq -n --arg msg "auto-format: reformatted $FILE via $cmd" '{systemMessage: $msg}' || true
  fi
  # A missing formatter is not an error. Returning non-zero here would trip
  # `set -e` and surface a spurious hook failure on every edit.
  return 0
}

case "$EXT" in
  js|jsx|ts|tsx|css|scss|json|md|yaml|yml|html)
    # JS/TS ecosystem: biome > prettier > dprint
    if [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then
      format_with npx biome format --write "$FILE"
    elif [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ] || [ -f "prettier.config.mjs" ]; then
      format_with npx prettier --write "$FILE"
    elif [ -f "dprint.json" ]; then
      format_with dprint fmt "$FILE"
    fi
    ;;
  py)
    # Python: ruff > black > autopep8
    if [ -f "ruff.toml" ] || grep -q '\[tool.ruff\]' pyproject.toml 2>/dev/null; then
      format_with ruff format "$FILE"
    elif [ -f "pyproject.toml" ] && grep -q '\[tool.black\]' pyproject.toml 2>/dev/null; then
      format_with black --quiet "$FILE"
    elif command -v black &>/dev/null; then
      format_with black --quiet "$FILE"
    fi
    ;;
  go)
    format_with gofmt -w "$FILE"
    ;;
  rs)
    format_with rustfmt "$FILE"
    ;;
  sh|bash)
    format_with shfmt -w "$FILE"
    ;;
  tf|tfvars)
    format_with terraform fmt "$FILE"
    ;;
esac

# Always allow - formatting is a convenience, not a gate
exit 0
