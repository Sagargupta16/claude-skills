# Database Plugin

Database schema design, migrations, query optimization, and connection pooling patterns.

## Skills

- **database**: SQL vs NoSQL selection, schema design for Postgres and MongoDB, migration tools (Alembic, Prisma, Drizzle, goose), indexing strategies, connection pooling, query optimization, and backup patterns.

## Commands

- `/design-schema`: Design a database schema for a feature with tables, indexes, and migrations

## Example

```
> /design-schema "e-commerce with users, products, orders"

Detected: Postgres via SQLAlchemy + Alembic

Proposed schema:

| Table    | Column       | Type         | Constraints          |
|----------|-------------|--------------|----------------------|
| users    | id          | UUID         | PK, default uuid     |
|          | email       | VARCHAR(255) | UNIQUE, NOT NULL     |
|          | name        | VARCHAR(255) | NOT NULL             |
| products | id          | UUID         | PK                   |
|          | name        | VARCHAR(255) | NOT NULL             |
|          | price_cents | INTEGER      | NOT NULL             |
| orders   | id          | UUID         | PK                   |
|          | user_id     | UUID         | FK -> users, CASCADE |
|          | status      | VARCHAR(50)  | DEFAULT 'pending'    |

Indexes: orders(user_id), orders(status)
Shall I generate the Alembic migration?
```

## Installation

```
/plugin install database@sagar-dev-skills
```
