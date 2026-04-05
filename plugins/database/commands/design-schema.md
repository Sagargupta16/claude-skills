---
description: Design a database schema for a feature with tables, relationships, indexes, and migration plan
user_invocable: true
---

Design a database schema for the specified feature or domain.

Steps:
1. Understand the data requirements from the user's description
2. Detect the database type from the codebase (Postgres, MongoDB, SQLite, etc.)
3. Detect the ORM/migration tool in use (SQLAlchemy, Prisma, Drizzle, Motor, etc.)
4. Check existing schema for naming conventions and patterns
5. Design the schema:
   - Tables/collections with columns/fields and types
   - Primary keys, foreign keys, constraints
   - Indexes for expected query patterns
   - Relationships (1:1, 1:many, many:many)
6. Present the design as a table with field name, type, constraints, and purpose
7. If approved, generate:
   - Migration file using the project's migration tool
   - Model/schema definitions matching the project's ORM patterns
8. Verify the migration runs cleanly

Do NOT generate migration code until the user approves the schema design.
