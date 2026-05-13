---
name: renovate-triage
description: Use when triaging open Renovate PRs across your own repos into merge / close / defer. Activates on "renovate triage", "review dep PRs", "monthly deps", or on the 1st of a month if deps are grouped monthly.
disable-model-invocation: true
allowed-tools: Bash(gh search prs:*) Bash(gh api:*) Bash(gh pr:*)
---

# renovate-triage

## Live data

- Open Renovate PRs authored by `app/renovate` on your repos: !`gh search prs --author app/renovate --state open --json repository,title,number,url --limit 100 2>/dev/null || echo "gh unavailable or not authenticated"`

## When to activate

- User says "renovate triage", "review dep PRs", "monthly deps", "batch deps".
- It's the 1st of the month and deps are grouped monthly.

Skip if: the user is asking about a single specific PR (use a PR-review skill instead), or if Renovate isn't configured on their repos.

## Steps

1. **Use the live PR list above.** Do not re-fetch.
2. **Group by repo.** One repo's PRs often share the same grouping rule.
3. **For each PR, fetch merge state and CI:**
   - `gh api repos/{owner}/{repo}/pulls/{num} --jq '{mergeable, mergeStateStatus, title, labels}'`
   - `gh pr checks <url>`
4. **Classify each PR:**
   - **Merge** -- CI green, patch or minor bump, library is stable and well-adopted, no flags in the repo's Renovate config.
   - **Close** -- superseded by a newer PR, wrong repo, duplicate, or abandoned.
   - **Defer** -- major version bump, known breaking change, CI red that needs investigation, or a library that the repo pins deliberately.
5. **Output a table** grouped by repo with recommended action per PR.
6. **Do not merge automatically.** Present the plan; the user approves.
7. **After approval,** merge in order, one repo at a time, verifying CI between merges (not in parallel).

## Rules

- **Never** merge a Renovate PR with unresolved security findings on the PR or the repo.
- `@types/*`-only bumps can silently break builds -- always check CI is green before merging, not just "mergeable".
- **Major bumps always defer.** React 18 -> 19, Next 14 -> 15, Node 20 -> 22, etc. These are planned work, not routine hygiene.
- Close old superseded PRs before merging the latest one in a grouped series -- otherwise Renovate may reopen them.

## Output

```text
| Repo | PR | Bump | CI | Action | Notes |
|---|---|---|---|---|---|
```

Group by repo. After the table, list the proposed merge order across all repos.
