#!/usr/bin/env bash
# secret-scanner.sh - Scans new/modified files for hardcoded secrets
# Hook event: PostToolCall (file write/edit)
#
# Runs after file creation or modification to detect accidentally
# introduced secrets before they get committed.

set -euo pipefail

FILE="${1:-}"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

# Skip binary files, lock files, and common non-source files
case "$FILE" in
  *.lock|*.png|*.jpg|*.gif|*.ico|*.woff*|*.ttf|*.eot|*.svg|*.map)
    exit 0
    ;;
  *node_modules/*|*.git/*|*__pycache__/*|*.next/*|*dist/*|*build/*)
    exit 0
    ;;
esac

PATTERNS=(
  'AKIA[0-9A-Z]{16}'
  'sk-[a-zA-Z0-9]{20,}'
  'ghp_[a-zA-Z0-9]{36}'
  'PRIVATE KEY-----'
  'password\s*=\s*["\x27][^"\x27]{8,}'
)

for pattern in "${PATTERNS[@]}"; do
  if grep -qE "$pattern" "$FILE" 2>/dev/null; then
    echo "WARNING: Potential secret detected in $FILE"
    echo "  Pattern matched: $pattern"
    echo "  Move secrets to environment variables or a .env file (gitignored)."
    exit 0  # Warn, don't block file writes
  fi
done

exit 0
