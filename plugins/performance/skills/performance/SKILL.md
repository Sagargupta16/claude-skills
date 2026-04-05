---
name: performance
description: Use when optimizing application performance -- profiling, caching strategies, query optimization, bundle analysis, lazy loading, memory management, or benchmarking. Covers backend, frontend, and database performance for any stack.
---

# Performance Optimization Patterns

## Quick Reference

| Task | Approach |
|------|----------|
| Find bottleneck | Profile first, never guess |
| Slow API response | Check queries (N+1), add caching, pagination |
| Large bundle | Code splitting, tree shaking, lazy loading |
| Memory leak | Heap snapshots, check event listeners and closures |
| Slow database | EXPLAIN query, add indexes, check connection pool |
| High CPU | Profile flamegraph, check loops and algorithms |

## The Optimization Workflow

1. **Measure** -- profile to find the actual bottleneck
2. **Set a target** -- "response time under 200ms" not "make it faster"
3. **Fix the biggest bottleneck** -- one change at a time
4. **Measure again** -- verify the improvement
5. **Stop when target is met** -- don't over-optimize

Never optimize without profiling first. Intuition about bottlenecks is wrong more often than right.

## Profiling Tools

| Language | Tool | Command |
|----------|------|---------|
| Python | cProfile | `python -m cProfile -s cumtime app.py` |
| Python | py-spy | `py-spy top --pid <pid>` |
| Node.js | clinic.js | `npx clinic doctor -- node app.js` |
| Node.js | built-in | `node --prof app.js` |
| Go | pprof | `import _ "net/http/pprof"` then `/debug/pprof/` |
| Rust | flamegraph | `cargo flamegraph` |
| Browser | DevTools | Performance tab -> Record |

## Caching Strategies

### Cache Hierarchy

| Level | Tool | TTL | Use Case |
|-------|------|-----|----------|
| In-process | Dict/Map | App lifetime | Config, small lookup tables |
| Application | Redis/Memcached | Minutes-hours | Session data, API responses |
| HTTP | Cache-Control headers | Varies | Static assets, API responses |
| CDN | CloudFront/Cloudflare | Hours-days | Static files, images |
| Database | Query cache, materialized views | Varies | Expensive aggregations |

### Cache Invalidation Patterns

| Pattern | How | When |
|---------|-----|------|
| TTL-based | Set expiry time | Data changes predictably |
| Write-through | Update cache on write | Consistency critical |
| Cache-aside | Check cache, fallback to DB, write to cache | Read-heavy workloads |
| Event-driven | Invalidate on event/webhook | Distributed systems |

```python
# Cache-aside pattern
async def get_user(user_id: str) -> dict:
    cached = await redis.get(f"user:{user_id}")
    if cached:
        return json.loads(cached)
    user = await db.users.find_one({"_id": user_id})
    await redis.set(f"user:{user_id}", json.dumps(user), ex=300)  # 5 min TTL
    return user
```

### HTTP Caching

```python
# Static assets: cache aggressively
Cache-Control: public, max-age=31536000, immutable

# API responses: short cache with revalidation
Cache-Control: private, max-age=60, must-revalidate
ETag: "abc123"

# Never cache
Cache-Control: no-store
```

## Backend Optimization

### N+1 Query Problem

```python
# BAD: N+1 queries (1 for users + N for orders)
users = await db.users.find().to_list()
for user in users:
    user["orders"] = await db.orders.find({"user_id": user["_id"]}).to_list()

# GOOD: 2 queries total
users = await db.users.find().to_list()
user_ids = [u["_id"] for u in users]
orders = await db.orders.find({"user_id": {"$in": user_ids}}).to_list()
orders_by_user = defaultdict(list)
for order in orders:
    orders_by_user[order["user_id"]].append(order)
```

### Pagination

Always paginate list endpoints. Never return unbounded results.

```python
# Cursor-based (efficient for large datasets)
@router.get("/items")
async def list_items(cursor: str | None = None, limit: int = Query(default=25, le=100)):
    query = {}
    if cursor:
        query["_id"] = {"$gt": ObjectId(cursor)}
    items = await db.items.find(query).limit(limit + 1).to_list()
    has_more = len(items) > limit
    items = items[:limit]
    next_cursor = str(items[-1]["_id"]) if has_more else None
    return {"data": items, "next_cursor": next_cursor}
```

### Connection Pooling

Always pool database and HTTP connections in production:

```python
# Database pool
engine = create_async_engine(url, pool_size=10, max_overflow=20)

# HTTP client pool
client = httpx.AsyncClient(limits=httpx.Limits(max_connections=100))
```

## Frontend Optimization

### Bundle Size

| Technique | Impact |
|-----------|--------|
| Code splitting (dynamic imports) | Load only what's needed |
| Tree shaking | Remove unused exports |
| Lazy-load routes | Don't load all pages upfront |
| Replace heavy libraries | date-fns over moment, preact over react |
| Analyze bundle | `npx vite-bundle-visualizer` or webpack-bundle-analyzer |

```typescript
// Lazy-load a route component
const Dashboard = lazy(() => import("./pages/Dashboard"));
```

### Image Optimization

| Format | Use Case |
|--------|----------|
| WebP | Photos, complex images (30% smaller than JPEG) |
| AVIF | Photos (50% smaller, less browser support) |
| SVG | Icons, logos, simple graphics |
| PNG | Screenshots, images needing transparency |

Always set explicit `width` and `height` to prevent layout shift.

### Critical Rendering Path

1. Minimize critical CSS (inline above-the-fold styles)
2. Defer non-critical JavaScript (`defer` or `async`)
3. Preload key resources: `<link rel="preload" href="font.woff2" as="font">`
4. Lazy-load below-the-fold images: `loading="lazy"`

## Benchmarking

```bash
# HTTP endpoints
hey -n 1000 -c 50 http://localhost:8000/api/users
# or
wrk -t4 -c100 -d30s http://localhost:8000/api/users

# Python functions
python -m timeit -s "from app import func" "func()"

# Node.js (built-in)
console.time("operation");
await doSomething();
console.timeEnd("operation");
```

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Optimize without profiling | Measure first, then optimize the actual bottleneck |
| Cache everything | Cache hot paths with clear invalidation strategy |
| Premature optimization | Ship working code first, optimize when metrics show need |
| Micro-optimize tight loops before fixing N+1 queries | Fix algorithmic issues before constant-factor tweaks |
| Add indexes to every column | Index only columns used in WHERE/JOIN/ORDER BY |
| Load all data then filter in app code | Filter and paginate at the database level |
| Serve unoptimized images | Compress, resize, use modern formats (WebP/AVIF) |
