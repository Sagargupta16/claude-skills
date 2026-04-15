# Dev Rules Plugin

Development guardrails - git safety, security best practices, PR workflow discipline, and context optimization patterns.

## Skills

- **dev-rules**: Auto-activates as guardrails when writing code, making git operations, handling secrets, reviewing PRs, or working with dependencies. Enforces safe defaults without requiring manual invocation.

## Agents

| Agent | Model | Description |
|-------|-------|-------------|
| `guardrail-checker` | haiku | Verifies code changes follow git safety, security, and coding standards |

## Hooks

| Hook | Event | Description |
|------|-------|-------------|
| `secret-guard` | PreToolCall (git commit) | Blocks commits containing hardcoded secrets |
| `no-force-push` | PreToolCall (git push) | Blocks force pushes to main/master |
| `branch-guard` | PreToolCall (git commit) | Warns when committing directly to main |

## What It Covers

| Area | Examples |
|------|---------|
| Git safety | No force push to main, no `reset --hard`, no `--no-verify` |
| Security | No committed secrets, parameterized queries, input validation |
| PR workflow | Read comments first, check merge readiness, verify before deleting forks |
| Context optimization | Progressive disclosure, targeted reads, efficient exploration |

## Example

When you run `git add .`, the skill intervenes:

```
WARN: `git add .` risks staging secrets or binaries.
Staging specific files instead: src/api.py, src/models.py
Skipped: .env (matches secret pattern)
```

## Installation

```
/plugin install dev-rules@sagar-dev-skills
```
