---
description: Set up structured logging, health checks, and error handling for the project
user_invocable: true
---

Set up or improve logging and observability for the current project.

Steps:
1. Detect the framework (FastAPI, Express, Go, etc.)
2. Check existing logging setup -- extend rather than replace
3. Set up or improve:
   - Structured JSON logging with appropriate library (structlog, pino, slog)
   - Request correlation IDs (generate on entry, forward to downstream)
   - Health check endpoint (`/health` with dependency checks)
   - Error handling middleware (capture context, log, return safe error)
4. Configure log levels: ERROR for failures, WARN for degraded, INFO for events
5. Ensure sensitive data is excluded from logs (passwords, tokens, PII)
6. Present the changes for review before applying

Do NOT add metrics/tracing infrastructure unless specifically asked. Start with logging and health checks.
