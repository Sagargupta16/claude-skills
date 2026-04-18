---
name: security-hardening
description: Use when hardening application security -- preventing OWASP top 10 vulnerabilities, configuring security headers, implementing rate limiting, sanitizing input, managing CORS, or reviewing code for security issues. Covers web security for any backend framework.
---

# Security Hardening Patterns

## Quick Reference

| Threat | Prevention |
|--------|-----------|
| SQL/NoSQL injection | Parameterized queries, ORMs |
| XSS | Output encoding, CSP headers |
| CSRF | SameSite cookies, CSRF tokens |
| Broken auth | Short-lived tokens, bcrypt, rate limiting |
| Sensitive data exposure | HTTPS, encryption at rest, no secrets in code |
| Security misconfiguration | Security headers, least privilege, no defaults |
| SSRF | Allowlist URLs, block private ranges |
| Path traversal | Validate and normalize paths |

## OWASP Top 10 Prevention

### Injection (SQL, NoSQL, Command)

```python
# BAD: string concatenation
query = f"SELECT * FROM users WHERE id = '{user_id}'"

# GOOD: parameterized query
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))

# GOOD: ORM
user = await User.get(id=user_id)
```

```python
# BAD: MongoDB injection
db.users.find({"username": request.json["username"]})  # attacker sends {"$ne": ""}

# GOOD: validate type
username = request.json.get("username")
if not isinstance(username, str):
    raise ValueError("Username must be a string")
db.users.find({"username": username})
```

```python
# BAD: command injection
os.system(f"convert {filename} output.png")

# GOOD: use subprocess with list args (no shell)
subprocess.run(["convert", filename, "output.png"], check=True)
```

### Cross-Site Scripting (XSS)

```python
# BAD: rendering raw HTML from user input
return f"<div>{user_input}</div>"

# GOOD: use template engine with auto-escaping (Jinja2, React)
# React auto-escapes by default. Only dangerouslySetInnerHTML bypasses it.
```

Prevent with Content Security Policy:
```
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'
```

### Authentication Failures

| Rule | Implementation |
|------|---------------|
| Hash passwords | bcrypt or argon2, never MD5/SHA |
| Short-lived access tokens | 15 minutes for JWT access tokens |
| Refresh token rotation | New refresh token on each use, revoke old |
| Rate limit login | Max 5 attempts per minute per IP |
| MFA for sensitive operations | TOTP or WebAuthn |

```python
from passlib.hash import bcrypt

# Hash
hashed = bcrypt.hash(password)

# Verify
if not bcrypt.verify(password, hashed):
    raise HTTPException(401, "Invalid credentials")
```

### Sensitive Data Exposure

- Never log passwords, tokens, or PII
- Use HTTPS everywhere (redirect HTTP to HTTPS)
- Encrypt sensitive fields at rest (PII, payment data)
- Set `Secure`, `HttpOnly`, `SameSite` on cookies
- Never return password hashes in API responses

## Security Headers

```python
# FastAPI middleware
@app.middleware("http")
async def add_security_headers(request, call_next):
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "0"  # deprecated, use CSP instead
    response.headers["Strict-Transport-Security"] = "max-age=63072000; includeSubDomains"
    response.headers["Content-Security-Policy"] = "default-src 'self'"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
    return response
```

```javascript
// Express with helmet
const helmet = require("helmet");
app.use(helmet());
```

| Header | Purpose |
|--------|---------|
| `Strict-Transport-Security` | Force HTTPS |
| `Content-Security-Policy` | Control resource loading |
| `X-Content-Type-Options: nosniff` | Prevent MIME sniffing |
| `X-Frame-Options: DENY` | Prevent clickjacking |
| `Referrer-Policy` | Control referrer information |
| `Permissions-Policy` | Disable browser features |

## Rate Limiting

```python
# FastAPI with slowapi
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@app.post("/login")
@limiter.limit("5/minute")
async def login(request: Request):
    ...
```

