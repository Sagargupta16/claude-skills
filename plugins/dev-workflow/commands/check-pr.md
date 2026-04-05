---
description: Check a PR's CI status, reviews, comments, and merge readiness
user_invocable: true
---

Check the status of a PR - CI checks, reviews, comments, and merge readiness.

Steps:
1. Get PR details: `gh pr view $ARGUMENTS --json state,mergeable,reviewDecision,statusCheckRollup,comments,reviews`
2. Check CI status - list all checks and their pass/fail status
3. Check review status - approved, changes requested, or pending
4. Read any new comments or review feedback
5. If there are failures:
   - Fetch the failed check logs
   - Identify the root cause
   - Suggest fixes
6. Provide a clear summary:
   - PR state (open/closed/merged)
   - CI status (all green / X failing)
   - Review status
   - Action items if any

$ARGUMENTS
