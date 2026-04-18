---
description: Generate a CLAUDE.md file tailored to the current project's tech stack
user_invocable: true
---

Generate a project-specific CLAUDE.md file:

1. Detect the project type by scanning for config files:
   - `pyproject.toml` / `requirements.txt` -> Python
   - `package.json` with react -> React/Vite
   - `package.json` with express -> MERN/Express
   - `*.tf` / `main.tf` -> Terraform
   - `go.mod` -> Go
   - `Cargo.toml` -> Rust
   - Multiple projects in subdirs -> Monorepo

2. Scan existing configuration for real details:
   - Package manager (pnpm, npm, uv, pip)
   - Test framework (pytest, jest, vitest, go test)
   - Linter/formatter config
   - Build commands
   - Existing CI/CD configuration

3. Generate a CLAUDE.md following the template for the detected stack:
   - Project overview (filled in from actual project)
   - Common commands (from actual package.json scripts or Makefile)
   - Coding conventions (from existing linter/formatter config)
   - Architecture (from actual directory structure)
   - Critical rules wrapped in `<important>` tags

4. Target: under 200 lines, specific to this project, no generic filler

5. If a CLAUDE.md already exists, audit it against best practices and suggest improvements instead of replacing it.
