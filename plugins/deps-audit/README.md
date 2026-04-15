# Deps Audit Plugin

Multi-language dependency auditing, security scanning, and update management.

## Skills

- **deps-audit**: Vulnerability scanning, outdated package detection, unused dependency identification, and safe update strategies for npm, pip, cargo, and go.

## Commands

| Command | Description |
|---------|-------------|
| `/audit-deps` | Scan dependencies for vulnerabilities, outdated packages, and unused deps |

## Agents

| Agent | Model | Description |
|-------|-------|-------------|
| `dependency-auditor` | haiku | Audits dependencies for CVEs, outdated versions, and compatibility issues |

## Example

```
> /audit-deps

Detected: pnpm from pnpm-lock.yaml
Running: pnpm audit

Found 2 vulnerabilities:
  HIGH   lodash <4.17.21 (prototype pollution) -- fix: pnpm update lodash
  LOW    debug <4.3.1 (ReDoS) -- fix: pnpm update debug

Outdated: 5 packages (3 minor, 2 major)
Unused: 1 package (left-pad)
```

## Installation

```
/plugin install deps-audit@sagar-dev-skills
```
