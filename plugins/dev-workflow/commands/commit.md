---
description: Review all changes and create a well-crafted conventional commit
user_invocable: true
---

Review all staged and unstaged changes, then create a well-crafted git commit.

Steps:
1. Run `git status` to see all changes
2. Run `git diff` and `git diff --staged` to understand what changed
3. Run `git log --oneline -5` to match the repo's commit style
4. Stage only relevant files (never stage .env, credentials, or large binaries)
5. Write a concise commit message:
   - Use conventional commit format: `type: short description`
   - Types: feat, fix, refactor, docs, test, chore, style, perf
   - Focus on WHY, not WHAT
   - Keep first line under 72 chars
6. Create the commit
7. Show the result with `git status`

Do NOT add `Co-Authored-By` lines. Do NOT push unless explicitly asked.
