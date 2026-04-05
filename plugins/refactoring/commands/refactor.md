---
description: Identify code smells and apply safe refactoring with tests verification
user_invocable: true
---

Analyze code for refactoring opportunities and apply safe transformations.

Steps:
1. Run tests to establish a passing baseline
2. Identify the target: user-specified files or `git diff --name-only` for recent changes
3. Read the target code and identify code smells (long functions, duplication, deep nesting, etc.)
4. Present findings as a table: location, smell, suggested refactoring
5. If user approves, apply refactorings one at a time:
   - Make one change
   - Run tests to verify no regression
   - Commit the change
6. Never combine refactoring with behavior changes

Do NOT refactor code unrelated to the user's task. Present the plan before making changes.
