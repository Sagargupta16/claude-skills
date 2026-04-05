---
description: Design REST API endpoints for a feature with URL structure, methods, request/response schemas, and error handling
user_invocable: true
---

Design API endpoints for the specified feature or domain.

Steps:
1. Understand the feature requirements from the user's description
2. Identify the resources and their relationships
3. Detect the existing API framework (FastAPI, Express, Go, etc.) from the codebase
4. Check existing endpoints for naming and style conventions
5. Design endpoints following REST conventions:
   - Resource URLs (plural nouns, max 2 nesting levels)
   - HTTP methods (GET, POST, PUT, PATCH, DELETE)
   - Request body schemas
   - Response schemas with status codes
   - Error response format matching existing API patterns
   - Pagination for list endpoints
6. Present the design as a table with URL, method, description, and request/response types
7. If approved, generate the route/controller code matching the project's patterns

Do NOT generate code until the user approves the design. Present the API contract first.
