---
name: session-management
description: Use when deciding whether to continue a session or start fresh, when handing off work between sessions, or when managing long-running development tasks across multiple Claude Code sessions. Covers session lifecycle, handoff summaries, and session hygiene.
---

# Session Management

## Quick Reference

| Decision | Recommendation |
|----------|---------------|
| New unrelated task | New session |
| Continuing same feature | Continue or resume (`-c` / `-r`) |
| Context feels degraded | New session with handoff summary |
| Multiple failed approaches | /clear or new session |
| Coming back after hours | New session, re-read STATUS.md |
| Pair programming flow | Continue, compact at boundaries |

## Session Lifecycle

```
Start Session
├── Fresh start? → Read CLAUDE.md, STATUS.md, orient
├── Continuing work? → Resume with `-c` or session ID
│
├── Working...
│   ├── Natural boundary → Consider compact
│   ├── Task complete → Handoff summary, then new task or end
│   └── Context degraded → Handoff summary, new session
│
└── End Session
    └── Summarize state for future self
```

## When to Start a New Session

| Situation | New Session? | Why |
|-----------|-------------|-----|
| Different feature / bug | Yes | Avoid context pollution |
| Same feature, new day | Yes | Context from yesterday is stale |
| Context over 300K tokens | Yes | Quality degrades beyond this |
| Multiple /rewind attempts failed | Yes | Context is poisoned |
| Switching repos in workspace | Yes | Different conventions, different state |
| Quick follow-up on same work | No | Continue with `-c` |

## Handoff Summaries

When ending a session or handing off to a new one, create a summary:

### What to Include
- What was accomplished
- What's left to do (specific files, specific next steps)
- Key decisions made and why
- Any gotchas or traps discovered
- Current state of tests / build / PR

### Format
```
## Session Summary

**Done**: Implemented auth middleware in src/middleware/auth.ts, added JWT validation, wrote 12 tests (all passing).

**Next**: Wire up middleware to /api/admin/* routes, add refresh token endpoint, update API docs.

**Decisions**: Used jose library over jsonwebtoken (better ESM support). Access tokens expire in 15min, refresh in 7d.

**Gotchas**: The existing User model doesn't have a refreshToken field yet -- migration needed before refresh endpoint.

**State**: All tests green, build passes, no PR yet.
```

## Resume Patterns

### Continue Last Session
```bash
claude -c
```

### Resume Specific Session
```bash
claude -r "session-id" "Continue from where we left off"
```

### Start Fresh with Context
```bash
# Copy the handoff summary into the first message
claude
> "I'm continuing work on auth middleware. Here's where I left off: [paste summary]"
```

## Session Hygiene

### Do
- One logical task per session
- Compact at natural boundaries (between features, after debugging)
- Write handoff summaries before complex task switches
- Start sessions by reading current state (STATUS.md, git status)

### Don't
- Carry debugging context into feature work
- Resume week-old sessions (context is stale)
- Mix unrelated tasks in one session
- Skip orientation at session start

## Multi-Session Workflows

For large features that span multiple sessions:

```
Session 1: Plan
├── Analyze codebase
├── Write implementation plan
├── Save plan to file or PR description
└── Handoff: "Plan complete, ready for step 1"

Session 2: Implement Core
├── Read plan
├── Implement steps 1-3
├── Run tests
└── Handoff: "Steps 1-3 done, tests green, step 4 next"

Session 3: Implement Rest + Polish
├── Read plan + previous handoff
├── Implement steps 4-6
├── Full test suite + build
└── Handoff: "Implementation complete, ready for PR"

Session 4: Review + Ship
├── /review the changes
├── Fix review findings
├── Create PR
└── Done
```

## Anti-Patterns

| Anti-Pattern | Problem | Do Instead |
|-------------|---------|-----------|
| Never starting fresh | Stale context degrades quality | New session for new tasks |
| No handoff summaries | Future sessions lack context | Write summary at natural boundaries |
| Resuming ancient sessions | Context is outdated | Start fresh, reference old summary |
| Mixing 5 tasks in one session | Context pollution, confusion | One logical task per session |
| Skipping orientation | Miss recent changes by others | Read STATUS.md and git log first |
