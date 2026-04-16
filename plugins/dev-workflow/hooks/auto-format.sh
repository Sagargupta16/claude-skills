#!/usr/bin/env bash
# auto-format.sh - Runs project formatter after file writes
# Hook event: PostToolUse (Write, Edit)
#
# Detects the project's formatter (prettier, biome, black, ruff, gofmt,
# rustfmt, shfmt) and runs it on the changed file. Warns if formatting
# was applied but never blocks (exit 0 always).

set -euo pipefail

# Get the file path from the tool result (passed via stdin or args)
FILE="${1:-}"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

# Detect file extension
EXT="${FILE##*.}"

format_with() {
  local cmd="$1"
  shift
  if command -v "$cmd" &>/dev/null; then
    "$cmd" "$@" 2>/dev/null && echo "FORMATTED: $FILE (via $cmd)" || true
    return 0
  fi
  return 1
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
