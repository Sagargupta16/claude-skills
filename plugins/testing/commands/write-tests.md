---
description: Analyze code and generate tests with appropriate framework and patterns
user_invocable: true
---

Generate tests for the specified code or most recently changed files.

Steps:
1. Detect the test framework from config files (package.json, pyproject.toml, Cargo.toml, go.mod)
2. Identify the target code to test:
   - If the user specified files, use those
   - Otherwise, check `git diff --name-only` for recently changed source files
3. Read the target source files and understand the public API
4. Check for existing tests -- extend rather than overwrite
5. Generate tests following the project's existing test patterns:
   - Match naming conventions, directory structure, and import style
   - Include happy path, error cases, and edge cases
   - Use existing fixtures/helpers where available
6. Write the test files
7. Run the tests to verify they pass
8. Report coverage if tooling is available

Do NOT generate tests for trivial getters/setters or type definitions. Focus on behavior and logic.
