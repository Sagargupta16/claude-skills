---
name: monorepo
description: Use when working in monorepo workspaces with multiple projects, when configuring CLAUDE.md loading for multi-project setups, or when managing cross-package dependencies and shared conventions. Covers workspace organization, CLAUDE.md hierarchy, and multi-project patterns.
---

# Monorepo Management

## Quick Reference

| Topic | Key Rule |
|-------|----------|
| CLAUDE.md loading | Ancestors load at startup, descendants load lazily, siblings never load |
| Root CLAUDE.md | Shared conventions, common commands, workspace overview |
| Package CLAUDE.md | Package-specific rules, local commands, local conventions |
| Max length | Under 200 lines per CLAUDE.md file |
| Cross-package rules | Put in root, not in one package hoping another reads it |

## CLAUDE.md Loading Rules

Understanding how CLAUDE.md files load is critical for monorepo configuration:

```
workspace/
├── CLAUDE.md              # Loads immediately at startup (ancestor)
├── packages/
│   ├── CLAUDE.md          # Loads immediately at startup (ancestor of any package)
│   ├── frontend/
│   │   ├── CLAUDE.md      # Loads lazily when reading files in frontend/
│   │   └── src/
│   │       └── CLAUDE.md  # Loads lazily when reading files in src/
│   └── backend/
│       ├── CLAUDE.md      # Loads lazily when reading files in backend/
│       └── src/
│           └── CLAUDE.md  # Loads lazily when reading files in src/
```

### Loading Behavior

| Position | Loading | Implication |
|----------|---------|-------------|
| **Ancestor** (directory above CWD) | Immediate at startup | Always active, use for global rules |
| **Descendant** (directory below CWD) | Lazy, on file read | Only active when working in that directory |
| **Sibling** (parallel directory) | Never | frontend/ rules won't see backend/ rules |

### Design Implications

- **Shared conventions** (code style, git rules, security) go in root CLAUDE.md
- **Package-specific conventions** (framework patterns, local commands) go in package CLAUDE.md
- **Don't assume sibling loading** -- if both frontend and backend need a rule, put it in the common ancestor

## Workspace Organization

### Root CLAUDE.md Template

```markdown
# CLAUDE.md

## Workspace Overview
Monorepo containing [N] packages: [brief list]. Uses [pnpm/npm/yarn] workspaces.

## Common Commands
- Install all: `pnpm install`
- Build all: `pnpm -r build`
- Test all: `pnpm -r test`
- Lint all: `pnpm -r lint`

## Shared Conventions
- [Language rules that apply to ALL packages]
- [Git conventions]
- [Formatting standards]

## Package Map
| Package | Path | Stack | Port |
|---------|------|-------|------|
| Frontend | packages/frontend | React, Vite | 3000 |
| Backend | packages/backend | FastAPI | 8000 |
| Shared | packages/shared | TypeScript | - |
```

### Package CLAUDE.md Template

```markdown
# CLAUDE.md

## Package: [name]
[1 sentence description]

## Commands
- Dev: `pnpm dev`
- Test: `pnpm test`
- Build: `pnpm build`

## Conventions
[Package-specific patterns, architecture, conventions]

## Dependencies
- Depends on: `@workspace/shared` for types
- Consumed by: `@workspace/frontend` for API types
```

## Cross-Package Dependencies

### Dependency Graph Awareness

```
When modifying shared packages:
1. Identify all consumers: `grep -r "@workspace/shared" packages/*/package.json`
2. Check if changes break consumers
3. Update consumers if interfaces changed
4. Run tests in ALL affected packages, not just the one you modified
```

### Change Propagation

| Change in... | Also Check... |
|-------------|--------------|
| Shared types | All packages that import them |
| API contracts | Frontend consumers |
| Database schema | Backend + any direct DB consumers |
| Build config | All packages using shared config |
| Root tooling | All packages (lint, format, test config) |

## Workspace Tool Patterns

### pnpm Workspaces

```bash
# Run command in specific package
pnpm --filter frontend dev

# Run in all packages
pnpm -r test

# Add dependency to specific package
pnpm --filter backend add fastapi

# Add shared dev dependency to root
pnpm add -D -w typescript
```

### npm Workspaces

```bash
npm run dev --workspace=packages/frontend
npm run test --workspaces
npm install express --workspace=packages/backend
```

## Multi-Project Claude Code Patterns

### Focused Work

When working on one package:
1. Claude loads root CLAUDE.md (ancestor -- immediate)
2. Claude loads package CLAUDE.md (descendant -- when reading files there)
3. Sibling packages' rules are NOT loaded
4. If you need cross-package awareness, state it in the prompt

### Cross-Package Changes

When changes span packages:
1. Plan the change order (dependencies first)
2. Work on shared/core packages first
3. Then work on consumers
4. Run cross-package tests after all changes

## .claude/rules/ for Detailed Rules

When root CLAUDE.md exceeds 200 lines, split into rules:

```
.claude/
├── rules/
│   ├── git-safety.md        # Git conventions
│   ├── security.md          # Security rules
│   ├── frontend.md          # Frontend patterns
│   ├── backend.md           # Backend patterns
│   └── testing.md           # Test conventions
```

Rules files are loaded alongside CLAUDE.md and help keep each file focused.

## Anti-Patterns

| Anti-Pattern | Problem | Do Instead |
|-------------|---------|-----------|
| All rules in one 500-line CLAUDE.md | Rules get ignored beyond ~200 lines | Split into root + package + rules/ |
| Package rules in wrong CLAUDE.md | Sibling packages don't load each other's rules | Put shared rules in common ancestor |
| No root CLAUDE.md | No shared conventions enforced | Always have a root CLAUDE.md |
| Duplicating rules across packages | Drift and maintenance burden | Shared rules in root, package-specific locally |
| Ignoring cross-package dependencies | Breaking changes in shared code | Check consumers when modifying shared packages |
| Running tests only in changed package | Miss integration breakages | Run tests in all affected packages |
