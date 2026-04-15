# CI/CD Plugin

GitHub Actions CI/CD patterns, workflow templates, and debugging guides.

## Skills

- **ci-cd**: Workflow templates for Node.js, Python, Rust, Go, and Docker. Caching strategies, matrix builds, secrets management, release automation, and common failure diagnosis.

## Commands

| Command | Description |
|---------|-------------|
| `/setup-ci` | Detect project type and generate a CI workflow |

## Agents

| Agent | Model | Description |
|-------|-------|-------------|
| `ci-fixer` | sonnet | Diagnoses failing CI/CD pipelines and proposes fixes |

## Example

```
> /setup-ci

Detected: Node.js (pnpm) from pnpm-lock.yaml
Generated: .github/workflows/ci.yml
  - Checkout, pnpm setup, install, lint, test, build
  - Cache: pnpm store via setup-node
  - Triggers: push to main, pull requests
```

## Installation

```
/plugin install ci-cd@sagar-dev-skills
```
