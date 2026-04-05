---
description: Generate or improve project documentation -- README, ADR, API docs, or changelog
user_invocable: true
---

Generate or improve documentation for the current project.

Steps:
1. Detect project type and existing docs (README, CHANGELOG, docs/ directory)
2. Ask what to generate if not specified: README, ADR, API reference, changelog, or technical spec
3. For READMEs: analyze codebase for features, setup steps, usage patterns
4. For ADRs: gather context, decision, and consequences from the user
5. For API docs: read route handlers and generate endpoint reference table
6. For changelogs: read git log since last tag and categorize changes
7. Write documentation matching the project's existing style
8. Present for review before writing to files

Do NOT add generic filler. Every line should convey real information about this specific project.
