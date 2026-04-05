---
name: api-design
description: Use when designing REST or GraphQL APIs, choosing URL structures, error formats, pagination strategies, or authentication patterns. Covers HTTP conventions, versioning, OpenAPI, and rate limiting.
---

# API Design Patterns

## Quick Reference

| Task | Approach |
|------|----------|
| URL structure | Nouns for resources, HTTP verbs for actions |
| Versioning | URL prefix (`/api/v1/`) for most projects |
| Errors | RFC 9457 problem details format |
| Pagination | Cursor-based for large datasets, offset for small |
| Auth | JWT bearer tokens or API keys depending on use case |
| Docs | OpenAPI 3.1 spec, auto-generated where possible |

## URL Structure

### Resource Naming

```
GET    /api/v1/users           # List users
POST   /api/v1/users           # Create user
GET    /api/v1/users/{id}      # Get user by ID
PUT    /api/v1/users/{id}      # Replace user
PATCH  /api/v1/users/{id}      # Partial update
DELETE /api/v1/users/{id}      # Delete user

GET    /api/v1/users/{id}/orders    # Nested resource
POST   /api/v1/users/{id}/orders    # Create nested resource
```

Rules:
- Plural nouns for collections: `/users` not `/user`
- Kebab-case for multi-word resources: `/order-items`
- No verbs in URLs: `/users/{id}/activate` not `/activateUser`
- Max 2 levels of nesting, then use query params or top-level resources

### Filtering, Sorting, Search

```
GET /api/v1/users?status=active&role=admin       # Filter
GET /api/v1/users?sort=-created_at,name           # Sort (- for desc)
GET /api/v1/users?search=john                     # Search
GET /api/v1/users?fields=id,name,email            # Sparse fields
```

## HTTP Methods and Status Codes

### Methods

| Method | Purpose | Idempotent | Body |
|--------|---------|-----------|------|
| GET | Read resource(s) | Yes | No |
| POST | Create resource | No | Yes |
| PUT | Replace resource | Yes | Yes |
| PATCH | Partial update | No | Yes |
| DELETE | Remove resource | Yes | No |

### Status Codes

| Code | When to Use |
|------|-------------|
| 200 | Successful GET, PUT, PATCH, DELETE |
| 201 | Successful POST (resource created) |
| 204 | Successful DELETE with no body |
| 400 | Invalid request body or params |
| 401 | Missing or invalid authentication |
| 403 | Authenticated but not authorized |
| 404 | Resource not found |
| 409 | Conflict (duplicate, state violation) |
| 422 | Valid JSON but failed validation |
| 429 | Rate limit exceeded |
| 500 | Unhandled server error |

## Error Response Format

Use RFC 9457 Problem Details:

```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation Error",
  "status": 422,
  "detail": "Email address is already in use",
  "instance": "/api/v1/users",
  "errors": [
    {
      "field": "email",
      "message": "Email 'test@test.com' is already registered"
    }
  ]
}
```

Rules:
- Always include `status`, `title`, and `detail`
- Use `errors` array for field-level validation failures
- Never expose stack traces or internal details in production
- Use consistent error types across the API

### Framework Implementation

**FastAPI:**
```python
from fastapi import HTTPException
from fastapi.responses import JSONResponse

@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "type": f"https://api.example.com/errors/{exc.status_code}",
            "title": exc.detail,
            "status": exc.status_code,
        },
    )
```

**Express:**
```javascript
app.use((err, req, res, next) => {
  const status = err.status || 500;
  res.status(status).json({
    type: `https://api.example.com/errors/${status}`,
    title: err.message,
    status,
  });
});
```

## Versioning

| Strategy | Format | When to Use |
|----------|--------|-------------|
| URL prefix | `/api/v1/users` | Default choice -- simple, visible, cacheable |
| Header | `Accept: application/vnd.api+json;version=2` | When URL stability matters |
| Query param | `/api/users?version=2` | Avoid -- poor caching |

When to bump versions:
- Removing a field from a response: **breaking** (bump major)
- Adding an optional field: **non-breaking** (no bump)
- Changing a field type: **breaking** (bump major)
- Adding a new endpoint: **non-breaking** (no bump)

## Pagination

### Cursor-Based (recommended for large datasets)

```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6MTAwfQ==",
    "has_more": true
  }
}
```

Request: `GET /api/v1/users?cursor=eyJpZCI6MTAwfQ==&limit=25`

Advantages: consistent results, no skipped/duplicated items on insert/delete.

### Offset-Based (simpler, for small datasets)

```json
{
  "data": [...],
  "pagination": {
    "total": 150,
    "page": 2,
    "per_page": 25,
    "total_pages": 6
  }
}
```

Request: `GET /api/v1/users?page=2&per_page=25`

### Default Limits

Always enforce a max page size server-side:
```python
@router.get("/users")
async def list_users(page: int = 1, per_page: int = Query(default=25, le=100)):
    ...
```

## Authentication Patterns

| Pattern | Use Case | Implementation |
|---------|----------|---------------|
| JWT Bearer | SPA, mobile apps | `Authorization: Bearer <token>` |
| API Key | Server-to-server, third-party integrations | `X-API-Key: <key>` or query param |
| Session cookie | Traditional web apps | `Set-Cookie: session=<id>` |
| OAuth 2.0 | Third-party login | Authorization code flow |

JWT structure:
```
Header: {"alg": "HS256", "typ": "JWT"}
Payload: {"sub": "user_123", "exp": 1700000000, "role": "admin"}
```

Rules:
- Short token expiry (15min access, 7d refresh)
- Store refresh tokens server-side
- Never store JWTs in localStorage (use httpOnly cookies)
- Validate tokens on every request

## Rate Limiting

Response headers:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1700000060
Retry-After: 30
```

Common limits:
- Public APIs: 60-100 requests/minute
- Authenticated: 1000 requests/minute
- Write operations: Lower limits than reads

Return `429 Too Many Requests` with `Retry-After` header.

## OpenAPI / Swagger

Auto-generate where possible:
- **FastAPI**: Built-in at `/docs` (Swagger UI) and `/redoc`
- **Express**: Use `swagger-jsdoc` + `swagger-ui-express`
- **Go**: Use `swag` annotations
- **NestJS**: `@nestjs/swagger` decorators

Minimum spec:
```yaml
openapi: "3.1.0"
info:
  title: API Name
  version: "1.0.0"
paths:
  /api/v1/users:
    get:
      summary: List users
      parameters:
        - name: page
          in: query
          schema: { type: integer, default: 1 }
      responses:
        "200":
          description: User list
```

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Use verbs in URLs (`/getUsers`) | Use HTTP methods on noun resources |
| Return 200 for errors with error body | Use proper HTTP status codes |
| Expose database IDs directly | Use UUIDs or opaque IDs |
| Return different error formats per endpoint | Use consistent error schema everywhere |
| Paginate without a max limit | Always enforce server-side max page size |
| Version every minor change | Only version on breaking changes |
| Return full nested objects always | Support sparse fields or use separate endpoints |
| Accept `*` CORS in production | Whitelist specific origins from env vars |
