# claude-md-generator

CLAUDE.md file generation and auditing -- project-specific templates for Python, React, Terraform, MERN, Go, Rust, and monorepo workspaces with best-practice structure.

## Components

| Type | Name | Description |
|------|------|-------------|
| Skill | claude-md-generator | Templates, structure patterns, loading rules |
| Command | `/scaffold-claude-md` | Generate CLAUDE.md tailored to project stack |
| Agent | claude-md-auditor | Audit existing CLAUDE.md files for best practices |

## Key Concepts

- **Under 200 lines** per CLAUDE.md -- rules get ignored beyond this
- **`<important>` tags** for must-follow rules that shouldn't be skipped
- **Loading rules**: Ancestors load at startup, descendants lazily, siblings never
- **Stack-specific templates**: Python, React, Terraform, MERN, Go, Rust, Monorepo

## Install

```bash
claude plugin add sagar-dev-skills/claude-md-generator
```
