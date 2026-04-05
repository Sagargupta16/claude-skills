---
description: Review the current branch's changes for quality, bugs, and best practices
user_invocable: true
---

Review the current branch's changes for quality, bugs, and best practices.

Steps:
1. Run `git diff main...HEAD` (or appropriate base branch) to see all changes
2. For each changed file, analyze:
   - Logic errors or bugs
   - Security vulnerabilities (injection, XSS, secrets exposure)
   - Performance issues
   - Error handling gaps
   - Code style consistency
3. Check test coverage - are new functions tested?
4. Check for:
   - Hardcoded values that should be configurable
   - Missing input validation at boundaries
   - Race conditions or async issues
   - Breaking changes to public APIs
5. Provide a summary with:
   - Overall assessment (ship it / needs changes / major issues)
   - Specific issues with file:line references
   - Suggested fixes for each issue
