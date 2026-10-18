#!/usr/bin/env bash
# Prints the CHANGELOG.md section for one marketplace version, without its
# heading, for use as GitHub Release notes.
# Run from repo root: bash scripts/release-notes.sh 5.6.0
#
# Exits 1 when the version has no section or the section is empty, so a
# release can never go out with blank notes.

set -euo pipefail

VERSION="${1:?usage: release-notes.sh VERSION (for example 5.6.0)}"
CHANGELOG="${2:-CHANGELOG.md}"

NOTES=$(tr -d '\r' <"$CHANGELOG" | awk -v want="## [$VERSION]" '
  index($0, "## [") == 1 {
    if (found) exit
    if (index($0, want) == 1) { found = 1; next }
  }
  found { print }
')

# Trim leading and trailing blank lines.
NOTES=$(sed -e '/./,$!d' <<<"$NOTES")
NOTES=$(printf '%s\n' "$NOTES" | sed -e ':a' -e '/^\n*$/{$d;N;ba' -e '}')

if [ -z "${NOTES//[[:space:]]/}" ]; then
  echo "ERROR: $CHANGELOG has no notes under ## [$VERSION]" >&2
  exit 1
fi

printf '%s\n' "$NOTES"
