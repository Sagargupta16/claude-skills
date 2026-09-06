# Git Advanced Plugin

Advanced git operations beyond basic commit/push/pull.

## Skills

- **git-advanced**: Rebase workflows, interactive rebase, cherry-pick, conflict resolution strategy, git bisect, stash management, undo operations, reflog recovery, and history exploration.

## Commands

| Command | Description |
|---------|-------------|
| `/resolve-conflict` | Analyze and resolve merge conflicts with context from both branches |

## Agents

| Agent | Model | Description |
|-------|-------|-------------|
| `git-assistant` | sonnet | Handles complex rebases, cherry-picks, conflict resolution, and history cleanup |

## Hooks

Registered in [`hooks/hooks.json`](hooks/hooks.json). Needs `jq` on your PATH to read the tool call.

| Hook | Event / matcher | Description |
|------|-----------------|-------------|
| `commit-lint` | PostToolUse / `Bash`, on `git commit` | Checks the new commit's conventional-commit format and subject length. Warns only, never blocks |

## Example

```
> /resolve-conflict

Found 2 conflicted files after rebase onto main:

src/api.py:
  Ours: added rate limiting middleware
  Theirs: refactored middleware chain
  Resolution: keep both -- rate limiting fits into new chain

src/config.py:
  Ours: added RATE_LIMIT env var
  Theirs: reorganized config sections
  Resolution: add RATE_LIMIT to new section structure

Apply resolutions? Tests will run after.
```

## Installation

```
/plugin install git-advanced@sagar-dev-skills
```
