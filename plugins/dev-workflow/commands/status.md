---
description: Give a comprehensive status overview of the current repository
user_invocable: true
---

Give a comprehensive status overview of the current repository.

Steps:
1. `git status` - working tree state
2. `git log --oneline -5` - recent commits
3. `git branch -a` - all branches
4. `git stash list` - any stashed changes
5. Check for open PRs: `gh pr list --state open`
6. Check for CI status on current branch
7. Check if behind/ahead of remote
8. Check for any merge conflicts with main

Provide a clean summary of where things stand.
