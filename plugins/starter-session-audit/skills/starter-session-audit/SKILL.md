---
name: starter-session-audit
description: Use when the user asks to audit a session for uncaptured learnings. Activates on "audit this session", "session audit", "what did we miss", "end of session check", or "/starter-session-audit". Scans the conversation for corrections, preferences, decisions, and new context, then proposes where to save each.
disable-model-invocation: true
allowed-tools: Read Edit Write Glob Grep
---

# starter-session-audit

A lightweight end-of-session audit. Catches things the user said during the session that should be saved permanently so they never have to say them again.

## What this skill does

Two things, and only two things:

1. **Scans the conversation for uncaptured learnings** -- corrections, preferences, decisions, and new context that are not already in the project's instruction files.
2. **Proposes where to save each finding** -- which file, which section, exact wording. The user approves or skips each one.

No file reorganization. No cleanup. No progress tracking. Just: "Did I learn anything this session that should be remembered?"

## Step 1: Discover the persistence layout

Claude Code sessions can use several layers of persistence. Load whichever files exist:

- **Project CLAUDE.md** -- at repo root or workspace root (standing instructions for this project).
- **User-global CLAUDE.md** -- typically `~/.claude/CLAUDE.md` (preferences that apply everywhere).
- **Memory / MEMORY.md** -- any workspace-level memory index file plus any topical files it points at.
- **Live-state files** -- STATUS.md, TODO.md, or similar workspace files if the project uses them.
- **Local-only override** -- `CLAUDE.local.md` (git-ignored, machine-specific).
- **Rules** -- `.claude/rules/*.md` if the project uses path-scoped rule files.
- **Resources** -- `.claude/resources/*.md` if the project keeps task-triggered reference docs.
- **Repo-level CLAUDE.md** files in any repo touched during the session.

If the project only has a single CLAUDE.md, that's fine. The audit adapts.

## Step 2: Scan the conversation

Walk the full conversation top to bottom. Look for four signal types.

### A. Corrections

The user fixed something Claude produced -- changed wording, rejected an approach, said "no, do it this way instead." Each correction reveals an underlying rule.

**Ask:** what preference or rule drove this change?

**Example:** User changed "refactor the whole module" to "just the one function". Rule: "Prefer surgical changes; don't expand scope without asking."

### B. Explicit preferences

Direct instructions: "always", "never", "I prefer", "from now on", "don't do that", "stop doing X".

**Example:** "Stop summarizing what you just did at the end of every response."

### C. Decisions

Choices that affect future work -- stack choice, schema decision, project direction, timeline, scope resolution.

**Example:** "Let's use Biome instead of Prettier across the portfolio repos."

### D. New context

Facts about the user, their work, or the world that weren't in any loaded file -- contact details, schedules, relationships, project status, tool changes.

**Example:** "The API token is in the env as `FOO_TOKEN`, not in settings.json."

## Step 3: Filter against what's already saved

For each finding from Step 2, grep the loaded files from Step 1. Skip anything already captured. Only surface genuinely new findings.

## Step 4: Route each finding

Two routing tests:

- **Test 1: Does it prescribe behavior?** ("always", "never", "before X do Y") -> goes to CLAUDE.md (project or user-global) or a matching `.claude/rules/` file.
- **Test 2: Does it describe a fact about the world that could change?** (repo status, PR state, stack choice) -> goes to STATUS.md or memory.

Finer routing:

| Finding kind | Target file |
| --- | --- |
| Global preference (applies to every project) | `~/.claude/CLAUDE.md` |
| Project-wide rule (always-on) | user-level `~/.claude/rules/` (if global rules live there), project `.claude/rules/`, or project CLAUDE.md |
| Path-scoped rule | new or existing file in `.claude/rules/` with `paths:` frontmatter |
| Cross-session fact about the user | new or existing memory topic file + index entry |
| Live repo state | `STATUS.md` |
| Backlog idea | `TODO.md` |
| Voice / output convention | `.claude/resources/voice-principles.md` or similar |
| Repo-specific behavior | that repo's own `CLAUDE.md` |

If the project doesn't have this exact layout, route to whatever's closest. Ask the user if ambiguous.

## Step 5: Present findings

Format each one:

```text
[N]. <what happened in one sentence>

- Rule/fact: <exact wording to save>
- Where it goes: <file path + section>
- Why: <one sentence on why it matters for future sessions>
```

Group into:

- **Recommend (apply unless you object):** clear-cut findings with an obvious home.
- **Your call:** judgment calls or findings that could fit two places.

If there are no findings: `Clean session. Nothing new to capture.` Don't manufacture findings.

## Step 6: Apply approved changes

After the user approves (all, some, or none), write the approved entries to target files. For each write, print:

```text
Saved to <path>: "<the line as written>"
```

If a target file does not exist yet (new memory topic, for example), create it with minimal frontmatter and add the index entry.

## Hard rules

- **Never write without approval.** Always present findings first, wait, then apply.
- **Never save secrets.** If a finding contains a token, API key, or credential, flag it and refuse -- suggest storing in a credential manager and referencing by variable name.
- **Never duplicate.** If something is already in the loaded files, skip it even if re-stated.
- **Never make up facts.** Only capture things the user said in this session. Do not infer or extrapolate.
- **Never rewrite the user's words without showing the rewrite.** If condensing a correction into a rule, show the rewritten version for approval first.
