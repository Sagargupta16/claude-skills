# Refactoring Plugin

Safe code refactoring workflows, code smell detection, and migration patterns.

## Skills

- **refactoring**: Code smell detection table, extract/rename/move patterns, guard clauses, parameter objects, migration strategies (JS->TS, CJS->ESM, class->functional), and safe refactoring workflow.

## Commands

| Command | Description |
|---------|-------------|
| `/refactor` | Identify code smells and apply safe refactorings with test verification |

## Agents

| Agent | Model | Description |
|-------|-------|-------------|
| `refactorer` | sonnet | Systematic multi-file refactoring -- renames, extractions, and pattern migrations |

## Example

```
> /refactor src/services/

Analyzing 4 files...

| File              | Smell            | Suggestion              |
|-------------------|------------------|-------------------------|
| order_service.py  | Long function    | Extract calculate_tax() |
| order_service.py  | Deep nesting     | Guard clauses           |
| user_service.py   | Duplicate code   | Extract validate_email  |
| utils.py          | Dead code        | Remove unused parse_v1  |

Apply these refactorings? (Tests will run after each change)
```

## Installation

```
/plugin install refactoring@sagar-dev-skills
```
