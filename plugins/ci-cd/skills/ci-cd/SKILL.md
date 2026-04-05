---
name: ci-cd
description: Use when setting up, debugging, or optimizing GitHub Actions CI/CD workflows. Covers workflow syntax, caching strategies, matrix builds, secrets management, release automation, and diagnosing failing checks.
---

# GitHub Actions CI/CD Patterns

## Quick Reference

| Task | Approach |
|------|----------|
| New workflow | Choose template below by project type |
| CI failing | Check logs -> match common failure patterns below |
| Slow builds | Add caching, use matrix for parallelism |
| Release | Tag-triggered workflow with changelog |
| Secrets | Repository secrets + environment protection rules |
| Reusable logic | Composite actions or reusable workflows |

## Workflow Structure

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup runtime
        # Language-specific setup
      - name: Install dependencies
        # Package manager install
      - name: Lint
        # Linter run
      - name: Test
        # Test suite
      - name: Build
        # Build step (if applicable)
```

## Language-Specific Templates

### Node.js (pnpm)

```yaml
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm test
      - run: pnpm build
```

### Python (uv)

```yaml
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v5
      - uses: actions/setup-python@v5
        with:
          python-version: "3.13"
      - run: uv sync
      - run: uv run ruff check .
      - run: uv run pytest
```

### Python (pip)

```yaml
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.13"
          cache: pip
      - run: pip install -r requirements.txt
      - run: ruff check .
      - run: pytest
```

### Docker Build + Push

```yaml
jobs:
  docker:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          push: ${{ github.event_name != 'pull_request' }}
          tags: ghcr.io/${{ github.repository }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## Caching Strategies

| Package Manager | Cache Key |
|----------------|-----------|
| pnpm | `pnpm/action-setup` + `setup-node` with `cache: pnpm` |
| npm | `setup-node` with `cache: npm` |
| pip | `setup-python` with `cache: pip` |
| uv | `setup-uv` handles caching automatically |
| cargo | `actions/cache` with `target/` and `Cargo.lock` hash |
| go | `setup-go` with `cache: true` |
| Docker | `cache-from: type=gha` in `build-push-action` |

Custom cache example:
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.cache/custom
    key: ${{ runner.os }}-custom-${{ hashFiles('**/lockfile') }}
    restore-keys: ${{ runner.os }}-custom-
```

## Matrix Builds

```yaml
jobs:
  test:
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        node-version: [20, 22]
        exclude:
          - os: windows-latest
            node-version: 20
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
```

Use `fail-fast: false` to see all failures, not just the first.

## Secrets Management

```yaml
# Use repository or environment secrets - never hardcode
env:
  API_KEY: ${{ secrets.API_KEY }}

# Protect production deployments with environments
jobs:
  deploy:
    environment: production  # Requires approval
    steps:
      - run: deploy --token ${{ secrets.DEPLOY_TOKEN }}
```

Rules:
- Never echo or log secrets
- Use `environment` protection for production deployments
- Rotate secrets if exposed in logs
- Use `GITHUB_TOKEN` for GitHub API calls (auto-provided)

## Release Automation

```yaml
name: Release
on:
  push:
    tags: ["v*"]

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Create GitHub Release
        env:
          GH_TOKEN: ${{ github.token }}
        run: gh release create ${{ github.ref_name }} --generate-notes
```

## Debugging CI Failures

### Common Failure Patterns

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| "Permission denied" | Missing `permissions` block | Add required permissions to job |
| "Resource not accessible" | `GITHUB_TOKEN` scope too narrow | Add `permissions: contents: write` etc. |
| "Cache not found" | Changed lockfile or wrong cache key | Check `hashFiles()` pattern matches lockfile |
| "Out of disk space" | Large build artifacts or Docker layers | Add cleanup step or use larger runner |
| Flaky tests (pass/fail randomly) | Race conditions or timing deps | Add retries or fix test isolation |
| "Node.js version not found" | Version string format | Use quotes: `node-version: "22"` |
| Different behavior on PR vs push | Different trigger contexts | Check `github.event_name` conditions |

### Reading Workflow Logs

1. Go to the Actions tab -> click the failing run
2. Expand the failing step
3. Look for the **first** error (not the last) - cascading failures are common
4. Check the "Set up job" step for environment issues
5. Use `ACTIONS_STEP_DEBUG` secret set to `true` for verbose logging

## Reusable Workflows

```yaml
# .github/workflows/reusable-test.yml
on:
  workflow_call:
    inputs:
      node-version:
        type: string
        default: "22"

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
      - run: npm ci && npm test
```

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: "22"
```

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Use `actions/checkout@v2` | Use `@v4` (latest major) |
| `npm install` in CI | `npm ci` (clean install from lockfile) |
| Skip `permissions` block | Always declare minimum required permissions |
| Cache `node_modules/` directly | Let `setup-node` cache the package manager store |
| Run deploys on every push | Use tag triggers or environment protection |
| Use `continue-on-error: true` to hide failures | Fix the underlying issue |
| Duplicate steps across workflows | Extract to reusable workflow or composite action |
