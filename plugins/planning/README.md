# planning

Implementation planning -- plan mode usage, interview-then-execute workflow, prototype over PRD approach, and plan review patterns for multi-file features.

## Components

| Type | Name | Description |
|------|------|-------------|
| Skill | planning | Planning methodology selection and execution |
| Command | `/plan` | Create a structured implementation plan |
| Agent | plan-reviewer | Review plan for completeness and correct ordering |

## Key Concepts

- **Decision tree**: <3 files = just do it, 3-5 files = lightweight plan, 5+ files = full plan mode
- **Interview-then-execute**: Have Claude ask clarifying questions, then plan in a new session
- **Prototype over PRD**: Build and iterate instead of writing long specs for uncertain requirements
- **Second opinion**: Start a new session to review your plan as a staff engineer

## Install

```bash
claude plugin add sagar-dev-skills/planning
```
