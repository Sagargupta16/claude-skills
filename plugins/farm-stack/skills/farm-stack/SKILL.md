---
name: farm-stack
description: Use when building or scaffolding FastAPI + React + MongoDB (FARM stack) applications. Covers project structure, async MongoDB with Motor, Pydantic v2 models, config patterns, Docker setup, and testing conventions.
---

# FARM Stack Development Patterns

## Quick Reference

| Task | Approach |
|------|----------|
| New project | Use `/scaffold-farm` or follow structure below |
| Add feature | Create model -> service -> route (one file per domain per layer) |
| Config | Dual-layer: env vars (priority) + YAML fallback |
| Database | Motor async client, never sync PyMongo in routes |
| Docker | Alpine-based, compose with MongoDB + backend |
| Frontend | Vite + React, proxy API in dev, static mount in prod |
| Testing | pytest + httpx async, 80%+ coverage target |

## Project Structure

```
project-root/
├── main.py                    # FastAPI entry with lifespan
├── requirements.txt           # Pinned dependencies
├── pyproject.toml             # Tool config (ruff, pytest)
├── .env.example               # Environment template
├── Dockerfile                 # python:3.13-alpine
├── docker-compose.yml         # MongoDB + backend + optional frontend
├── Makefile                   # Dev commands (run, test, lint, build)
├── config/
│   ├── __init__.py
│   ├── secrets_parser.py      # Env + YAML config loader, Motor client
│   ├── secrets.yml            # Local dev config (git-ignored)
│   ├── secrets.yml.example    # Template with placeholders
│   └── logging.py             # Logging setup
├── models/                    # Pydantic v2 data models
│   └── {domain}_models.py     # Base -> Create -> Response per domain
├── routes/                    # API endpoint handlers
│   └── {domain}_routes.py     # APIRouter per domain
├── services/                  # Business logic layer
│   └── {domain}_services.py   # Async MongoDB operations
├── utils/                     # Shared utilities
├── tests/                     # pytest suite
│   └── test_{domain}.py       # Per-domain tests
├── client/                    # React + Vite frontend
│   ├── package.json
│   ├── vite.config.js
│   └── src/
└── client_build/              # Built frontend (served as static)
```

## Naming Convention

Domain files follow strict naming: `{domain}_models.py`, `{domain}_services.py`, `{domain}_routes.py`, `test_{domain}.py`.

Adding a "product" feature creates: `product_models.py`, `product_services.py`, `product_routes.py`, `test_product.py`.

## Config Pattern

Dual-layer precedence:
1. **Environment variables** (highest priority) via `python-dotenv`
2. **YAML fallback** via `config/secrets.yml` for local dev

```python
# config/secrets_parser.py
# 1. dotenv.load_dotenv()
# 2. Read secrets.yml as fallback defaults
# 3. Build MongoDB connection string
# 4. Create Motor async client
# 5. Export get_database(), get_collection()
```

MongoDB connection variations:
- Local: `mongodb://localhost:27017/dbname`
- Authenticated: `mongodb://user:pass@host:port/dbname`
- Atlas: `mongodb+srv://user:pass@cluster.mongodb.net/dbname`
- Env override: `MONGODB_URL` bypasses all YAML parsing

## Standard .env.example

```
# Database
MONGODB_HOST=localhost
MONGODB_PORT=27017
MONGODB_DATABASE=app_name
MONGODB_USERNAME=
MONGODB_PASSWORD=

# Server
API_HOST=0.0.0.0
API_PORT=8000
DEBUG=True

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
```

## Entry Point Pattern

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: init DB connections, caches
    yield
    # Shutdown: close connections

app = FastAPI(title="App Name", version="1.0.0", lifespan=lifespan)

# CORS from env (comma-separated origins)
cors_origins = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")
app.add_middleware(CORSMiddleware,
    allow_origins=cors_origins, allow_credentials=True,
    allow_methods=["*"], allow_headers=["*"],
)

# Mount routers with versioned prefix
app.include_router(domain_router, prefix="/api/v1", tags=["domain"])

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

# Serve built frontend in production
if os.path.exists("client_build"):
    app.mount("/", StaticFiles(directory="client_build", html=True))
```

## Model Pattern (Pydantic v2)

Three-tier: Base (shared fields) -> Create (input extras) -> Response (id + timestamps).

```python
from pydantic import BaseModel, EmailStr
from datetime import datetime

class UserBase(BaseModel):
    name: str
    email: EmailStr

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: str
    created_at: datetime

    model_config = {"from_attributes": True}
```

## Service Pattern (Async MongoDB)

```python
from config.secrets_parser import get_database

class DomainService:
    def __init__(self):
        self.db = get_database()
        self.collection = self.db.domain_name

    async def get_all(self) -> list:
        items = []
        async for item in self.collection.find():
            item["id"] = str(item["_id"])
            del item["_id"]
            items.append(item)
        return items

    async def create(self, data: DomainCreate) -> dict:
        doc = data.model_dump()
        doc["created_at"] = datetime.now(timezone.utc)
        result = await self.collection.insert_one(doc)
        doc["id"] = str(result.inserted_id)
        return doc
```

Always convert `_id` (ObjectId) to string `id` when returning from MongoDB.

## Route Pattern

```python
from fastapi import APIRouter, HTTPException

router = APIRouter()
service = DomainService()

@router.get("/items", response_model=list[Item])
async def get_items():
    return await service.get_all()

@router.post("/items", response_model=Item, status_code=201)
async def create_item(data: ItemCreate):
    return await service.create(data)
```

## Docker Pattern

```dockerfile
# Check latest stable: https://hub.docker.com/_/python
FROM python:3.13-alpine
WORKDIR /app
RUN adduser -D appuser
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
USER appuser
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

docker-compose.yml includes: MongoDB 8+ with persistent volume, backend with hot-reload, shared bridge network. Environment flows from `.env` to compose to containers.

## Core Dependencies

Version numbers below are minimums as of early 2026 -- check PyPI for latest stable:

```
fastapi>=0.115.0
uvicorn[standard]>=0.34.0
motor>=3.7.0
pydantic[email]>=2.10.0
PyYAML>=6.0
python-dotenv>=1.0.0
passlib[bcrypt]>=1.7.4
python-multipart>=0.0.20
```

Dev: `pytest`, `httpx`, `ruff`, `coverage`

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Sync PyMongo in FastAPI routes | Motor async client |
| Hardcode CORS origins | Read from env var |
| Commit `config/secrets.yml` | Only commit `secrets.yml.example` |
| Use `from_attributes` without converting `_id` | Convert ObjectId to str first |
| Put business logic in routes | Use service layer |
| Use `class Config:` in Pydantic v2 | Use `model_config = {}` dict |
| Run as root in Docker | Add non-root user |
