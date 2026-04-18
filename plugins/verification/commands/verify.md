---
description: Run pre-completion verification checklist for the current changes
user_invocable: true
---

Run verification checks before claiming work is complete:

1. Detect the project type and change type from recent modifications
2. Run the appropriate verification checklist:
   - **Backend**: Check if server starts, test endpoints, check logs
   - **Frontend**: Check if dev server starts, test in browser if possible
   - **Tests**: Run the test suite, report pass/fail/skip counts
   - **Build**: Run the build command, verify it succeeds
   - **Types**: Run type checker if configured
   - **Lint**: Run linter if configured
3. Check for committed secrets or sensitive data in staged changes
4. Verify git state: correct branch, expected files changed
5. Report a summary:
   - GREEN: All checks pass, safe to proceed
   - YELLOW: Some checks need attention (list them)
   - RED: Blocking issues that must be fixed
