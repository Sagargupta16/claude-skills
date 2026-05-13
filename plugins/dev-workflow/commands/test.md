---
description: Detect the project's test framework and run the test suite
user_invocable: true
---

## Live state

- Detection: !`ls -1 package.json pyproject.toml pytest.ini setup.cfg Cargo.toml go.mod Makefile 2>/dev/null`
- package.json scripts: !`jq -r '.scripts // {} | to_entries | map("\(.key): \(.value)") | .[]' package.json 2>/dev/null | head -10 || echo "no package.json"`

## Task

Using the detection above, run the project's test suite.

Framework mapping:
- `package.json` with `scripts.test` -> `pnpm test` (preferred), else `npm test` or `yarn test`
- `pytest.ini` / `pyproject.toml [tool.pytest]` / `setup.cfg` -> `pytest -v` (or `uv run pytest -v` if `uv.lock` exists)
- `Cargo.toml` -> `cargo test`
- `go.mod` -> `go test ./...`
- `Makefile` with `test:` target -> `make test`

If tests fail:
1. Parse the failing test name and root-cause line.
2. Show the specific assertion or error message.
3. Classify: is the failure in code we just changed, or pre-existing?
4. Suggest a minimal fix. Do not auto-fix unless the user asked.

Report: `X passed, Y failed, Z skipped` and whether failures are new or pre-existing.
