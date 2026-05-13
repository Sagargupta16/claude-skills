---
description: Sync current fork with upstream remote and prepare for contribution
user_invocable: true
---

## Live state

- Remotes: !`git remote -v`
- Current branch: !`git rev-parse --abbrev-ref HEAD`
- Fork parent: !`gh repo view --json parent -q '.parent | "\(.owner.login)/\(.name)"' 2>/dev/null || echo "not a fork or gh unavailable"`

## Task

Sync the current forked repository with its upstream.

1. If no `upstream` remote is listed above, add it: `git remote add upstream <parent-repo-url>` using the fork parent from the live state.
2. Fetch: `git fetch upstream`.
3. If on `main` or `master`:
   - Merge fast-forward: `git merge --ff-only upstream/main` (or `upstream/master`).
   - If not fast-forward-able, stop and report divergence. Do not auto-rebase `main`.
   - Push synced main to origin: `git push origin main`.
4. If on a feature branch:
   - Show status relative to `upstream/main`: commits behind, commits ahead.
   - Recommend `git rebase upstream/main` -- but do not run it without explicit confirmation.
5. Report: commits behind/ahead, any conflicts, any push needed.

## Rules

- Never force push to `main` or `master`.
- Never rebase a feature branch without explicit user confirmation -- rebasing rewrites history.
- If conflicts exist, list the conflicting files and suggest resolution approach. Do not auto-resolve.
