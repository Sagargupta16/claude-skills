# Recommended Plugin Stack

A curated set of Claude Code plugins organized by use case. Start with the essentials and add more as needed.

## Tier 1: Essentials (install these first)

These give you a complete everyday dev workflow.

```
/plugin marketplace add Sagargupta16/claude-skills
/plugin install dev-workflow@sagar-dev-skills
/plugin install dev-rules@sagar-dev-skills
```

This gives you: `/commit`, `/review`, `/test`, `/fix`, `/pr`, `/status`, `/check-pr` + auto-activating guardrails for git safety and security.

## Tier 2: Your Stack

Pick the plugins that match your tech stack.

```
# Full-stack web (FastAPI + React + MongoDB)
/plugin install farm-stack@sagar-dev-skills

# Testing (pytest, jest/vitest, go test, cargo test)
/plugin install testing@sagar-dev-skills

# API design (REST conventions, error formats, pagination)
/plugin install api-design@sagar-dev-skills

# Database (schema design, migrations, indexing)
/plugin install database@sagar-dev-skills

# CI/CD (GitHub Actions)
/plugin install ci-cd@sagar-dev-skills

# Docker
/plugin install docker-deploy@sagar-dev-skills

# Dependency management
/plugin install deps-audit@sagar-dev-skills
```

## Tier 3: Open Source and Maintenance

For open source contributors and repo maintenance.

```
# Fork management and upstream compliance
/plugin install oss-contrib@sagar-dev-skills

# Repository hygiene (.gitignore, README, LICENSE)
/plugin install repo-polish@sagar-dev-skills
```

## Tier 4: Official Plugins (from claude-plugins-official)

Recommended official plugins that pair well with this marketplace:

| Plugin | Why |
|--------|-----|
| `superpowers` | Brainstorming, TDD, debugging, code review, planning workflows |
| `github` | GitHub integration for PRs, issues, actions |
| `pr-review-toolkit` | Comprehensive PR review with multiple analyzers |
| `context7` | Auto-fetch library documentation |
| `feature-dev` | Guided feature development workflow |
| `code-simplifier` | Code clarity and maintainability review |
| `playground` | Interactive HTML/JS prototyping |

### LSP Plugins (pick your languages)

| Language | Plugin |
|----------|--------|
| Python | `pyright-lsp` |
| TypeScript/JavaScript | `typescript-lsp` |
| Go | `gopls-lsp` |
| Rust | (no official LSP plugin yet) |

### Output Styles (optional)

| Style | What It Does |
|-------|-------------|
| `explanatory-output-style` | Educational insights with code |
| `learning-output-style` | Interactive learning + explanations |

## Template Settings

See [settings.template.json](settings.template.json) for a ready-to-use settings file with all recommended plugins pre-configured. Copy it to `~/.claude/settings.json` and customize.

## Tips

- **Don't enable everything** - each plugin adds tokens to every conversation
- **Start minimal** - add plugins as you need them
- **Check for overlaps** - some official plugins duplicate functionality (e.g., multiple code review plugins)
- **LSPs are per-language** - only enable the ones for languages you actively use
- **Never put secrets in settings.json** - use environment variables or a `.env` file instead
