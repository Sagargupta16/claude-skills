---
description: Create a pull request for the current branch
user_invocable: true
---

## Live state

- Branch: !`git rev-parse --abbrev-ref HEAD`
- Upstream: !`git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "no upstream set"`
- Base detection: !`git merge-base HEAD origin/main 2>/dev/null && echo "main" || echo "unknown"`
- Changed files: !`git diff origin/main...HEAD --stat 2>/dev/null || git diff main...HEAD --stat`
- Commits on branch: !`git log origin/main..HEAD --oneline 2>/dev/null || git log main..HEAD --oneline`
- Existing PR: !`gh pr view --json url,state,title 2>/dev/null || echo "no PR yet"`
- PR template: !`cat .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null || cat .github/pull_request_template.md 2>/dev/null || echo "no template"`

## Task

Using the live state above, create (or surface) a PR.

1. If an existing PR is listed above, return its URL. Do not create a duplicate.
2. If the upstream is not set, push with `git push -u origin <branch>`.
3. If a PR template exists above, fill it verbatim. Otherwise use this shape:

```markdown
## Summary

<1-3 bullets -- what changed and why>

## Test plan

- [ ] <what was run, what passed>
- [ ] <manual verification if relevant>
```

4. Title: conventional-commit style, under 70 chars, specific (not "update code").
5. Create via `gh pr create --title "..." --body "..."`.
6. Return the PR URL.

## Rules

- Never force push.
- Never include `Co-Authored-By` trailers.
- Never embed secrets, tokens, internal URLs.
- Keep Summary under 4 sentences.
- Testing section is mandatory -- "ran locally" is not enough.
