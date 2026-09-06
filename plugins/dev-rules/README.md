# Dev Rules Plugin

Development guardrails - git safety, security best practices, PR workflow discipline, and context optimization patterns.

## Skills

- **dev-rules**: Auto-activates as guardrails when writing code, making git operations, handling secrets, reviewing PRs, or working with dependencies. Enforces safe defaults without requiring manual invocation.

## Agents

| Agent | Model | Description |
|-------|-------|-------------|
| `guardrail-checker` | haiku | Verifies code changes follow git safety, security, and coding standards |

## Hooks

Registered in [`hooks/hooks.json`](hooks/hooks.json). All three match the `Bash` tool, then require the shell statement to start with `git` before doing anything, so a command that merely mentions `git commit` (a grep over the docs, say) is left alone.

| Hook | Event / matcher | Description |
|------|-----------------|-------------|
| `secret-guard` | PreToolUse / `Bash`, on `git commit` | Blocks the commit (exit 2) when a secret pattern appears in the staged content, or in a tracked working-tree change that `-a` / `-am` would stage |
| `no-force-push` | PreToolUse / `Bash`, on `git push` | Blocks (exit 2) a force push aimed at main, master, production, or release. Reads the refspec, so a target named on the command line counts, `+branch` counts as a force, and `--force` at a feature branch does not |
| `branch-guard` | PreToolUse / `Bash`, on `git commit` | Warns when committing directly to main or master. Never blocks |

These hooks need `jq` on your PATH to read the tool call. Without it the two guards say so once and stand down rather than blocking.

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
