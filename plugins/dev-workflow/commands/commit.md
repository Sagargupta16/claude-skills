---
description: Review all changes and create a well-crafted conventional commit
user_invocable: true
---

## Live state

- Status: !`git status --short`
- Staged stat: !`git diff --cached --stat`
- Staged diff: !`git diff --cached`
- Unstaged stat: !`git diff --stat`
- Recent commit style: !`git log --oneline -5`

## Task

Review the live state above and create a conventional commit. Do not re-fetch diffs.

Steps:
1. If nothing is staged, stop and ask which files to stage. Never use `git add .` or `git add -A`.
2. Match the conventional-commit type from the staged diff: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`, `perf`, `build`, `ci`.
3. Match the repo's commit-style pattern shown above (prefix casing, scope usage, body length).
4. Subject under 72 chars, imperative mood, no trailing period.
5. If the *why* is not obvious from the subject, add a short body (1-3 lines).
6. Never commit files that likely contain secrets (`.env`, `credentials.json`, private keys).
7. Never add `Co-Authored-By` trailers. Never push unless explicitly asked.

Output: the commit (or a refusal with reason if anything above blocks).
