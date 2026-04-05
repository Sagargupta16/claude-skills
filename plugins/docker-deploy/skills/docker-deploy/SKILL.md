---
name: docker-deploy
description: Use when creating Dockerfiles, docker-compose configs, or containerizing applications. Covers multi-stage builds, image optimization, compose patterns for dev and production, health checks, signal handling, and security hardening.
---

# Docker and Deployment Patterns

## Quick Reference

| Task | Approach |
|------|----------|
| New Dockerfile | Choose template by language below |
| Optimize image | Multi-stage build + Alpine/distroless base |
| Dev environment | docker-compose with hot-reload and volumes |
| Production | Multi-stage, non-root user, health checks |
| Debugging | `docker logs`, `docker exec`, build with `--progress=plain` |

## Dockerfile Templates

### Python (FastAPI / Flask / Django)

```dockerfile
# Build stage
FROM python:3.13-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Runtime stage
FROM python:3.13-slim
WORKDIR /app
RUN adduser --disabled-password --no-create-home appuser
COPY --from=builder /install /usr/local
COPY . .
USER appuser
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Node.js (Express / Next.js / Vite)

```dockerfile
# Build stage
FROM node:22-alpine AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

# Runtime stage
FROM node:22-alpine
WORKDIR /app
RUN adduser -D appuser
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json .
USER appuser
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### Go

```dockerfile
# Build stage
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /app/server .

# Runtime stage
FROM gcr.io/distroless/static-debian12
COPY --from=builder /app/server /server
USER nonroot
EXPOSE 8080
ENTRYPOINT ["/server"]
```

### Rust

```dockerfile
# Build stage
FROM rust:1.82-slim AS builder
WORKDIR /app
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs && cargo build --release && rm -rf src
COPY . .
RUN cargo build --release

# Runtime stage
FROM gcr.io/distroless/cc-debian12
COPY --from=builder /app/target/release/app /app
USER nonroot
EXPOSE 8080
ENTRYPOINT ["/app"]
```

## Docker Compose Patterns

### Development

```yaml
services:
  app:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - .:/app          # Hot-reload via volume mount
      - /app/node_modules  # Exclude node_modules from mount
    environment:
      - DEBUG=true
    depends_on:
      db:
        condition: service_healthy

  db:
    image: mongo:8
    ports:
      - "27017:27017"
    volumes:
      - db_data:/data/db
    healthcheck:
      test: mongosh --eval "db.runCommand('ping').ok"
      interval: 10s
      timeout: 5s
      retries: 3

volumes:
  db_data:
```

### Production

```yaml
services:
  app:
    image: ghcr.io/org/app:latest
    ports:
      - "8000:8000"
    env_file: .env
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: "0.5"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 15s
    depends_on:
      db:
        condition: service_healthy

  db:
    image: mongo:8
    volumes:
      - db_data:/data/db
    restart: unless-stopped
    healthcheck:
      test: mongosh --eval "db.runCommand('ping').ok"
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  db_data:
```

## .dockerignore

Always create a `.dockerignore` to keep images small and avoid leaking secrets:

```
.git
.gitignore
node_modules
__pycache__
*.pyc
.env
.env.*
.vscode
.idea
*.md
!README.md
docker-compose*.yml
Dockerfile*
.dockerignore
tests/
coverage/
.pytest_cache/
dist/
build/
```

## Image Optimization

### Base Image Selection

| Use Case | Base Image | Size |
|----------|-----------|------|
| Python apps | `python:3.13-slim` | ~150MB |
| Python minimal | `python:3.13-alpine` | ~50MB |
| Node.js apps | `node:22-alpine` | ~130MB |
| Go apps | `gcr.io/distroless/static` | ~2MB |
| Rust apps | `gcr.io/distroless/cc` | ~20MB |
| Static files | `nginx:alpine` | ~40MB |

### Layer Caching

Order instructions from least to most frequently changing:

```dockerfile
# 1. Base image (rarely changes)
FROM python:3.13-slim

# 2. System deps (rarely changes)
RUN apt-get update && apt-get install -y --no-install-recommends curl

# 3. App deps (changes when lockfile changes)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. App code (changes most often - LAST)
COPY . .
```

## Health Checks

```dockerfile
# HTTP health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=15s \
  CMD curl -f http://localhost:8000/health || exit 1

# TCP health check (no curl needed)
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD nc -z localhost 8000 || exit 1
```

## Signal Handling

Use `exec` form for CMD/ENTRYPOINT to receive signals correctly:

```dockerfile
# GOOD: exec form - PID 1, receives SIGTERM
CMD ["uvicorn", "main:app", "--host", "0.0.0.0"]

# BAD: shell form - shell is PID 1, app doesn't get signals
CMD uvicorn main:app --host 0.0.0.0
```

For Node.js, handle SIGTERM explicitly:
```javascript
process.on("SIGTERM", () => {
  server.close(() => process.exit(0));
});
```

## Security Hardening

| Practice | Implementation |
|----------|---------------|
| Non-root user | `RUN adduser -D appuser` + `USER appuser` |
| No secrets in image | Use env vars or mounted secrets at runtime |
| Pin base image digests | `FROM python:3.13-slim@sha256:abc...` for production |
| Scan for vulnerabilities | `docker scout cves` or `trivy image` |
| Read-only filesystem | `docker run --read-only --tmpdir /tmp` |
| No unnecessary packages | `--no-install-recommends` for apt |

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Run as root | Create and switch to non-root user |
| Skip `.dockerignore` | Always create one (prevents leaking .env, .git) |
| `COPY . .` before installing deps | Copy lockfile first, install, then copy code |
| Use `latest` tag in production | Pin specific versions or digests |
| Store secrets in image layers | Use runtime env vars or mounted secrets |
| Install dev dependencies in prod image | Use multi-stage builds |
| Use `alpine` with Python C extensions | Use `slim` instead (musl vs glibc issues) |
| Ignore `SIGTERM` handling | Use exec form CMD + signal handlers |
