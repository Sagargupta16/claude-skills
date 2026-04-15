# Docker Deploy Plugin

Docker best practices, Dockerfile templates, and compose patterns for development and production.

## Skills

- **docker-deploy**: Multi-stage Dockerfiles for Python, Node.js, Go, and Rust. Compose patterns for dev/prod, image optimization, health checks, signal handling, and security hardening.

## Commands

| Command | Description |
|---------|-------------|
| `/dockerize` | Detect project type and generate Docker configuration |

## Agents

| Agent | Model | Description |
|-------|-------|-------------|
| `dockerfile-optimizer` | haiku | Analyzes Dockerfiles for image size, build speed, and security improvements |

## Example

```
> /dockerize

Detected: Python (FastAPI) from main.py + requirements.txt
Generated:
  Dockerfile          (multi-stage, python-slim, non-root user)
  docker-compose.yml  (MongoDB + backend, health checks)
  .dockerignore       (excludes .env, .git, __pycache__)
```

## Installation

```
/plugin install docker-deploy@sagar-dev-skills
```
