#!/usr/bin/env bash
# Checks that relative markdown links resolve to files that exist.
# Run from repo root: bash scripts/check-links.sh
#
# Only relative targets are checked. External URLs, mail links, bare `#anchor`
# fragments, and targets that resolve outside the repo (CLAUDE.md deliberately
# points at the parent workspace, which is absent in CI) are skipped.

set -uo pipefail

ROOT="$(pwd)"
ERRORS=0
FILES=0

while IFS= read -r file; do
  FILES=$((FILES + 1))
  while IFS= read -r target; do
    case "$target" in
      http://* | https://* | mailto:* | '#'* | '') continue ;;
    esac

    # Drop the anchor: docs/x.md#section only needs docs/x.md to exist.
    path="${target%%#*}"
    [[ -n "$path" ]] || continue

    candidate="$(dirname "$file")/$path"
    case "$(realpath -m "$candidate")" in
      "$ROOT" | "$ROOT"/*) ;;
      *) continue ;;
    esac

    if [[ ! -e "$candidate" ]]; then
      echo "ERROR: broken link in $file -> $target"
      ERRORS=$((ERRORS + 1))
    fi
  done < <(grep -oP '\]\(\K[^)]+' "$file" || true)
done < <(git ls-files '*.md')

echo ""
echo "================================"
echo "Link check complete: $FILES markdown file(s), $ERRORS broken relative link(s)"
[[ $ERRORS -eq 0 ]] && echo "PASSED" || echo "FAILED"
exit $ERRORS
