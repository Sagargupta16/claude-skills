---
description: Generate a handoff summary for the current session to pass to the next session
user_invocable: true
---

Generate a concise handoff summary for the current session:

1. Review what was accomplished in this session
2. Identify what's left to do (specific files, specific next steps)
3. List key decisions made and their rationale
4. Note any gotchas, traps, or non-obvious findings
5. Report current state: tests, build, PR, branch

Format the summary as:

```
## Session Summary

**Done**: [What was completed]

**Next**: [Specific remaining tasks with file paths]

**Decisions**: [Key choices and why]

**Gotchas**: [Non-obvious issues discovered]

**State**: [Tests/build/PR/branch status]
```

This summary should be self-contained enough that a new session can pick up immediately without re-reading the entire codebase.