```javascript
// Express with express-rate-limit
const rateLimit = require("express-rate-limit");
app.use("/api/", rateLimit({
  windowMs: 60 * 1000,   // 1 minute
  max: 100,               // 100 requests per window
  standardHeaders: true,
}));
```

| Endpoint Type | Suggested Limit |
|--------------|----------------|
| Login/auth | 5-10 per minute |
| API (authenticated) | 100-1000 per minute |
| API (public) | 30-60 per minute |
| Password reset | 3 per hour |
| File upload | 10 per hour |

## CORS Configuration

```python
# GOOD: explicit origins from env
cors_origins = os.getenv("CORS_ORIGINS", "").split(",")
app.add_middleware(CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)

# BAD: wildcard with credentials
app.add_middleware(CORSMiddleware,
    allow_origins=["*"],        # anyone can call your API
    allow_credentials=True,     # this combination is rejected by browsers anyway
)
```

## Input Validation

Validate all input at system boundaries:

```python
from pydantic import BaseModel, EmailStr, Field

class CreateUser(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    email: EmailStr
    age: int = Field(ge=0, le=150)
```

| Input Type | Validation |
|-----------|-----------|
| Strings | Max length, allowlist characters for usernames |
| Numbers | Min/max range, integer vs float |
| Emails | Format validation (use library, not regex) |
| URLs | Allowlist domains for SSRF prevention |
| File uploads | Max size, allowlist MIME types, scan for malware |
| Paths | Normalize, reject `..`, resolve to allowed directory |

## Threat Modeling (STRIDE)

| Threat | Description | Common Mitigation |
|--------|-------------|-------------------|
| **S**poofing | Pretending to be another user/service | Strong auth, MFA, mTLS |
| **T**ampering | Modifying data in transit or at rest | Integrity checks, signed payloads, HMAC |
| **R**epudiation | Denying an action occurred | Audit logs, signed commits, timestamps |
| **I**nformation Disclosure | Unauthorized data access | Encryption, access control, data classification |
| **D**enial of Service | Making service unavailable | Rate limiting, CDN, auto-scaling, circuit breakers |
| **E**levation of Privilege | Gaining unauthorized access level | Least privilege, RBAC, input validation |

## Supply Chain Security

| Risk | Prevention |
|------|-----------|
| Compromised dependencies | Lock files, audit before install, Dependabot/Renovate |
| Typosquatting packages | Verify package names carefully, check download counts |
| Malicious post-install scripts | Review npm `postinstall` scripts, use `--ignore-scripts` for untrusted |
| Outdated dependencies with CVEs | Regular `npm audit` / `pip audit` / `cargo audit` |
| Unpinned versions | Always use lock files, pin in CI |

## API Security Checklist

| Check | Implementation |
|-------|---------------|
| Authentication on all endpoints | Middleware/decorator, not per-route |
| Authorization checks | Role-based, check on every request |
| Input validation | Pydantic/Zod schemas at API boundary |
| Output filtering | Don't return internal fields (password hash, internal IDs) |
| Rate limiting | Per-IP and per-user limits |
| Request size limits | Max body size, max file upload size |
| Timeout configuration | Don't let slow requests hold connections |
| Error responses | Generic messages, no stack traces in production |

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| `allow_origins=["*"]` in production | Explicit origin allowlist from env vars |
| Store passwords as MD5/SHA | Use bcrypt or argon2 |
| Log full request bodies | Redact sensitive fields (passwords, tokens, PII) |
| Disable HTTPS for development convenience | Use HTTPS everywhere, use self-signed certs for dev |
| Trust client-side validation only | Always validate server-side too |
| Use `eval()` or `exec()` with user input | Never execute user-provided code |
| Expose stack traces in production errors | Generic error messages, detailed logs server-side |
| Hardcode secrets in code | Use environment variables or secret managers |
| Install packages without auditing | Run `npm audit` / `pip audit` before and after |
| Use wildcard IAM permissions | Least privilege -- specific actions and resources |
| Skip CSRF protection on state-changing endpoints | SameSite cookies + CSRF tokens |
| Trust JWT without signature verification | Always verify signature, check expiry, validate issuer |
