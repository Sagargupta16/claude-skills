---
description: Set up or fix GitHub Actions CI/CD for the current project
user_invocable: true
---

Set up or fix GitHub Actions CI/CD workflows for the current project.

Steps:
1. Detect project type:
   - `package.json` -> Node.js (check for pnpm-lock.yaml, yarn.lock, or package-lock.json)
   - `requirements.txt` / `pyproject.toml` -> Python
   - `Cargo.toml` -> Rust
   - `go.mod` -> Go
   - `Dockerfile` -> Docker build
2. Check if `.github/workflows/` already exists
   - If yes, read existing workflows and identify issues
   - If no, create the directory
3. Generate a CI workflow using the ci-cd skill templates:
   - Lint step (appropriate linter for the language)
   - Test step (detected test framework)
   - Build step (if applicable)
   - Caching (appropriate for the package manager)
4. If a Dockerfile exists, optionally add a Docker build job
5. Show the generated workflow for review before writing
6. Write to `.github/workflows/ci.yml`
7. Show next steps (commit, push, check Actions tab)

Use the ci-cd skill for all workflow patterns and best practices.
