# renovate-triage

Batch-triage all your open Renovate PRs into merge / close / defer. Groups by repo, checks CI, proposes a merge order.

## What it does

- Pulls open Renovate PRs across all your repos (`gh search prs --author app/renovate --state open`).
- Classifies each PR:
  - **Merge** -- CI green, patch or minor bump, stable library.
  - **Close** -- superseded, duplicate, abandoned.
  - **Defer** -- major version bump, known breaking change, or CI red needing investigation.
- Proposes a merge order (one repo at a time, verify CI between).
- Never merges automatically. You approve first.

## When it activates

- "Renovate triage"
- "Review dep PRs"
- "Monthly deps" / "batch deps"
- Start of month if deps are grouped monthly.

## Requirements

- `gh` CLI authenticated.
- Renovate configured on your repos (this skill does not configure Renovate -- see `repo-polish` for that).

## Safety

- Never merges security-flagged PRs without resolution.
- Major version bumps always defer by design.
- Closes superseded PRs before merging latest in grouped series.
