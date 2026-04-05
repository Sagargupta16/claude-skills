---
description: Create a pull request for the current branch
user_invocable: true
---

Create a pull request for the current branch.

Steps:
1. Run `git log` and `git diff` against the base branch to understand all changes
2. Draft a concise PR title (under 70 chars) and description
3. Push the branch if not already pushed
4. Create the PR using `gh pr create` with:
   - A clear title summarizing the change
   - A body with: ## Summary (2-3 bullet points), ## Test plan (checklist)
   - Appropriate labels if the repo uses them
5. Return the PR URL

Rules:
- Never force push
- Check if a PR already exists for this branch first (`gh pr view`)
- If PR exists, show its URL instead of creating a duplicate
- Keep the title short and descriptive, not generic
- Use conventional commit style for the title (feat:, fix:, refactor:, etc.)
