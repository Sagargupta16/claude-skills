---
description: Create a Dockerfile and docker-compose.yml for the current project
user_invocable: true
---

Create Docker configuration for the current project.

Steps:
1. Detect project type and runtime:
   - `package.json` -> Node.js (check for build script, framework)
   - `requirements.txt` / `pyproject.toml` -> Python (check for FastAPI, Flask, Django)
   - `Cargo.toml` -> Rust
   - `go.mod` -> Go
   - Static HTML/CSS/JS -> Nginx
2. Check for existing Docker files:
   - If `Dockerfile` exists, review and suggest improvements
   - If not, generate using docker-deploy skill templates
3. Generate files:
   - `Dockerfile` (multi-stage build, non-root user, optimized layers)
   - `.dockerignore` (exclude .git, .env, node_modules, etc.)
   - `docker-compose.yml` (dev setup with database if needed)
4. If the project uses a database, add the appropriate service:
   - MongoDB, PostgreSQL, MySQL, Redis
   - Include health checks and persistent volumes
5. Show generated files for review before writing
6. Verify with `docker compose config` if Docker is available

Use the docker-deploy skill for all patterns and best practices.
