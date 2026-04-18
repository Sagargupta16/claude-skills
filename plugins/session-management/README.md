# session-management

Session lifecycle management -- when to start new sessions, rewind vs correct decisions, handoff summaries between sessions, and multi-session workflow patterns.

## Components

| Type | Name | Description |
|------|------|-------------|
| Skill | session-management | Session lifecycle, handoff patterns, session hygiene |
| Command | `/handoff` | Generate a handoff summary for session transitions |
| Agent | session-advisor | Evaluate session health and recommend continue vs restart |

## Key Concepts

- **New task = new session** -- avoid context pollution from unrelated work
- **Handoff summaries** bridge sessions with Done/Next/Decisions/Gotchas/State
- **Multi-session workflows**: Plan -> Implement Core -> Polish -> Ship
- **Resume patterns**: `claude -c` for last session, `claude -r "id"` for specific session

## Install

```bash
claude plugin add sagar-dev-skills/session-management
```
