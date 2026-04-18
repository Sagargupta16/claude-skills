---
name: context-management
description: Use when managing Claude Code context window during long sessions, when context feels degraded, or when deciding between /compact, /clear, /rewind, and sub-agents. Covers context rot detection, compaction timing, branching strategy, and sub-agent isolation patterns.
---

# Context Management

## Quick Reference

| Signal | Action |
|--------|--------|
| At ~50% context usage | Manual `/compact` with focus instructions |
| Approach fails, output quality drops | `/rewind` to before the failed attempt |
| New unrelated task mid-session | `/clear` or start new session |
| Need to explore/research | Spawn sub-agent (keeps main context clean) |
| Over 300K tokens used | Strongly consider new session |
| Auto-compact triggered | Too late -- quality already degraded |

## Context Rot

Context rot is the gradual degradation of output quality as the context window fills up. It typically starts around 300-400K tokens (on 1M token models), but varies by task complexity.

### Symptoms
- Claude repeats previous mistakes or ignores corrections
- Output becomes more generic, less project-specific
- Instructions from CLAUDE.md start being ignored
- Code patterns drift from established conventions

### Prevention
1. **Manual compact at 50%** -- don't wait for auto-compaction
2. **Use sub-agents** for exploration tasks (research stays in child context, only results bubble up)
3. **New session for new tasks** -- don't carry unrelated context
4. **Focus compaction**: `/compact "keep only the auth implementation details and test results"`

## Branching Strategy

Every turn in a Claude Code session is a branching point. Choose deliberately:

```
Current turn outcome:
├── Good result → Continue (carry all context forward)
├── Mediocre result → Two options:
│   ├── /rewind (drop the attempt, retry clean)
│   └── Correct in context (adds noise, sometimes fine for small fixes)
├── Bad result / wrong direction → /rewind (always)
├── Task complete, new task → /clear or new session
└── Need deep research → Spawn sub-agent
```

### /rewind vs Correct In Context

| Scenario | Use /rewind | Correct in context |
|----------|------------|-------------------|
| Wrong approach entirely | Yes | No |
| Small typo or missed detail | No | Yes |
| Generated wrong file | Yes | No |
| Right idea, minor adjustment | No | Yes |
| Multiple failed attempts | Yes (go back further) | No |

## Compaction

### When to Compact

- **Good time**: ~50% context usage, between logical task boundaries
- **Bad time**: Mid-implementation, during debugging, during a complex multi-step plan

### How to Compact Well

```
# BAD: no guidance
/compact

# GOOD: focused compaction with retention instructions
/compact "Keep: current implementation plan steps 3-7, test results from auth module, the API schema we agreed on. Drop: exploration of rejected approaches, file reads from unrelated modules."
```

### Compaction vs Clear vs New Session

| Method | Preserves | Loses | Best For |
|--------|-----------|-------|----------|
| `/compact` | Summary of work, key decisions | Details, exact code snippets | Mid-task context reduction |
| `/clear` | Nothing (clean slate) | Everything | Starting fresh task in same session |
| New session | Nothing | Everything | Completely new task or severely degraded context |

## Sub-Agent Isolation

Use sub-agents to keep the main context window clean:

| Task Type | Use Sub-Agent? | Why |
|-----------|---------------|-----|
| File exploration / grep | Yes | Search results are bulky, only need the answer |
| Code review | Yes | Review details stay in child, summary comes back |
| Research / investigation | Yes | Exploration paths stay isolated |
| Implementation | No | Need to see and verify the changes |
| Debugging | Depends | Simple bug: no. Complex investigation: yes |

### Pattern: Research Then Implement

```
1. Spawn sub-agent: "Research how auth middleware works in this codebase"
2. Get summary back (main context stays clean)
3. Implement based on summary (in main context where you can verify)
```

## Anti-Patterns

| Anti-Pattern | Problem | Do Instead |
|-------------|---------|-----------|
| Never compacting | Context fills up, quality degrades silently | Compact at ~50% usage |
| Compacting too often | Lose important context | Compact at natural boundaries |
| Waiting for auto-compact | Model is least intelligent during auto-compact | Manual compact before it triggers |
| Saying "no try again" after bad output | Failed attempt stays in context, pollutes future attempts | /rewind then re-prompt |
| Reading every file "just in case" | Wastes context on irrelevant content | Search first, read only what's needed |
| Running all research in main context | Exploration results bloat context | Use sub-agents for research |
| Continuing after multiple failures | Context is poisoned with failed approaches | /clear or new session |
