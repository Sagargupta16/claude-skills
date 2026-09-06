#!/usr/bin/env bash
# secret-guard.sh - Blocks commits containing potential secrets
# Hook event: PreToolUse, matcher Bash (registered in hooks/hooks.json)
#
# Scans the staged content for patterns that indicate hardcoded secrets:
# API keys, tokens, passwords, connection strings, private keys.
# Exits 2 to block the commit if secrets are found (exit 1 would not block).

set -euo pipefail

# Claude Code passes the tool call as JSON on stdin, not as arguments.
if ! command -v jq &>/dev/null; then
  echo "secret-guard: jq is not on PATH, so this hook cannot read its input. Install jq to enable the guard."
  exit 0
fi

INPUT=$(cat || true)
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT" 2>/dev/null || true)

# Only inspect git commits -- this hook sees every Bash call.
if ! grep -qE '\bgit\b.*\bcommit\b' <<<"$CMD"; then
  exit 0
fi

# Patterns that indicate hardcoded secrets
PATTERNS=(
  'AKIA[0-9A-Z]{16}'                    # AWS access key
  'sk-[a-zA-Z0-9]{20,}'                 # OpenAI/Stripe secret key
  'ghp_[a-zA-Z0-9]{36}'                 # GitHub personal access token
  'gho_[a-zA-Z0-9]{36}'                 # GitHub OAuth token
  'glpat-[a-zA-Z0-9\-]{20}'            # GitLab personal access token
  'xox[bpors]-[a-zA-Z0-9\-]+'          # Slack token
  'password\s*=\s*["\x27][^"\x27]+'     # password = "..."
  'secret\s*=\s*["\x27][^"\x27]+'       # secret = "..."
  'PRIVATE KEY-----'                     # Private key block
  'mongodb(\+srv)?://[^/\s]+:[^/\s]+@'  # MongoDB connection string with creds
  'postgres://[^/\s]+:[^/\s]+@'         # Postgres connection string with creds
)

FOUND=0

# Scan the staged blobs, not the working tree: a secret that was staged and then
# edited out of the working copy still lands in the commit. Filenames arrive
# NUL-separated so paths containing spaces survive.
while IFS= read -r -d '' file; do
  blob=$(git show ":$file" 2>/dev/null || true)
  [ -n "$blob" ] || continue
  for pattern in "${PATTERNS[@]}"; do
    if grep -qE "$pattern" <<<"$blob"; then
      if [ "$FOUND" -eq 0 ]; then
        echo "BLOCKED: Potential secrets detected in staged content:" >&2
        echo "" >&2
        FOUND=1
      fi
      echo "  $file matches: $pattern" >&2
    fi
  done
done < <(git diff --cached -z --name-only --diff-filter=d 2>/dev/null)

if [ "$FOUND" -eq 1 ]; then
  # stderr is what Claude Code surfaces as the reason a call was blocked.
  echo "" >&2
  echo "Remove secrets from these files before committing." >&2
  echo "Use environment variables or .env files (gitignored) instead." >&2
  exit 2
fi

exit 0
