# monorepo

Monorepo management -- CLAUDE.md loading rules, workspace organization, cross-package dependency management, and multi-project convention patterns.

## Components

| Type | Name | Description |
|------|------|-------------|
| Skill | monorepo | Loading rules, workspace patterns, cross-package deps |
| Command | `/workspace-check` | Audit workspace health and CLAUDE.md coverage |
| Agent | workspace-auditor | Full workspace health audit |

## Key Concepts

- **CLAUDE.md loading**: Ancestors at startup, descendants lazily, siblings never
- **Root CLAUDE.md**: Shared conventions that apply to ALL packages
- **Package CLAUDE.md**: Package-specific rules, loaded only when working there
- **Cross-package changes**: Work dependency-first, test all affected packages

## Install

```bash
claude plugin add sagar-dev-skills/monorepo
```
