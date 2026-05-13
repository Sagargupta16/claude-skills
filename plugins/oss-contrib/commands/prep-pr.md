---
description: Prepare a PR for an upstream open source project with proper template compliance
user_invocable: true
---

## Live state

- Branch: !`git rev-parse --abbrev-ref HEAD`
- Remote parent: !`gh repo view --json parent -q '.parent | "\(.owner.login)/\(.name)"' 2>/dev/null || echo "not a fork"`
- CONTRIBUTING: !`cat CONTRIBUTING.md 2>/dev/null | head -100 || cat .github/CONTRIBUTING.md 2>/dev/null | head -100 || echo "no CONTRIBUTING.md"`
- PR template: !`cat .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null || cat .github/pull_request_template.md 2>/dev/null || echo "no PR template"`
- Diff stat: !`git diff $(git merge-base HEAD upstream/main 2>/dev/null || git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main)...HEAD --stat`
- Recent merged PRs (for style match): !`gh pr list --state merged --limit 3 --json title,body -q '.[] | "\(.title)\n\(.body | .[0:300])\n---"' 2>/dev/null || echo "gh unavailable"`

## Task

Prepare a PR for upstream review. Do not create it automatically.

1. **Read CONTRIBUTING.md above.** Note CLA/DCO requirements, commit style, testing requirements, AI-disclosure rules.
2. **Match recent merged PRs.** Tone, title format, body shape, body length.
3. **Quality-bar check (7+/10).** Is this a real bug fix or meaningful feature? Skip self-promo awesome-list adds, trivial typos, docstring-only changes unless they fix a real issue.
4. **Scope discipline.** Review diff stat above -- flag any files outside the issue's scope as drive-by changes to strip.
5. **Tests.** Do tests exist for the change? Do they match upstream's test patterns (framework, fixtures, markers)?
6. **Rebase check.** Is the branch up to date with `upstream/main`?
7. **Fill the PR template verbatim** (if one exists above). Include AI-disclosure checkboxes when the repo asks for them.
8. **Project-specific conventions.** If the upstream is Apache Airflow: use `[component] Description` title format, verify template-rendering tests use `create_task_instance_of_operator`.

## Output

```text
Upstream: <owner/repo>
Quality bar: <pass/fail + reason>
Scope: <narrow/wide + any drive-by files>
Tests: <match/mismatch + what>
Rebase: <up-to-date/behind-by-N>
PR template: <filled/missing/N-A>
Ready: <yes/no>
Blockers: <list or "none">

---
PROPOSED TITLE: <title>

PROPOSED BODY:
<filled template or shape>
```

## Hard rules

- **Never comment on or push to upstream PRs without explicit permission.** Preparation is autonomous. Posting is not.
- Never include `Co-Authored-By` trailers.
- Never embed secrets or internal URLs.
- Do not create the PR. Show the prepared content; user decides.
