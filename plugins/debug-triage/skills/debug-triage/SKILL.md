---
name: debug-triage
description: Use when triaging a pasted error, stack trace, or terminal transcript. Activates on "debug this", "fix this", "why is this broken", or when a user pastes red terminal output. Produces a tight cause-fix-test report, not a lecture.
allowed-tools: Read Grep Glob Bash(git log:*) Bash(git blame:*) Bash(git diff:*)
---

# debug-triage

## When to activate

- User pastes a terminal or PowerShell transcript containing an error.
- User pastes a stack trace.
- User says "debug", "fix this", "why is this broken", "what's going on here".

Do NOT activate for refactoring requests, feature work, or general code review -- those are separate tasks.

## Steps

1. **Parse the actual error.** Read stack traces bottom-up. The top frame is usually the symptom; the root cause is deeper in the stack or earlier in the log. Ignore generic first lines like "Traceback (most recent call last):" or "Uncaught Error".
2. **State the likely cause in one sentence.** Not a paragraph. "Null dereference on `user.profile` because the auth middleware returns `null` for unverified emails."
3. **Propose the fix as a diff or command.** Not prose. Either a code snippet showing before/after, or the exact shell command to run.
4. **Name a regression test.** Where it would live (`tests/auth/email_verify_test.py`), and what assertion would catch this bug next time. One line.
5. **Flag sibling updates.** If the fix changes behavior documented in README, CHANGELOG, or any doc file, list them. If not, say "none".

## Rules

- **Don't ask the user to reformat the paste.** Parse whatever they gave you.
- **Fix first, explain if asked.** Don't narrate what the error means at length.
- **Ambiguous errors:** if 2+ causes are equally likely, pick the likeliest and say so in one line. Do not dump all possibilities unless asked.
- **Recent changes are suspect.** Run `git log -5 --oneline -- <file>` on the failing file. If a recent commit touched the failing line, mention it.
- **Environment first.** If the error looks like it could be environmental (missing env var, wrong Node/Python version, CRLF line endings, path with spaces), check the environment before hypothesizing code bugs.

## Output

```text
Cause: <one line>
Fix: <diff or command>
Regression test: <path + what it asserts>
Siblings to update: <list or "none">
```

No preamble. Lead with `Cause:`.
