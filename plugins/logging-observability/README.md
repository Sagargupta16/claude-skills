# Logging and Observability Plugin

Structured logging, health checks, error tracking, and monitoring patterns.

## Skills

- **logging-observability**: Structured JSON logging setup (structlog, pino, slog), log level guidelines, request correlation IDs, health check endpoints, error handling middleware, metrics (four golden signals), and sensitive data redaction.

## Commands

- `/setup-logging`: Set up structured logging, health checks, and error handling

## Example

```
> /setup-logging

Detected: FastAPI project
Existing logging: basic print() statements

Setting up:
  - structlog with JSON formatter
  - Request ID middleware (generates UUID, forwards via X-Request-ID)
  - /health endpoint (checks DB + Redis connectivity)
  - Exception handler (logs context, returns safe error response)
  - Log level: INFO for production, DEBUG for development

4 files modified. Review changes?
```

## Installation

```
/plugin install logging-observability@sagar-dev-skills
```
