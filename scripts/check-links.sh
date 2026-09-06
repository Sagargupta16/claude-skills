#!/usr/bin/env bash
# Checks that relative markdown links resolve to files that exist.
# Run from repo root: bash scripts/check-links.sh
#
# Only relative targets are checked. External URLs, mail links, bare `#anchor`
# fragments, and targets that resolve outside the repo (CLAUDE.md deliberately
# points at the parent workspace, which is absent in CI) are skipped, so a link
# that leaves the repo can never fail this check.
#
# Deliberately sticks to POSIX grep (no -oP) and does its own path
# normalization (no realpath -m) so it behaves the same on macOS and the BSDs.
# The version this replaced could not fail at all; a check that quietly reports
# success on an unfamiliar toolchain is the same defect wearing a new hat.

set -uo pipefail

ERRORS=0
FILES=0
SKIPPED=0

# Collapses `a/./b` and `a/b/../c` without touching the filesystem. Fails when
# the path escapes the repo root, which is how out-of-repo targets are spotted.
# Keeps to a string stack rather than an array: an empty array under `set -u`
# is an unbound-variable error on the bash 3.2 that macOS still ships.
normalize() {
  local raw="$1" segment out=""
  local IFS=/
  # shellcheck disable=SC2086 # deliberate word splitting on /
  set -- $raw
  for segment in "$@"; do
    case "$segment" in
      '' | .) ;;
      ..)
        [[ -n "$out" ]] || return 1
        if [[ "$out" == */* ]]; then out="${out%/*}"; else out=""; fi
        ;;
      *)
        if [[ -n "$out" ]]; then out="$out/$segment"; else out="$segment"; fi
        ;;
    esac
  done
  echo "$out"
}

while IFS= read -r file; do
  FILES=$((FILES + 1))

  # `](target)` for every inline link. grep exits 1 on no matches, which is
  # normal, and 2 on a real failure such as an unsupported flag. Only 0 and 1
  # are acceptable: masking the rest with `|| true` is what let the old check
  # report a clean pass while extracting nothing.
  raw=$(grep -oE '\]\([^)]+\)' "$file")
  status=$?
  if [[ $status -gt 1 ]]; then
    echo "ERROR: grep failed on $file (exit $status) -- cannot verify its links"
    ERRORS=$((ERRORS + 1))
    continue
  fi
  [[ -n "$raw" ]] || continue

  while IFS= read -r match; do
    target="${match#](}"
    target="${target%)}"
    case "$target" in
      http://* | https://* | mailto:* | '#'* | '') continue ;;
    esac

    # Drop the anchor: docs/x.md#section only needs docs/x.md to exist.
    path="${target%%#*}"
    [[ -n "$path" ]] || continue

    dir="$(dirname "$file")"
    [[ "$dir" == "." ]] && candidate="$path" || candidate="$dir/$path"

    if ! resolved=$(normalize "$candidate"); then
      SKIPPED=$((SKIPPED + 1))
      continue
    fi

    if [[ ! -e "$resolved" ]]; then
      echo "ERROR: broken link in $file -> $target"
      ERRORS=$((ERRORS + 1))
    fi
  done <<< "$raw"
done < <(git ls-files '*.md')

echo ""
echo "================================"
echo "Link check complete: $FILES markdown file(s), $ERRORS broken relative link(s), $SKIPPED target(s) outside the repo (not checked)"
[[ $ERRORS -eq 0 ]] && echo "PASSED" || echo "FAILED"
# Not `exit $ERRORS`: an exit status wraps mod 256, so a large count could land on 0.
[[ $ERRORS -eq 0 ]] || exit 1
exit 0
