# starter-session-audit

End-of-session audit. Catches things you told Claude during the session that should be saved permanently -- so you never have to say them again.

## What it does

Two things, only:

1. **Scans the conversation** for corrections, preferences, decisions, and new context that are not already in your CLAUDE.md / MEMORY.md / STATUS.md / rules files.
2. **Proposes where to save each finding** -- file path, section, exact wording. You approve or skip each one.

No file reorganization, no cleanup, no progress tracking.

## When it activates

- "Audit this session"
- "Session audit"
- "What did we miss"
- "End of session check"
- `/starter-session-audit`

## How it adapts

Works with any persistence layout -- a single `CLAUDE.md`, or the full three-tier stack (user CLAUDE.md + project CLAUDE.md + MEMORY.md + STATUS.md + `.claude/rules/` + `.claude/resources/`). If a file doesn't exist, the routing adapts or asks.

## Hard rules

- Never writes without approval.
- Never saves secrets -- flags them and refuses.
- Never duplicates what's already saved.
- Never invents findings. If the session had no learnings, it says so.

## Credit

Adapted from a community template. Rewritten to be persistence-layout agnostic.
