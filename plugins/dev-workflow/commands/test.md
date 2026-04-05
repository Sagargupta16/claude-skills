---
description: Detect the project's test framework and run the test suite
user_invocable: true
---

Detect the project's test framework and run the test suite.

Steps:
1. Check for test configuration:
   - `package.json` (scripts.test) -> npm/yarn/pnpm test
   - `pytest.ini` / `pyproject.toml` / `setup.cfg` -> pytest
   - `Cargo.toml` -> cargo test
   - `go.mod` -> go test ./...
   - `Makefile` -> check for test target
2. Run the tests
3. If tests fail:
   - Parse the error output
   - Identify the failing test and root cause
   - Show the specific assertion or error
   - Suggest a fix (but don't auto-fix unless asked)
4. Report summary: X passed, Y failed, Z skipped
