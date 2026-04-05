# API Design Plugin

REST API design patterns, HTTP conventions, error handling, pagination, and authentication.

## Skills

- **api-design**: URL structure, HTTP methods and status codes, RFC 9457 error format, pagination strategies, authentication patterns, versioning, rate limiting, and OpenAPI.

## Commands

- `/design-api`: Design REST API endpoints for a feature before writing code

## Example

```
> /design-api "user management with roles"

Proposed endpoints:

| Method | URL                          | Description              |
|--------|------------------------------|--------------------------|
| GET    | /api/v1/users                | List users (paginated)   |
| POST   | /api/v1/users                | Create user              |
| GET    | /api/v1/users/{id}           | Get user by ID           |
| PATCH  | /api/v1/users/{id}           | Update user              |
| DELETE | /api/v1/users/{id}           | Delete user              |
| GET    | /api/v1/users/{id}/roles     | Get user's roles         |
| PUT    | /api/v1/users/{id}/roles     | Set user's roles         |
| GET    | /api/v1/roles                | List available roles     |

Shall I generate the route handlers?
```

## Installation

```
/plugin install api-design@sagar-dev-skills
```
