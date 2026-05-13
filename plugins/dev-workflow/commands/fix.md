---
description: Analyze and fix a bug from error messages or unexpected behavior
user_invocable: true
---

## Live state

- Branch: !`git rev-parse --abbrev-ref HEAD`
- Recent changes: !`git log --oneline -10`
- Uncommitted diff: !`git diff`

## Task

Fix the bug described in `$ARGUMENTS` (or the most recent error output in the conversation).

Process:
1. **Parse the symptom.** Read any stack trace bottom-up. Identify the exact file and line of the crash.
2. **Root-cause, not symptom.** The crash site is often downstream of the real bug. Trace backwards:
   - Where did the bad data originate?
   - What contract was violated?
   - Does a recent commit in the log above correlate?
3. **Minimal fix.** Change only what's needed at the true root cause. Do not refactor adjacent code. Do not add unrelated improvements.
4. **Verify.** Run the narrowest test that covers this behavior. If no test exists, write one that would have caught the bug.
5. **Report.**

## Output

```text
SYMPTOM: <what breaks>
ROOT CAUSE: <file:line -- why>
FIX: <diff or summary>
VERIFICATION: <test run, pass/fail>
CONFIDENCE: <high | medium | low>
```

If confidence is low, list alternative hypotheses before applying.

$ARGUMENTS
