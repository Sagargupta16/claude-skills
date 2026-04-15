#!/usr/bin/env bash
# secret-guard.sh - Blocks commits containing potential secrets
# Hook event: PreToolCall (git commit)
#
# Scans staged files for patterns that indicate hardcoded secrets:
# API keys, tokens, passwords, connection strings, private keys.
# Exits non-zero to block the commit if secrets are found.

set -euo pipefail

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

# Get staged files (skip deleted files and binary files)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=d 2>/dev/null || true)

if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

FOUND=0

for pattern in "${PATTERNS[@]}"; do
  # Search staged file contents for secret patterns
  MATCHES=$(echo "$STAGED_FILES" | xargs grep -lEn "$pattern" 2>/dev/null || true)
  if [ -n "$MATCHES" ]; then
    if [ "$FOUND" -eq 0 ]; then
      echo "BLOCKED: Potential secrets detected in staged files:"
      echo ""
    fi
    echo "  Pattern: $pattern"
    echo "  Files: $MATCHES"
    echo ""
    FOUND=1
  fi
done

if [ "$FOUND" -eq 1 ]; then
  echo "Remove secrets from these files before committing."
  echo "Use environment variables or .env files (gitignored) instead."
  exit 1
fi

exit 0
