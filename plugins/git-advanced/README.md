# Git Advanced Plugin

Advanced git operations beyond basic commit/push/pull.

## Skills

- **git-advanced**: Rebase workflows, interactive rebase, cherry-pick, conflict resolution strategy, git bisect, stash management, undo operations, reflog recovery, and history exploration.

## Commands

- `/resolve-conflict`: Analyze and resolve merge conflicts with context from both branches

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
