---
name: verification
description: Use when completing a task, before claiming work is done, or before creating a PR. Enforces verification checklists for backend, frontend, infrastructure, and general code changes. Prevents premature completion claims.
---

# Verification Before Completion

## Quick Reference

| Change Type | Minimum Verification |
|-------------|---------------------|
| Backend API | Run server, hit endpoints, check responses |
| Frontend UI | Start dev server, test in browser, check edge cases |
| Database migration | Run migration, verify schema, test rollback |
| Infrastructure/IaC | Plan/validate, check for destructive changes |
| Bug fix | Reproduce bug, apply fix, confirm fix, check for regressions |
| Refactor | Run full test suite, verify behavior unchanged |
| Documentation | Build docs, check links, verify accuracy |

## The Rule

Never claim work is complete based solely on:
- Code looking correct
- Type checks passing
- Linter being clean
- Tests passing (tests verify code correctness, not feature correctness)

Always verify the actual feature works as intended.

## Backend Verification

```
1. Run the server / service
2. Hit affected endpoints (curl, httpie, or test client)
3. Check response status codes and bodies
4. Verify error cases return proper errors
5. Check logs for warnings or errors
6. Run the test suite
7. Check for N+1 queries or performance issues
```

### FastAPI Example
```bash
# Start server
uvicorn main:app --reload

# Test endpoint
curl -X POST http://localhost:8000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "test", "email": "test@example.com"}'

# Check error handling
curl -X POST http://localhost:8000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": ""}'  # should return 422

# Run tests
python -m pytest -v
```

## Frontend Verification

```
1. Start dev server
2. Navigate to affected pages
3. Test the golden path (happy path)
4. Test edge cases:
   - Empty state
   - Error state
   - Loading state
   - Long text / overflow
   - Mobile viewport
5. Check browser console for errors
6. Test keyboard navigation (accessibility)
7. Run test suite and build
```

### React/Vite Example
```bash
# Start dev server
pnpm dev

# In browser: test the feature manually
# Check console: no errors or warnings
# Test mobile: use responsive mode

# Run tests and build
pnpm test && pnpm build
```

## Database Migration Verification

```
1. Run migration forward
2. Verify schema matches expectations
3. Run migration backward (rollback)
4. Verify rollback is clean
5. Run migration forward again
6. Seed data if needed, verify queries work
7. Run application test suite
```

## Infrastructure Verification

```
1. Run terraform plan / cdk diff
2. Review changes -- especially destroys
3. Check for state drift
4. Verify no secrets in plan output
5. Apply to staging/dev first
6. Verify resources created correctly
7. Run smoke tests against new infrastructure
```

## Bug Fix Verification

```
1. Reproduce the original bug (confirm it exists)
2. Apply the fix
3. Verify the bug is fixed (same reproduction steps)
4. Check for regressions (related features still work)
5. Write a test that would have caught this bug
6. Run full test suite
```

## Pre-PR Checklist

Before creating a pull request:

| Check | Command |
|-------|---------|
| Tests pass | `pytest` / `pnpm test` / `go test ./...` |
| Build succeeds | `pnpm build` / `cargo build` |
| No type errors | `pyright` / `tsc --noEmit` |
| No lint warnings | `ruff check` / `eslint .` |
| No committed secrets | Search for API keys, tokens, passwords |
| Branch is up to date | `git fetch origin && git log origin/main..HEAD` |
| Changes are scoped | `git diff --stat` -- only expected files changed |

## Anti-Patterns

| Anti-Pattern | Problem | Do Instead |
|-------------|---------|-----------|
| "Tests pass so it works" | Tests verify code, not features | Test the actual feature manually |
| "It compiles so it's done" | Compilation != correctness | Run and verify behavior |
| "I checked the happy path" | Bugs hide in edge cases | Test error states, empty states, boundaries |
| Skipping verification for small changes | Small changes cause big bugs | Always verify, even one-liners |
| Only verifying in isolation | Integration issues missed | Test in context of the full application |
| Claiming done without running it | Most common failure mode | Run it, use it, then claim done |
