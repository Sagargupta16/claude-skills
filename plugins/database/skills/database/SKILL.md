---
name: database
description: Use when designing database schemas, writing migrations, optimizing queries, choosing between SQL and NoSQL, or setting up connection pooling. Covers Postgres, MongoDB, SQLite, and migration tools like Alembic, Prisma, and Drizzle.
---

# Database Patterns

## Quick Reference

| Task | Approach |
|------|----------|
| Choose DB | See selection guide below |
| Schema design | Normalize first, denormalize with reason |
| Migrations | Use framework migration tool, never raw DDL in production |
| Indexing | Index columns used in WHERE, JOIN, ORDER BY |
| Connection pooling | Always pool in production, configure per language |
| Query optimization | EXPLAIN first, add indexes, then restructure |

## SQL vs NoSQL Selection

| Choose SQL (Postgres) When | Choose NoSQL (MongoDB) When |
|---------------------------|---------------------------|
| Complex relationships and joins | Document-shaped data with variable schema |
| ACID transactions required | High write throughput, horizontal scaling |
| Strict data integrity needed | Rapid prototyping, schema evolving frequently |
| Reporting and analytics | Nested/hierarchical data structures |
| Financial or regulated data | Geospatial queries, time series |

**Default choice**: Postgres. Use MongoDB when the data is genuinely document-shaped or schema flexibility is a core requirement.

## Schema Design

### Postgres

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'user',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    total_cents INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
```

Rules:
- Use UUIDs over auto-increment for public-facing IDs
- Store money as integer cents, never floats
- Use `TIMESTAMPTZ` not `TIMESTAMP` for timezone safety
- Add `created_at` and `updated_at` to all tables
- Foreign keys with explicit `ON DELETE` behavior

### MongoDB

```javascript
// Collection: users
{
  _id: ObjectId("..."),
  email: "user@example.com",   // unique index
  name: "Test User",
  passwordHash: "...",
  role: "user",
  createdAt: ISODate("..."),
  updatedAt: ISODate("...")
}

// Collection: orders (reference pattern)
{
  _id: ObjectId("..."),
  userId: ObjectId("..."),     // indexed
  status: "pending",
  totalCents: 2500,
  items: [                     // embedded pattern for tightly coupled data
    { productId: ObjectId("..."), name: "Widget", quantity: 2, priceCents: 1250 }
  ],
  createdAt: ISODate("...")
}
```

Embed when: data is always read together, 1:few relationship, bounded array size.
Reference when: data is shared across documents, unbounded growth, independent access patterns.

## Migration Tools

| Language | Tool | Config File |
|----------|------|-------------|
| Python (SQLAlchemy) | Alembic | `alembic.ini` |
| Python (Django) | Django migrations | `settings.py` |
| Node.js (Prisma) | Prisma Migrate | `prisma/schema.prisma` |
| Node.js (Drizzle) | Drizzle Kit | `drizzle.config.ts` |
| Node.js (Knex) | Knex migrations | `knexfile.js` |
| Go | goose | `migrations/` directory |
| Go | golang-migrate | `migrations/` directory |
| Rust | diesel | `diesel.toml` |

### Alembic (Python)

```bash
# Initialize
alembic init alembic

# Create migration
alembic revision --autogenerate -m "add orders table"

# Apply migrations
alembic upgrade head

# Rollback one step
alembic downgrade -1
```

### Prisma (Node.js)

```bash
# Create migration from schema changes
npx prisma migrate dev --name add_orders_table

# Apply migrations in production
npx prisma migrate deploy

# Generate client
npx prisma generate
```

### Drizzle (Node.js)

```bash
# Generate migration from schema changes
npx drizzle-kit generate

# Apply migrations
npx drizzle-kit migrate
```

## Indexing Strategy

### When to Index

| Scenario | Index Type |
|----------|-----------|
| Columns in WHERE clauses | B-tree (default) |
| Columns in JOIN conditions | B-tree |
| Columns in ORDER BY | B-tree |
| Full-text search | GIN (Postgres) or text index (MongoDB) |
| JSON field queries | GIN (Postgres) |
| Geospatial queries | GiST (Postgres) or 2dsphere (MongoDB) |
| Unique constraints | Unique index |

### Composite Indexes

```sql
-- Order matters: leftmost columns are used for prefix queries
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
-- This index serves: WHERE user_id = ? AND status = ?
-- Also serves:       WHERE user_id = ?
-- Does NOT serve:    WHERE status = ?
```

### MongoDB Indexes

```javascript
db.orders.createIndex({ userId: 1, status: 1 });
db.users.createIndex({ email: 1 }, { unique: true });
```

## Connection Pooling

| Language | Library | Config |
|----------|---------|--------|
| Python (async) | asyncpg | `pool = await asyncpg.create_pool(min_size=5, max_size=20)` |
| Python (sync) | SQLAlchemy | `pool_size=5, max_overflow=10` in `create_engine()` |
| Node.js | pg | `new Pool({ max: 20 })` |
| Node.js (Prisma) | Built-in | `connection_limit` in connection string |
| Go | database/sql | `db.SetMaxOpenConns(25); db.SetMaxIdleConns(5)` |

Production defaults: 5-20 connections per instance. Scale with instance count, not pool size.

## Query Optimization

### Workflow

1. **Measure**: Use `EXPLAIN ANALYZE` (Postgres) or `.explain()` (MongoDB)
2. **Identify**: Look for sequential scans, high row estimates, missing indexes
3. **Fix**: Add indexes, rewrite query, or restructure schema
4. **Verify**: Run `EXPLAIN ANALYZE` again to confirm improvement

### Common Fixes

| Problem | Solution |
|---------|----------|
| Sequential scan on large table | Add index on filtered columns |
| N+1 queries | Use JOIN or batch loading |
| Slow COUNT on large tables | Use estimated count or cache |
| Large offset pagination | Switch to cursor-based pagination |
| Unused indexes | Drop them (they slow writes) |

### Postgres EXPLAIN

```sql
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE user_id = 'abc-123' AND status = 'pending'
ORDER BY created_at DESC
LIMIT 25;
```

Look for: `Seq Scan` (bad on large tables), `Index Scan` (good), `Bitmap Heap Scan` (acceptable).

## Backup Strategy

| Database | Tool | Command |
|----------|------|---------|
| Postgres | pg_dump | `pg_dump -Fc dbname > backup.dump` |
| MongoDB | mongodump | `mongodump --uri="mongodb://..." --out=backup/` |
| SQLite | cp | `cp database.db backup.db` (while no writes) |

For production: automated daily backups, test restores monthly, keep 30-day retention.

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Store money as floats | Use integer cents or DECIMAL |
| Use `TIMESTAMP` without timezone | Use `TIMESTAMPTZ` (Postgres) or UTC everywhere |
| Run raw DDL in production | Use migration tools with up/down scripts |
| Create indexes on every column | Index only columns used in queries |
| Use `SELECT *` in production code | Select only needed columns |
| Skip connection pooling | Always pool connections in production |
| Store files in the database | Use object storage (S3), store URL in DB |
| Use ORM for complex reporting queries | Write raw SQL for analytics, ORM for CRUD |
| Delete data without soft-delete consideration | Add `deleted_at` column for audit-sensitive data |
