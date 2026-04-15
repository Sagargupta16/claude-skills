# FARM Stack Plugin

FastAPI + React + MongoDB (FARM stack) development patterns and project scaffolding.

## Skills

- **farm-stack**: Project structure, async MongoDB with Motor, Pydantic v2 models, dual-layer config, Docker setup, and testing conventions.

## Commands

| Command | Description |
|---------|-------------|
| `/scaffold-farm` | Scaffold a complete FARM project with all boilerplate files |

## Agents

| Agent | Model | Description |
|-------|-------|-------------|
| `farm-scaffolder` | sonnet | Scaffolds FARM stack components -- CRUD endpoints, React pages, MongoDB models |

## Example

```
> /scaffold-farm my-app

Created project structure:
  my-app/main.py           (FastAPI entry with lifespan)
  my-app/config/            (env + YAML config loader)
  my-app/models/            (Pydantic v2 base models)
  my-app/routes/            (API router stubs)
  my-app/services/          (async MongoDB service layer)
  my-app/docker-compose.yml (MongoDB + backend)
  my-app/.env.example
  my-app/Makefile
```

## Installation

```
/plugin install farm-stack@sagar-dev-skills
```
