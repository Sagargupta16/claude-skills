#!/usr/bin/env bash
# debug-log-check.sh - Flags debug/print statements in production code
# Hook event: PostToolCall (file write/edit)
#
# Checks modified files for debug statements that should not be
# committed to production: console.log, print(), debugger, etc.

set -euo pipefail

FILE="${1:-}"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

# Skip test files and config files
case "$FILE" in
  *test*|*spec*|*__test__*|*.config.*|*.json|*.yaml|*.yml|*.md|*.txt)
    exit 0
    ;;
  *node_modules/*|*.git/*|*__pycache__/*|*dist/*|*build/*)
    exit 0
    ;;
esac

WARNINGS=0

# Python debug patterns
if echo "$FILE" | grep -qE '\.(py)$'; then
  if grep -nE '^\s*(print\(|breakpoint\(\)|import pdb|pdb\.set_trace)' "$FILE" 2>/dev/null; then
    echo "WARNING: Debug statement found in $FILE"
    WARNINGS=$((WARNINGS + 1))
  fi
fi

# JavaScript/TypeScript debug patterns
if echo "$FILE" | grep -qE '\.(js|ts|jsx|tsx)$'; then
  if grep -nE '^\s*(console\.(log|debug|warn|error)\(|debugger)' "$FILE" 2>/dev/null; then
    echo "WARNING: Debug statement found in $FILE"
    WARNINGS=$((WARNINGS + 1))
  fi
fi

if [ "$WARNINGS" -gt 0 ]; then
  echo "  Remove debug statements before committing to production code."
  echo "  Use structured logging (logger.info/debug) instead."
fi

exit 0
