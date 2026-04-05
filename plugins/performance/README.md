# Performance Plugin

Performance optimization patterns for backend, frontend, and database.

## Skills

- **performance**: Profiling workflow, caching strategies (in-process, Redis, HTTP, CDN), N+1 query detection, pagination patterns, connection pooling, bundle optimization, image optimization, and benchmarking tools.

## Commands

- `/optimize`: Profile and identify bottlenecks, then suggest targeted optimizations

## Example

```
> /optimize "API response time for /api/users"

Analyzing routes/user_routes.py...

| Issue            | Impact | Fix                              |
|------------------|--------|----------------------------------|
| N+1 query        | High   | Batch load orders with $in query |
| No pagination    | High   | Add cursor-based pagination      |
| No caching       | Medium | Redis cache with 5min TTL        |
| Missing index    | Medium | Add index on users.email         |

Apply fixes?
```

## Installation

```
/plugin install performance@sagar-dev-skills
```
