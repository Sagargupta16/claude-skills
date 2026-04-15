# Testing Plugin

Test strategy, framework-specific patterns, and coverage guidance for multi-language projects.

## Commands

| Command | Description |
|---------|-------------|
| `/write-tests` | Analyze code and generate tests with the appropriate framework |

## Skills

- **testing**: Framework detection, test organization, fixture patterns, mocking strategies, coverage targets, and anti-patterns for pytest, jest/vitest, go test, and cargo test.

## Agents

| Agent | Model | Description |
|-------|-------|-------------|
| `test-runner` | haiku | Detects test framework, runs tests, and reports results with failure analysis |
| `test-generator` | sonnet | Generates unit tests matching project patterns, covering happy paths, errors, and edge cases |

## Example

```
> /write-tests src/services/user_service.py

Detected pytest from pyproject.toml.
Found existing tests in tests/test_user_service.py (3 tests).
Adding 5 new tests:
  - test_create_user_with_valid_data
  - test_create_user_duplicate_email_raises
  - test_get_user_not_found_returns_none
  - test_update_user_partial_fields
  - test_delete_user_removes_from_db
All 8 tests passing. Coverage: 87%
```

## Installation

```
/plugin install testing@sagar-dev-skills
```
