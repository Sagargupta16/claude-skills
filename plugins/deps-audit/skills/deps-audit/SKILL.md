---
name: deps-audit
description: Use when auditing, updating, or securing project dependencies. Covers multi-language dependency detection, security vulnerability scanning, outdated package identification, unused dependency detection, and update strategies for npm, pip, cargo, and go.
---

# Dependency Audit and Management

## Quick Reference

| Task | Approach |
|------|----------|
| Security scan | Run language-specific audit command |
| Find outdated | Check against latest versions |
| Find unused | Analyze imports vs declared dependencies |
| Update safely | Minor/patch first, test, then major |
| Lock files | Always commit lock files |

## Package Manager Detection

| File | Package Manager | Audit Command |
|------|----------------|---------------|
| `pnpm-lock.yaml` | pnpm | `pnpm audit` |
| `package-lock.json` | npm | `npm audit` |
| `yarn.lock` | yarn | `yarn audit` |
| `bun.lockb` | bun | `bun audit` (if available) |
| `requirements.txt` | pip | `pip-audit` |
| `pyproject.toml` (with uv) | uv | `uv pip audit` |
| `poetry.lock` | poetry | `poetry audit` (via plugin) |
| `Cargo.lock` | cargo | `cargo audit` |
| `go.sum` | go | `govulncheck ./...` |

## Security Vulnerability Scanning

### Node.js

```bash
# Check for known vulnerabilities
pnpm audit
# or
npm audit

# Auto-fix compatible updates
pnpm audit --fix
# or
npm audit fix

# See what would change without applying
npm audit fix --dry-run

# Force fixes (may include breaking changes)
npm audit fix --force  # Use with caution
```

### Python

```bash
# Install pip-audit if not present
pip install pip-audit

# Scan requirements.txt
pip-audit -r requirements.txt

# Scan installed packages
pip-audit

# Output as JSON for processing
pip-audit --format json

# Fix vulnerabilities
pip-audit --fix -r requirements.txt
```

### Rust

```bash
# Install cargo-audit
cargo install cargo-audit

# Scan for vulnerabilities
cargo audit

# Auto-fix compatible updates
cargo audit fix
```

### Go

```bash
# Install govulncheck
go install golang.org/x/vuln/cmd/govulncheck@latest

# Scan for vulnerabilities
govulncheck ./...
```

## Outdated Package Detection

### Node.js

```bash
# List outdated packages
pnpm outdated
# or
npm outdated

# Interactive update (pnpm)
pnpm update --interactive --latest
```

### Python

```bash
# List outdated packages
pip list --outdated

# With pip-tools
pip-compile --upgrade requirements.in
```

### Rust

```bash
# Install cargo-outdated
cargo install cargo-outdated

# List outdated
cargo outdated
```

### Go

```bash
# List available updates
go list -m -u all

# Update all dependencies
go get -u ./...
go mod tidy
```

## Unused Dependency Detection

### Node.js

```bash
# Install depcheck
npx depcheck

# Common false positives to ignore:
# - Babel plugins (loaded by config)
# - ESLint plugins (loaded by config)
# - TypeScript type packages (@types/*)
# - PostCSS plugins
```

### Python

Manually check: search codebase for each package name in imports.

```bash
# Check if a specific package is imported anywhere
grep -r "import package_name" src/
grep -r "from package_name" src/
```

## Update Strategy

### Safe Update Order

1. **Patch updates first** (1.2.3 -> 1.2.4): Bug fixes, safe to batch
2. **Minor updates** (1.2.3 -> 1.3.0): New features, backward-compatible
3. **Major updates** (1.2.3 -> 2.0.0): Breaking changes, update one at a time

### For Each Major Update

1. Read the changelog/migration guide
2. Update the single package
3. Run the full test suite
4. Fix any breaking changes
5. Commit before moving to the next

### Automated Updates

Use Renovate or Dependabot for automated PRs:

**Renovate** (recommended):
```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "schedule": ["on the first day of the month"],
  "groupName": "all dependencies",
  "groupSlug": "all"
}
```

**Dependabot**:
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: npm
    directory: /
    schedule:
      interval: monthly
    groups:
      all-dependencies:
        patterns: ["*"]
```

## Lock File Management

| Lock File | Must Commit? | Why |
|-----------|-------------|-----|
| `package-lock.json` | Yes | Ensures reproducible builds |
| `pnpm-lock.yaml` | Yes | Same |
| `yarn.lock` | Yes | Same |
| `Cargo.lock` (binary) | Yes | Reproducible builds for binaries |
| `Cargo.lock` (library) | Debatable | Libraries usually don't commit |
| `go.sum` | Yes | Integrity verification |
| `poetry.lock` | Yes | Reproducible environments |
| `requirements.txt` (pinned) | Yes | Acts as lock file |

## Common Issues

| Problem | Solution |
|---------|----------|
| Conflicting peer dependencies | Check compatibility matrix, may need `--legacy-peer-deps` |
| "ERESOLVE unable to resolve" | Peer dependency conflict - check versions |
| Vulnerability in transitive dep | Use `overrides` (npm) or `resolutions` (yarn) to force version |
| Lock file conflicts after merge | Delete lock file, reinstall, commit new lock |
| `pip-audit` finds no fix available | Pin to latest patched version or find alternative package |
| Cargo feature conflicts | Check feature flags in `Cargo.toml` |

## Transitive Dependency Overrides

When a vulnerability exists in a transitive (indirect) dependency:

### npm/pnpm (package.json)
```json
{
  "overrides": {
    "vulnerable-package": ">=2.0.1"
  }
}
```

### Yarn (package.json)
```json
{
  "resolutions": {
    "vulnerable-package": ">=2.0.1"
  }
}
```

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Ignore audit warnings | Triage and fix or document exceptions |
| Use `*` or `latest` for versions | Pin to specific semver ranges |
| Skip lock files in commits | Always commit lock files |
| Update everything at once | Update in safe order (patch -> minor -> major) |
| Suppress audit exit codes in CI | Fix vulnerabilities or add documented exceptions |
| Install from `master` branch | Use published releases with version numbers |
