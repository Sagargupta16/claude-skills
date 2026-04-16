# Methodology Plugin

Structured development methodologies for disciplined, repeatable workflows.

## Skills

- **methodology**: Decision tree for choosing TDD, BDD, SDD, plan-driven, or context engineering approaches. Step-by-step processes and anti-patterns for each.

## Commands

| Command | Description |
|---------|-------------|
| `/methodology` | Choose and apply the right methodology for the current task |

## Agents

| Agent | Model | Description |
|-------|-------|-------------|
| `methodology-coach` | sonnet | Guides structured workflow execution -- TDD cycles, BDD scenarios, spec-driven contracts |

## Methodologies Covered

| Methodology | Key Idea | First Artifact |
|-------------|----------|---------------|
| TDD | Red-green-refactor cycle | Failing test |
| BDD | Behavior specifications | Gherkin scenarios |
| SDD | Contract-first development | OpenAPI/schema spec |
| Plan-Driven | Plan before coding | Numbered implementation plan |
| Context Engineering | Design what Claude knows | CLAUDE.md + progressive loading |

## Installation

```
/plugin install methodology@sagar-dev-skills
```
