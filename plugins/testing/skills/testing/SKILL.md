---
name: testing
description: Use when writing tests, choosing test strategies, setting up test frameworks, or improving test coverage. Covers pytest, jest/vitest, go test, cargo test, mocking patterns, fixture design, and coverage thresholds.
---

# Testing Patterns

## Quick Reference

| Task | Approach |
|------|----------|
| Choose framework | Detect from config files (see table below) |
| Write unit tests | One test file per source file, test public API |
| Write integration tests | Separate directory, real dependencies where possible |
| Mock external deps | Only mock what you don't own (APIs, services) |
| Coverage target | 80%+ for business logic, skip generated code |
| Name tests | `test_<behavior>_<scenario>_<expected>` |

## Framework Detection

| Config File | Framework | Run Command |
|------------|-----------|-------------|
| `pytest.ini` / `pyproject.toml` [tool.pytest] | pytest | `pytest` |
| `package.json` (vitest) | vitest | `npx vitest` |
| `package.json` (jest) | jest | `npx jest` |
| `go.mod` | go test | `go test ./...` |
| `Cargo.toml` | cargo test | `cargo test` |
| `mix.exs` | ExUnit | `mix test` |

## Test Organization

```
tests/                      # or __tests__/, spec/, *_test.go
├── unit/                   # Fast, isolated, no I/O
│   ├── test_models.py
│   └── test_utils.py
├── integration/            # Real DB, real filesystem
│   └── test_api.py
├── conftest.py             # Shared fixtures (pytest)
└── fixtures/               # Test data files
    └── sample_response.json
```

One test file per source file. Mirror the source directory structure.

## pytest Patterns

### Fixtures

```python
import pytest

@pytest.fixture
def sample_user():
    """Create a test user with default values."""
    return {"name": "Test User", "email": "test@example.com"}

@pytest.fixture
def db_session(tmp_path):
    """Provide a temporary database session."""
    db = create_engine(f"sqlite:///{tmp_path}/test.db")
    yield Session(db)
    db.dispose()
```

Use `conftest.py` for shared fixtures. Keep fixtures close to where they're used -- don't put everything in a root conftest.

### Parametrize

```python
@pytest.mark.parametrize("input_val,expected", [
    ("hello", "HELLO"),
    ("", ""),
    ("123", "123"),
    ("Hello World", "HELLO WORLD"),
])
def test_to_upper(input_val, expected):
    assert to_upper(input_val) == expected
```

### Markers

```python
@pytest.mark.slow          # Skip with: pytest -m "not slow"
@pytest.mark.integration   # Run with: pytest -m integration
@pytest.mark.db_test       # Tests requiring database
```

Register custom markers in `pyproject.toml`:
```toml
[tool.pytest.ini_options]
markers = [
    "slow: marks tests as slow",
    "integration: integration tests",
]
```

### Async Tests

```python
import pytest

@pytest.mark.asyncio
async def test_fetch_data(httpx_mock):
    httpx_mock.add_response(json={"status": "ok"})
    result = await fetch_data("https://api.example.com")
    assert result["status"] == "ok"
```

Requires `pytest-asyncio` and `pytest-httpx`.

## jest / vitest Patterns

### Basic Structure

```typescript
import { describe, it, expect, beforeEach } from "vitest";

describe("UserService", () => {
  let service: UserService;

  beforeEach(() => {
    service = new UserService();
  });

  it("creates a user with valid data", () => {
    const user = service.create({ name: "Test", email: "t@t.com" });
    expect(user.id).toBeDefined();
    expect(user.name).toBe("Test");
  });

  it("throws on invalid email", () => {
    expect(() => service.create({ name: "Test", email: "bad" }))
      .toThrow("Invalid email");
  });
});
```

### Mocking

```typescript
import { vi } from "vitest";

// Mock a module
vi.mock("./api-client", () => ({
  fetchUser: vi.fn().mockResolvedValue({ id: 1, name: "Mock User" }),
}));

// Spy on a method
const spy = vi.spyOn(service, "save");
await service.create(data);
expect(spy).toHaveBeenCalledWith(expect.objectContaining({ name: "Test" }));
```

### Snapshot Testing

```typescript
it("renders correctly", () => {
  const result = render(<UserCard user={mockUser} />);
  expect(result).toMatchSnapshot();
});
```

Use snapshots sparingly -- they're brittle and easy to blindly update.

## Go Test Patterns

### Table-Driven Tests

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive", 2, 3, 5},
        {"zero", 0, 0, 0},
        {"negative", -1, 1, 0},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Add(tt.a, tt.b)
            if got != tt.expected {
                t.Errorf("Add(%d, %d) = %d, want %d", tt.a, tt.b, got, tt.expected)
            }
        })
    }
}
```

### Test Helpers

```go
func setupTestDB(t *testing.T) *sql.DB {
    t.Helper()
    db, err := sql.Open("sqlite3", ":memory:")
    if err != nil {
        t.Fatal(err)
    }
    t.Cleanup(func() { db.Close() })
    return db
}
```

## Cargo Test Patterns

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(2, 3), 5);
    }

    #[test]
    #[should_panic(expected = "divide by zero")]
    fn test_divide_by_zero() {
        divide(1, 0);
    }
}
```

Integration tests go in `tests/` directory at crate root (separate compilation unit).

## Mocking Strategy

| What to Mock | When | Tool |
|-------------|------|------|
| External HTTP APIs | Always | httpx_mock, msw, httpmock |
| Database | Integration: real DB. Unit: mock repo layer | testcontainers, sqlite in-memory |
| File system | Use tmp directories | tmp_path (pytest), os.TempDir (Go) |
| Time/clock | When testing time-dependent logic | freezegun, vi.useFakeTimers |
| Internal modules | Rarely -- prefer real implementations | Only at module boundaries |

**Rule: only mock what you don't own.** If you wrote the code, use the real implementation. Mock external services, APIs, and infrastructure.

## Coverage

### Running Coverage

| Framework | Command |
|-----------|---------|
| pytest | `pytest --cov=src --cov-report=term-missing` |
| vitest | `npx vitest --coverage` |
| jest | `npx jest --coverage` |
| go | `go test -coverprofile=cover.out ./... && go tool cover -func=cover.out` |
| cargo | `cargo tarpaulin` (requires cargo-tarpaulin) |

### What to Cover

- Business logic and domain rules: 80%+
- API endpoint handlers: test happy path + error cases
- Utility functions: 90%+ (they're easy to test)
- Generated code, type definitions, config: skip

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Test implementation details | Test behavior and public API |
| One giant test per function | Small focused tests, one assertion concept each |
| Mock everything | Only mock external dependencies |
| Skip error case tests | Test both happy path and failure modes |
| Copy-paste test setup | Use fixtures / helpers / beforeEach |
| Use random data without seeds | Use deterministic test data or seeded randoms |
| Test framework internals | Trust the framework, test your code |
| Write tests after the fact only | Write tests alongside or before implementation |
