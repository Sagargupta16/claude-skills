# OSS Contrib Plugin

Open source contribution workflow - upstream sync, compliance, code style matching, and PR preparation.

## Skills

- **oss-contrib**: Fork management, CONTRIBUTING.md compliance, code style matching, PR template filling, and project-specific reference patterns.

## Commands

| Command | Description |
|---------|-------------|
| `/sync-upstream` | Sync fork with upstream remote |
| `/prep-pr` | Prepare and validate a PR for upstream submission |

## Agents

| Agent | Model | Description |
|-------|-------|-------------|
| `pr-analyzer` | sonnet | Checks PR health -- CI status, review comments, merge readiness, and action items |

## Hooks

Registered in [`hooks/hooks.json`](hooks/hooks.json). Needs `jq` on your PATH to read the tool call.

| Hook | Event / matcher | Description |
|------|-----------------|-------------|
| `upstream-sync-check` | PreToolUse / `Bash`, on `gh pr create` | Warns when the branch is behind the upstream default branch. Skips repos with no `upstream` remote, and never blocks |

## Example

```
> /sync-upstream

Fetching upstream...
Merged upstream/main into local main (15 new commits).
Pushed to origin/main.
Your feature branch 'fix/template-fields' is 3 commits behind main.
Run: git rebase main

> /prep-pr

Read CONTRIBUTING.md: conventional commits required, CLA signed.
PR template found. Pre-filled: description, testing done, related issue.
Ready to submit.
```

## Installation

```
/plugin install oss-contrib@sagar-dev-skills
```
