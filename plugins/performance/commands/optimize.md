---
description: Profile and identify performance bottlenecks, then suggest targeted optimizations
user_invocable: true
---

Analyze the codebase for performance issues and suggest optimizations.

Steps:
1. Identify the performance concern from the user (slow endpoint, large bundle, memory usage)
2. Detect the stack (Python/Node/Go/Rust, frontend framework)
3. Analyze the relevant code for common bottlenecks:
   - N+1 queries, missing pagination, unbounded results
   - Missing caching opportunities
   - Large bundle imports, no code splitting
   - Synchronous I/O in async code
   - Missing connection pooling
4. Present findings as a table: location, issue, impact, fix
5. If user approves, apply fixes one at a time
6. Suggest profiling command to verify improvement

Do NOT optimize without identifying the actual bottleneck. Profile first, then fix.
