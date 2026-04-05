---
description: Scan code for security vulnerabilities and hardening opportunities
user_invocable: true
---

Audit the codebase for security issues and suggest hardening measures.

Steps:
1. Detect the stack and framework from config files
2. Scan for common vulnerabilities:
   - Injection risks (SQL, NoSQL, command injection)
   - XSS vectors (raw HTML rendering, missing CSP)
   - Hardcoded secrets, API keys, passwords
   - Missing input validation on API endpoints
   - Insecure CORS configuration (wildcard origins)
   - Missing security headers
   - Weak password hashing (MD5, SHA)
   - Missing rate limiting on auth endpoints
3. Check dependencies for known vulnerabilities (run audit command)
4. Present findings as a table: severity (critical/high/medium/low), location, issue, fix
5. If user approves, apply fixes starting with critical severity

Do NOT overwhelm with low-priority findings. Focus on issues that could lead to real exploitation.
