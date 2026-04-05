---
name: refactoring
description: Use when restructuring code without changing behavior -- extracting functions, renaming, moving files, reducing duplication, migrating between patterns (JS to TS, CJS to ESM), or addressing code smells. Covers safe refactoring workflows for any language.
---

# Refactoring Patterns

## Quick Reference

| Task | Approach |
|------|----------|
| Extract function/method | Identify repeated or complex block, extract with clear name |
| Rename safely | Find all references first, rename, run tests |
| Move file/module | Update all imports, check for re-exports, run tests |
| Reduce duplication | Extract shared logic only when used 3+ times |
| Migrate JS -> TS | File by file, start with strictest config, add types gradually |
| Migrate CJS -> ESM | Update require/module.exports to import/export, fix package.json |
| Simplify conditionals | Replace nested if/else with early returns or guard clauses |

## Safe Refactoring Workflow

1. **Verify tests pass** before touching anything
2. **Make one change at a time** -- don't combine refactors
3. **Run tests after each change** to catch regressions immediately
4. **Commit frequently** -- each refactor step gets its own commit
5. **Never mix refactoring with behavior changes** in the same commit

## Code Smell Detection

| Smell | Symptom | Refactoring |
|-------|---------|-------------|
| Long function | > 30 lines or does multiple things | Extract method |
| Duplicate code | Same logic in 3+ places | Extract shared function |
| Deep nesting | > 3 levels of if/for/try | Early returns, extract helper |
| Long parameter list | > 4 parameters | Introduce parameter object |
| Feature envy | Method uses another class's data more than its own | Move method |
| God class/module | One file does everything | Split by responsibility |
| Dead code | Unreachable or unused code | Delete it |
| Primitive obsession | Raw strings/ints for domain concepts | Introduce value types |
| Shotgun surgery | One change requires editing many files | Consolidate related logic |
| Middle man | Class that only delegates | Remove and call directly |

## Extract Patterns

### Extract Function

Before:
```python
def process_order(order):
    # validate
    if not order.items:
        raise ValueError("Empty order")
    if order.total < 0:
        raise ValueError("Negative total")
    # calculate tax
    tax = order.total * 0.08
    if order.state == "CA":
        tax = order.total * 0.0975
    order.tax = tax
    order.final_total = order.total + tax
```

After:
```python
def process_order(order):
    validate_order(order)
    order.tax = calculate_tax(order.total, order.state)
    order.final_total = order.total + order.tax

def validate_order(order):
    if not order.items:
        raise ValueError("Empty order")
    if order.total < 0:
        raise ValueError("Negative total")

def calculate_tax(total: float, state: str) -> float:
    if state == "CA":
        return total * 0.0975
    return total * 0.08
```

### Replace Nested Conditionals with Guard Clauses

Before:
```python
def get_payment(employee):
    if employee.is_active:
        if employee.is_full_time:
            if employee.years > 5:
                return employee.salary * 1.1
            else:
                return employee.salary
        else:
            return employee.hourly_rate * employee.hours
    else:
        return 0
```

After:
```python
def get_payment(employee):
    if not employee.is_active:
        return 0
    if not employee.is_full_time:
        return employee.hourly_rate * employee.hours
    if employee.years > 5:
        return employee.salary * 1.1
    return employee.salary
```

### Introduce Parameter Object

Before:
```typescript
function createUser(name: string, email: string, age: number, role: string, team: string) { ... }
```

After:
```typescript
interface CreateUserParams {
  name: string;
  email: string;
  age: number;
  role: string;
  team: string;
}

function createUser(params: CreateUserParams) { ... }
```

## Migration Patterns

### JavaScript to TypeScript

1. Rename `.js` to `.ts` (one file at a time, start with leaf modules)
2. Add `tsconfig.json` with strict mode
3. Fix type errors -- add types to function signatures first
4. Use `unknown` over `any` when the type is genuinely unclear
5. Run tests after each file migration

### CommonJS to ESM

| CJS | ESM |
|-----|-----|
| `const x = require('x')` | `import x from 'x'` |
| `const { a } = require('x')` | `import { a } from 'x'` |
| `module.exports = x` | `export default x` |
| `module.exports.a = a` | `export { a }` |
| `__dirname` | `import.meta.dirname` (Node 21+) or `fileURLToPath` |
| `__filename` | `import.meta.filename` (Node 21+) or `fileURLToPath` |

Also update `package.json`: add `"type": "module"`.

### Class to Functional (React)

| Class | Functional |
|-------|-----------|
| `this.state` / `setState` | `useState` |
| `componentDidMount` | `useEffect(..., [])` |
| `componentDidUpdate` | `useEffect(..., [deps])` |
| `componentWillUnmount` | `useEffect` cleanup return |
| `this.props` | Function parameters |
| `shouldComponentUpdate` | `React.memo` |

## Safe Rename Workflow

1. **Search all references** -- grep for the name across the codebase
2. **Check for dynamic usage** -- string-based lookups, reflection, config files
3. **Rename in all locations** -- source, tests, docs, configs
4. **Update imports/exports** -- especially re-exports from index files
5. **Run full test suite**
6. **Commit with descriptive message**: `refactor: rename X to Y for clarity`

## When NOT to Refactor

| Situation | Why |
|-----------|-----|
| Code is being deleted soon | Wasted effort |
| No tests exist for the code | Refactor tests first, then code |
| Mixed with a feature change | Do separately -- refactor first, then add feature |
| "While I'm here" improvements | Stay focused on the task at hand |
| Premature abstraction | Wait until pattern repeats 3+ times |

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Refactor and change behavior in one commit | Separate commits: refactor first, then change behavior |
| Extract a helper used only once | Inline is fine for single-use code |
| Create deep abstraction hierarchies | Prefer composition and flat structures |
| Rename without searching all references | Grep the entire codebase first |
| Refactor without passing tests | Fix or write tests first |
| "Clean up" code you're not working on | Only refactor code related to your current task |
