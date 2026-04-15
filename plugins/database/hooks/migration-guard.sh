#!/usr/bin/env bash
# migration-guard.sh - Warns about destructive database operations
# Hook event: PreToolCall (file write/edit on migration files)
#
# Scans migration files for destructive operations like DROP TABLE,
# TRUNCATE, DELETE without WHERE, or removing NOT NULL constraints.

set -euo pipefail

FILE="${1:-}"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

# Only check migration-like files
case "$FILE" in
  *migration*|*migrate*|*.sql|*alembic*|*schema*)
    ;;
  *)
    exit 0
    ;;
esac

WARNINGS=0

# Check for destructive operations
DESTRUCTIVE_PATTERNS=(
  "DROP TABLE"
  "DROP COLUMN"
  "TRUNCATE"
  "DELETE FROM.*[^W][^H][^E][^R][^E]"
  "ALTER.*DROP"
)

for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if grep -qiE "$pattern" "$FILE" 2>/dev/null; then
    if [ "$WARNINGS" -eq 0 ]; then
      echo "WARNING: Destructive operation detected in migration: $FILE"
      echo ""
    fi
    echo "  Found: $(grep -iE "$pattern" "$FILE" | head -1 | xargs)"
    WARNINGS=$((WARNINGS + 1))
  fi
done

if [ "$WARNINGS" -gt 0 ]; then
  echo ""
  echo "Ensure you have:"
  echo "  - A backup plan or rollback migration"
  echo "  - Confirmed this is intentional"
  echo "  - Tested on a staging environment first"
fi

exit 0
