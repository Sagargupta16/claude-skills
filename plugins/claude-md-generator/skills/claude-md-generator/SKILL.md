---
name: claude-md-generator
description: Use when creating a new CLAUDE.md file for a project, auditing an existing CLAUDE.md, or scaffolding project-specific Claude Code configuration. Covers templates for Python, React, Terraform, MERN, and monorepo workspaces with best-practice structure.
---

# CLAUDE.md Generator

## Quick Reference

| Project Type | Detection File | Template Focus |
|-------------|---------------|---------------|
| Python (FastAPI/Django) | `pyproject.toml`, `requirements.txt` | uv/pip, ruff, pyright, pytest |
| React/Next.js | `package.json` + react dep | pnpm, vite/next, eslint/biome, vitest |
| MERN stack | `package.json` + express + client/ | npm, express, mongodb, jest |
| Terraform/IaC | `*.tf`, `main.tf` | tflint, checkov, state management |
| Go | `go.mod` | go test, golangci-lint, go vet |
| Rust | `Cargo.toml` | cargo test, clippy, cargo fmt |
| Monorepo workspace | Multiple projects in subdirs | Root conventions + per-project rules |

## CLAUDE.md Structure

Every CLAUDE.md should follow this order:

```markdown
# CLAUDE.md

## Project Overview
[1-2 sentences: what this project does, what stack it uses]

## Common Commands
[Build, test, lint, run -- the commands you use daily]

## Coding Conventions
[Language style, formatting, naming, import order]

## Architecture
[Key patterns, data flow, important directories]

## Testing
[How to run tests, what framework, coverage requirements]

## Deployment
[How it deploys, environments, CI/CD]
```

## Best Practices

### Length
- Target: under 200 lines per CLAUDE.md file
- Over 200 lines: Claude starts ignoring rules in long contexts
- Split into `.claude/rules/*.md` for detailed sub-topics

### Critical Rules
Wrap must-follow rules in important tags:

```markdown
<important>
- Never commit .env files or API keys
- Always run tests before pushing
- Use conventional commits
</important>
```

### Loading Behavior (Monorepos)
- **Ancestors** (parent directories): Load at startup, walking up the directory tree
- **Descendants** (child directories): Load lazily when Claude reads files in that directory
- **Siblings** (parallel directories): Never load

Design implications:
- Put shared conventions in root CLAUDE.md
- Put component-specific rules in their own CLAUDE.md
- Don't rely on sibling rules loading -- `frontend/CLAUDE.md` won't see `backend/CLAUDE.md`

## Python Template

```markdown
# CLAUDE.md

## Project Overview
[Project name] -- [brief description]. Built with Python [version], FastAPI, and [database].

## Common Commands
- Install: `uv sync` (or `pip install -r requirements.txt`)
- Run: `uvicorn main:app --reload`
- Test: `python -m pytest -v`
- Lint: `ruff check . --fix`
- Type check: `pyright`
- Format: `ruff format .`

## Coding Conventions
- Type hints on all function signatures
- f-strings over .format() or %
- pathlib over os.path
- `from __future__ import annotations` in every file
- Docstrings: Google style, only for public APIs
- Max line length: 88 (ruff default)

## Architecture
[Describe key directories and patterns]

## Testing
- Framework: pytest with anyio for async tests
- Fixtures in conftest.py
- Mark DB tests: `@pytest.mark.db_test`
- Coverage: `pytest --cov=src --cov-report=term-missing`

<important>
- Never commit .env files -- use .env.example with placeholders
- Always run `python -m pytest` before pushing
- Use parameterized queries -- never string concatenation for DB
</important>
```

## React/Vite Template

```markdown
# CLAUDE.md

## Project Overview
[Project name] -- [brief description]. Built with React [version], Vite, and Tailwind CSS.

## Common Commands
- Install: `pnpm install`
- Dev: `pnpm dev`
- Build: `pnpm build`
- Test: `pnpm test`
- Lint: `pnpm lint`
- Type check: `tsc --noEmit`

## Coding Conventions
- Functional components with hooks only -- no class components
- CSS: Tailwind utility classes, no inline styles for layouts
- Imports: React first, then third-party, then local (auto-sorted)
- Named exports for components, default export only for pages
- Props: destructure in function signature

## Architecture
- `src/components/` -- reusable UI components
- `src/pages/` -- route-level pages
- `src/hooks/` -- custom hooks
- `src/data/` -- static data files (JSON)
- `src/lib/` -- utilities and helpers

<important>
- Never commit node_modules/ or .env files
- Always run `pnpm build` before creating a PR (catches type errors)
- Test in browser -- type checks don't verify UI behavior
</important>
```

## Terraform Template

```markdown
# CLAUDE.md

## Project Overview
Terraform configuration for [infrastructure description]. Provider: [AWS/GCP/Azure].

## Common Commands
- Init: `terraform init`
- Plan: `terraform plan -out=tfplan`
- Apply: `terraform apply tfplan`
- Validate: `terraform validate`
- Lint: `tflint --recursive`
- Security: `checkov -d .`
- Format: `terraform fmt -recursive`

## Conventions
- One resource type per file (e.g., vpc.tf, subnets.tf, security_groups.tf)
- Variables in variables.tf, outputs in outputs.tf
- Use locals for computed values and repeated expressions
- Tag all resources with: Environment, Project, ManagedBy=terraform
- State stored in S3 with DynamoDB locking

## Architecture
[Describe module structure, environments, state layout]

<important>
- Never hardcode credentials -- use IAM roles or environment variables
- Always run `terraform plan` before `terraform apply`
- Review destroys carefully -- they are irreversible
- Never store state files locally in production
- Run `checkov` before every PR
</important>
```

## CLAUDE.md Audit Checklist

When auditing an existing CLAUDE.md:

| Check | Standard |
|-------|----------|
| Length | Under 200 lines |
| Structure | Follows Overview > Commands > Conventions > Architecture order |
| Commands | Lists actual project commands (not generic) |
| Conventions | Specific to the tech stack in use |
| Critical rules | Wrapped in `<important>` tags |
| No secrets | No API keys, tokens, or real credentials |
| Up to date | Matches current project structure and tooling |
| Actionable | Rules are specific enough to follow, not vague platitudes |

## Anti-Patterns

| Anti-Pattern | Problem | Do Instead |
|-------------|---------|-----------|
| Generic filler content | Claude ignores vague rules | Write specific, actionable rules |
| 500+ line CLAUDE.md | Rules get ignored in long contexts | Under 200 lines, split to rules/ |
| No important tags | Critical rules have same weight as suggestions | Wrap must-follow rules in `<important>` |
| Documenting obvious things | Wastes context window | Focus on non-obvious project-specific rules |
| Copy-pasting from other projects | Rules don't match actual project | Customize for the specific project |
| Never updating | CLAUDE.md drifts from reality | Update when tooling or conventions change |
