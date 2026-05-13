# debug-triage

Paste an error. Get a cause-fix-test triage in four lines. No philosophical detour.

## What it does

Takes a stack trace, terminal transcript, or error message and returns:

```text
Cause: <one line>
Fix: <diff or command>
Regression test: <path + what it asserts>
Siblings to update: <list or "none">
```

## When it activates

- User pastes an error and says "debug", "fix this", "why is this broken".
- User pastes red terminal output.

## What it deliberately avoids

- No long explanation of what the error means. Fix first, explain only if asked.
- No reformatting requests. Parse whatever the user pasted.
- No listing every possible cause. If ambiguous, pick the likeliest and say so.
- No feature creep into refactoring or general code review.
