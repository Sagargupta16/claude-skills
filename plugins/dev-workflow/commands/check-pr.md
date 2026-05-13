---
description: Check a PR's CI status, reviews, comments, and merge readiness
user_invocable: true
argument-hint: [pr-number-or-url]
---

## Live state

- PR details: !`gh pr view $ARGUMENTS --json state,mergeable,mergeStateStatus,isDraft,reviewDecision,statusCheckRollup,title,url 2>/dev/null || gh pr view --json state,mergeable,mergeStateStatus,isDraft,reviewDecision,statusCheckRollup,title,url 2>/dev/null || echo "no PR found"`
- Review comments: !`gh pr view $ARGUMENTS --json comments,reviews 2>/dev/null || gh pr view --json comments,reviews 2>/dev/null || echo ""`
- CI checks: !`gh pr checks $ARGUMENTS 2>/dev/null || gh pr checks 2>/dev/null || echo ""`

## Task

Using the live state above, produce a merge-readiness report.

1. **State**: open / closed / merged / draft.
2. **CI**: all green, or list failing checks with names and conclusions.
3. **Reviews**: approved / changes-requested / pending. Summarize any unaddressed review comments.
4. **Merge readiness**: `mergeStateStatus` interpretation -- `CLEAN`, `BEHIND` (needs rebase), `BLOCKED` (required checks), `DIRTY` (conflicts), `UNSTABLE` (non-required failures).
5. **If CI is failing**, fetch the failing run's log head and identify the root cause (test failure, lint, build error). Suggest a narrow fix.

## Output

```text
PR: <title> (#<num>)
State: <state>
CI: <all-green | N failing: ...>
Reviews: <status>
Merge: <ready | blocked: <reason>>
Action: <one line>
```

$ARGUMENTS
