# Security Hardening Plugin

Web application security hardening and vulnerability prevention.

## Skills

- **security-hardening**: OWASP top 10 prevention with code examples, security headers configuration, rate limiting, CORS setup, input validation, password hashing, and sensitive data handling.

## Commands

- `/security-audit`: Scan code for security vulnerabilities and hardening opportunities

## Example

```
> /security-audit

Scanning codebase...

| Severity | Location          | Issue                        | Fix                          |
|----------|-------------------|------------------------------|------------------------------|
| CRITICAL | routes/auth.py:23 | Password stored as MD5       | Switch to bcrypt             |
| HIGH     | main.py:15        | CORS allows all origins      | Explicit allowlist from env  |
| HIGH     | routes/user.py:45 | No rate limit on login       | Add 5/min limit              |
| MEDIUM   | main.py           | Missing security headers     | Add helmet/middleware        |
| LOW      | routes/search.py  | No input length validation   | Add max_length to query param|

Fix critical and high issues?
```

## Installation

```
/plugin install security-hardening@sagar-dev-skills
```
