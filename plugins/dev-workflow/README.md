# Dev Workflow Plugin

Everyday development commands - commit, review, test, fix, create PRs, and check repo status.

## Commands

| Command | Description |
|---------|-------------|
| `/commit` | Review changes and create a conventional commit |
| `/review` | Analyze branch changes for bugs, security, quality |
| `/test` | Detect test framework, run tests, diagnose failures |
| `/fix` | Trace root cause, implement minimal fix, verify |
| `/pr` | Create pull request with summary and test plan |
| `/status` | Full repo overview: branches, PRs, CI, sync state |
| `/check-pr` | Check PR CI status, reviews, merge readiness |

## Skills

- **dev-workflow**: Structured workflows for git operations, code review checklists, test runner patterns, and bug fix methodology.

## Example

```
> /commit

Staged 3 files: src/auth.py, src/routes.py, tests/test_auth.py
Matched repo style from recent commits.
Created commit: feat: add JWT authentication to user endpoints

> /test

Detected pytest from pyproject.toml.
Running: pytest
12 passed, 0 failed (2.3s)
```

## Installation

```
/plugin install dev-workflow@sagar-dev-skills
```
