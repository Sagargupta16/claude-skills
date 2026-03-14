---
description: Scaffold a new FARM stack project with FastAPI + React + MongoDB
user_invocable: true
---

Scaffold a new FARM stack (FastAPI + React + MongoDB) project in the current directory.

Steps:
1. Ask for the project name and brief description
2. Create the full directory structure following the farm-stack skill patterns
3. Generate these files:
   - `main.py` with FastAPI app, CORS, lifespan, health check, static mount
   - `config/__init__.py` and `config/secrets_parser.py` with dual-layer config (env + YAML)
   - `config/secrets.yml.example` with MongoDB connection template
   - `.env.example` with all standard FARM env vars
   - `requirements.txt` with pinned FARM dependencies
   - `pyproject.toml` with ruff + pytest config
   - `Dockerfile` (python:3.13-alpine)
   - `docker-compose.yml` with MongoDB + backend services
   - `Makefile` with standard dev commands
   - `.gitignore` for Python projects
   - `README.md` with project description, setup, and usage
   - `LICENSE` (MIT)
   - Empty `models/__init__.py`, `routes/__init__.py`, `services/__init__.py`, `utils/__init__.py`, `tests/__init__.py`
   - `client/` directory with Vite + React scaffold (package.json, vite.config.js, src/main.jsx, src/App.jsx)
4. Initialize git repo if not already in one
5. Show summary of created files

Use the farm-stack skill for all patterns and conventions.
