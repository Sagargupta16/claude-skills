# Dev Rules Plugin

Development guardrails - git safety, security best practices, PR workflow discipline, and context optimization patterns.

## Skills

- **dev-rules**: Auto-activates as guardrails when writing code, making git operations, handling secrets, reviewing PRs, or working with dependencies. Enforces safe defaults without requiring manual invocation.

## What It Covers

| Area | Examples |
|------|---------|
| Git safety | No force push to main, no `reset --hard`, no `--no-verify` |
| Security | No committed secrets, parameterized queries, input validation |
| PR workflow | Read comments first, check merge readiness, verify before deleting forks |
| Context optimization | Progressive disclosure, targeted reads, efficient exploration |

## Installation

```
/plugin install dev-rules@sagar-dev-skills
```

This plugin has no commands - it provides background guardrails that activate automatically.
