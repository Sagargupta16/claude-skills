---
description: Audit project dependencies for vulnerabilities, outdated packages, and unused deps
user_invocable: true
---

Audit and report on the current project's dependencies.

Steps:
1. Detect package manager:
   - `pnpm-lock.yaml` -> pnpm
   - `package-lock.json` -> npm
   - `yarn.lock` -> yarn
   - `requirements.txt` / `pyproject.toml` -> pip / uv / poetry
   - `Cargo.toml` -> cargo
   - `go.mod` -> go
2. Run security vulnerability scan (language-appropriate audit command)
3. Check for outdated packages
4. Identify unused dependencies if tooling is available
5. Report in a clear summary:
   - Total dependencies (direct + transitive if available)
   - Security: critical/high/medium/low vulnerability counts
   - Outdated: list with current vs latest version
   - Unused: list of potentially removable packages
   - Recommended actions prioritized by severity

Use the deps-audit skill for all audit patterns and update strategies.
