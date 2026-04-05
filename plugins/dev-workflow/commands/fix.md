---
description: Analyze and fix a bug from error messages or unexpected behavior
user_invocable: true
---

Analyze and fix the bug described by the user or found in recent error output.

Steps:
1. Understand the bug:
   - Read any error messages or stack traces provided
   - Identify the failing file and line number
   - Read the relevant source code
2. Find root cause:
   - Trace the execution path
   - Check recent git changes that might have introduced it (`git log --oneline -10`)
   - Look for related tests
3. Implement the fix:
   - Make the minimal change needed
   - Don't refactor surrounding code
   - Don't add unrelated improvements
4. Verify:
   - Run relevant tests if they exist
   - Check that the fix doesn't break other things
5. Show what was changed and why

$ARGUMENTS
