---
name: logging-observability
description: Use when setting up logging, error tracking, health checks, metrics, or monitoring. Covers structured logging, log levels, correlation IDs, error reporting, and observability patterns for any backend framework.
---

# Logging and Observability Patterns

## Quick Reference

| Task | Approach |
|------|----------|
| Structured logging | JSON format with consistent fields |
| Log levels | ERROR for failures, WARN for degraded, INFO for events, DEBUG for dev |
| Error tracking | Capture exceptions with context, report to error service |
| Health checks | `/health` endpoint returning service and dependency status |
| Request tracing | Correlation ID per request, pass through service calls |
| Metrics | Count requests, measure latency, track error rates |

## Structured Logging

Always log as structured data (JSON), not free-text strings.

### Python

```python
import logging
import json

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            "timestamp": self.formatTime(record),
            "level": record.levelname,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
        }
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)
        if hasattr(record, "request_id"):
            log_data["request_id"] = record.request_id
        return json.dumps(log_data)
```

Or use `structlog` for Python:
```python
import structlog

logger = structlog.get_logger()
logger.info("order_created", order_id="abc-123", user_id="user-456", total=2500)
# {"event": "order_created", "order_id": "abc-123", "user_id": "user-456", "total": 2500, "timestamp": "..."}
```

### Node.js

```javascript
import pino from "pino";

const logger = pino({ level: "info" });
logger.info({ orderId: "abc-123", userId: "user-456", total: 2500 }, "order created");
// {"level":30,"time":...,"orderId":"abc-123","msg":"order created"}
```

### Go

```go
import "log/slog"

logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
logger.Info("order created",
    slog.String("order_id", "abc-123"),
    slog.String("user_id", "user-456"),
    slog.Int("total", 2500),
)
```

## Log Levels

| Level | When to Use | Examples |
|-------|-------------|---------|
| ERROR | Operation failed, needs attention | Unhandled exception, payment failed, DB connection lost |
| WARN | Degraded but functional | Retry succeeded, rate limit approaching, deprecated API called |
| INFO | Significant business events | User registered, order placed, deployment started |
| DEBUG | Development diagnostics | SQL queries, HTTP request/response details, cache hit/miss |

Rules:
- Production runs at INFO level (ERROR + WARN + INFO)
- Never log at ERROR for expected conditions (404, validation failures)
- DEBUG should be disabled in production unless actively investigating
- One INFO log per significant business event, not per function call

## Request Correlation

Assign a unique ID to each request and pass it through all service calls:

```python
import uuid
from contextvars import ContextVar

request_id_var: ContextVar[str] = ContextVar("request_id", default="")

@app.middleware("http")
async def add_request_id(request, call_next):
    request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
    request_id_var.set(request_id)
    response = await call_next(request)
    response.headers["X-Request-ID"] = request_id
    return response
```

Include `request_id` in every log entry. When calling downstream services, forward the header:
```python
httpx.get(url, headers={"X-Request-ID": request_id_var.get()})
```

## Health Checks

### Basic Health Endpoint

```python
@app.get("/health")
async def health():
    return {"status": "healthy"}
```

### Deep Health Check (with dependencies)

```python
@app.get("/health")
async def health():
    checks = {}

    # Database
    try:
        await db.command("ping")
        checks["database"] = "healthy"
    except Exception:
        checks["database"] = "unhealthy"

    # Redis
    try:
        await redis.ping()
        checks["redis"] = "healthy"
    except Exception:
        checks["redis"] = "unhealthy"

    all_healthy = all(v == "healthy" for v in checks.values())
    status_code = 200 if all_healthy else 503

    return JSONResponse(
        status_code=status_code,
        content={"status": "healthy" if all_healthy else "degraded", "checks": checks},
    )
```

Expose `/health` for load balancers (simple, fast) and `/health/detailed` for monitoring (includes dependency checks).

## Error Handling and Reporting

### Capture Context with Errors

```python
@app.exception_handler(Exception)
async def unhandled_exception_handler(request, exc):
    logger.error(
        "unhandled_exception",
        exc_info=exc,
        path=request.url.path,
        method=request.method,
        request_id=request_id_var.get(),
    )
    return JSONResponse(
        status_code=500,
        content={"type": "internal_error", "title": "Internal Server Error", "status": 500},
    )
```

### What to Log on Errors

| Include | Exclude |
|---------|---------|
| Error type and message | Passwords and tokens |
| Stack trace | Full request bodies with PII |
| Request path and method | Credit card numbers |
| Request ID / correlation ID | Session tokens |
| User ID (if authenticated) | Internal IP addresses |
| Timestamp | Database connection strings |

## Metrics (the Four Golden Signals)

| Signal | What to Measure | How |
|--------|----------------|-----|
| Latency | Request duration | Histogram per endpoint |
| Traffic | Requests per second | Counter per endpoint |
| Errors | Error rate (5xx / total) | Counter by status code |
| Saturation | CPU, memory, DB connections | Gauge |

```python
# Prometheus metrics example
from prometheus_client import Counter, Histogram

REQUEST_COUNT = Counter("http_requests_total", "Total requests", ["method", "path", "status"])
REQUEST_LATENCY = Histogram("http_request_duration_seconds", "Request latency", ["method", "path"])

@app.middleware("http")
async def metrics_middleware(request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start
    REQUEST_COUNT.labels(request.method, request.url.path, response.status_code).inc()
    REQUEST_LATENCY.labels(request.method, request.url.path).observe(duration)
    return response
```

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| `print()` for logging | Use a proper logging library with levels |
| Log as free-text strings | Use structured JSON logging |
| Log everything at INFO | Use appropriate levels -- most things are DEBUG |
| Log sensitive data (passwords, tokens) | Redact or exclude sensitive fields |
| Catch and silently swallow exceptions | Log with context, then re-raise or return error |
| Health check that always returns 200 | Check actual dependencies, return 503 when degraded |
| Generate a new request ID per service | Forward the original request ID through the chain |
| Alert on every single error | Alert on error rate thresholds, not individual errors |
