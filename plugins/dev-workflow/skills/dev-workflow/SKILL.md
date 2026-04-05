---
name: dev-workflow
description: Use when performing common development tasks like committing code, reviewing changes, running tests, fixing bugs, creating PRs, or checking repo status. Provides structured workflows for everyday git and development operations.
---

# Development Workflow Patterns

## Quick Reference

| Task | Command | What It Does |
|------|---------|-------------|
| Commit | `/commit` | Stage changes, write conventional commit message |
| Review | `/review` | Analyze branch changes for bugs, security, quality |
| Test | `/test` | Detect test framework, run tests, diagnose failures |
| Fix | `/fix` | Trace root cause, implement minimal fix, verify |
| PR | `/pr` | Create pull request with summary and test plan |
| Status | `/status` | Full repo overview: branches, PRs, CI, sync state |
| Check PR | `/check-pr` | CI status, reviews, comments, merge readiness |

## Commit Workflow

1. Run `git status` and `git diff` to understand changes
2. Run `git log --oneline -5` to match the repo's commit style
3. Stage only relevant files (never stage .env, credentials, binaries)
4. Write a conventional commit message:
   - Format: `type: short description`
   - Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`, `perf`
   - Focus on WHY, not WHAT
   - Keep first line under 72 chars
5. Never push unless explicitly asked

## Code Review Checklist

When reviewing branch changes (`git diff main...HEAD`):

| Category | Check For |
|----------|----------|
| Logic | Bugs, off-by-one errors, null handling |
| Security | Injection, XSS, secrets exposure, CORS |
| Performance | N+1 queries, unnecessary loops, missing indexes |
| Error handling | Unhandled exceptions, missing edge cases |
| Style | Consistency with surrounding code |
| Tests | New code covered? Edge cases tested? |
| API | Breaking changes to public interfaces? |

Provide: overall assessment (ship it / needs changes / major issues), specific issues with file:line references, suggested fixes.

## Test Runner

Detect the framework and run tests:

| Config File | Framework | Command |
|------------|-----------|---------|
| `package.json` (scripts.test) | npm/yarn/pnpm | `npm test` / `pnpm test` |
| `pytest.ini` / `pyproject.toml` | pytest | `pytest` |
| `Cargo.toml` | cargo | `cargo test` |
| `go.mod` | go | `go test ./...` |
| `Makefile` (test target) | make | `make test` |

On failure: parse output, identify the failing test, show the assertion, suggest a fix (don't auto-fix unless asked).

## Bug Fix Workflow

1. **Understand**: Read error messages, identify failing file and line
2. **Root cause**: Trace execution path, check `git log --oneline -10` for recent changes
3. **Fix**: Make the minimal change needed - no refactoring, no unrelated improvements
4. **Verify**: Run related tests, check nothing else broke
5. **Explain**: Show what changed and why

## PR Creation

1. Run `git log` and `git diff` against base branch
2. Check if PR already exists (`gh pr view`) - if so, show URL instead
3. Draft title (under 70 chars, conventional commit style)
4. Create PR with:
   - `## Summary` - 2-3 bullet points
   - `## Test plan` - checklist of what was tested
5. Push branch if needed, return PR URL
6. Never force push

## Repo Status Dashboard

Gather and present:
- `git status` - working tree state
- `git log --oneline -5` - recent commits
- `git branch -a` - all branches
- `git stash list` - stashed changes
- `gh pr list --state open` - open PRs
- CI status on current branch
- Behind/ahead of remote
- Merge conflicts with main

## PR Health Check

For a given PR number:
1. Get state, mergeable status, review decision, CI checks
2. Read new comments and review feedback
3. For failures: fetch logs, identify root cause, suggest fixes
4. Summary: PR state, CI status (green/failing), review status, action items
