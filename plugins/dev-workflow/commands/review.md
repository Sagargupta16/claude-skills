---
description: Review the current branch's changes for quality, bugs, and best practices
user_invocable: true
---

## Live state

- Branch: !`git rev-parse --abbrev-ref HEAD`
- Base detection: !`git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || echo "no main base found"`
- Changed files: !`git diff $(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null)...HEAD --stat`
- Full diff: !`git diff $(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null)...HEAD`

## Task

Review the diff above for quality, bugs, and best practices.

Per changed file, look for:
- Logic errors, off-by-one, null handling, race conditions
- Security: injection (SQL/XSS/command), hardcoded secrets, missing input validation, insecure deserialization
- Performance: N+1 queries, unbounded loops, missing indexes, memory leaks
- Error handling at boundaries; silent exception swallowing
- Hardcoded values that should be configurable
- Breaking changes to public APIs

Check test coverage: are new functions or branches tested?

## Output

```text
SUMMARY: <ship-it | needs-changes | major-issues>

[SEVERITY] file:line -- description
  Fix: <one-line suggestion>
```

Severity: `CRITICAL | HIGH | MEDIUM | LOW | STYLE`. Report only real findings; say "no issues" if the diff is clean.
