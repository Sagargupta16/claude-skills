---
description: Sync current fork with upstream remote and prepare for contribution
user_invocable: true
---

Sync the current forked repository with its upstream remote.

Steps:
1. Verify we're in a git repo with an `upstream` remote configured
2. If no upstream remote exists, detect the fork parent via `gh repo view --json parent` and add it
3. Fetch upstream: `git fetch upstream`
4. Check current branch -- if on main/master, merge upstream changes
5. If on a feature branch, show status relative to upstream
6. Push synced main to origin: `git push origin main`
7. Show summary: commits behind/ahead, any conflicts

If conflicts are found, list the conflicting files and suggest resolution approach.
