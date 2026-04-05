---
description: Analyze and resolve git merge conflicts with context from both branches
user_invocable: true
---

Resolve merge conflicts in the current branch.

Steps:
1. Run `git status` to identify conflicted files
2. For each conflicted file:
   - Read the conflict markers
   - Check `git log --oneline` for both branches to understand intent
   - Determine the correct resolution (keep both, choose one, or rewrite)
3. Present the proposed resolution for each file before applying
4. After user approval, resolve conflicts and stage the files
5. If in a rebase: `git rebase --continue`
6. If in a merge: `git merge --continue`
7. Run tests to verify the resolution is correct

Do NOT blindly accept "ours" or "theirs". Read both sides and merge intentionally.
