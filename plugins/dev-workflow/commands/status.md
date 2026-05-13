---
description: Give a comprehensive status overview of the current repository
user_invocable: true
---

## Live state

- Branch: !`git rev-parse --abbrev-ref HEAD`
- Working tree: !`git status --short`
- Recent commits: !`git log --oneline -5`
- Stashes: !`git stash list`
- Ahead/behind main: !`git rev-list --left-right --count origin/main...HEAD 2>/dev/null || git rev-list --left-right --count main...HEAD 2>/dev/null || echo "no upstream"`
- Open PRs from this branch: !`gh pr list --head $(git rev-parse --abbrev-ref HEAD) --json number,title,state 2>/dev/null || echo "gh not available or not a GitHub repo"`

## Task

Using the live state above, produce a concise status overview:

- **Where we are**: branch, commits ahead/behind, working tree state
- **Open PRs**: any associated with this branch
- **Hazards**: unpushed work, stashes, conflicts-with-main risk
- **Recommended next action**: one line

Do not re-fetch what is already inlined above.
