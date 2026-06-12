# Recommended Plugin Stack

A curated set of Claude Code plugins organized by use case. Start with the essentials and add more as needed.

## Tier 1: Essentials (install these first)

These give you a complete everyday dev workflow.

```
/plugin marketplace add Sagargupta16/claude-skills
/plugin install dev-workflow@sagar-dev-skills
/plugin install dev-rules@sagar-dev-skills
```

This gives you: `/commit`, `/review`, `/test`, `/fix`, `/pr`, `/status`, `/check-pr` + auto-activating guardrails for git safety and security. Also includes agents (code-reviewer, debugger, guardrail-checker) and hooks (secret-guard, no-force-push, branch-guard).

## Tier 2: Your Stack

Pick the plugins that match your tech stack.

```
# Full-stack web (FastAPI + React + MongoDB)
/plugin install farm-stack@sagar-dev-skills

# Docker
/plugin install docker-deploy@sagar-dev-skills

# Dependency management (vulnerabilities, outdated packages, Renovate)
/plugin install deps-audit@sagar-dev-skills
/plugin install renovate-triage@sagar-dev-skills
```

For testing, API design, database, CI/CD, documentation, performance, security, and observability needs, use the official Anthropic plugins and skills -- the overlapping plugins were removed from this marketplace in 5.0.0 to avoid duplication.

## Tier 3: General Purpose

Apply to any project regardless of stack.

```
# Code refactoring (smell detection, safe rename, migrations)
/plugin install refactoring@sagar-dev-skills

# Advanced git (rebase, cherry-pick, bisect, conflict resolution)
/plugin install git-advanced@sagar-dev-skills

# Context window health (compaction strategy, session management)
/plugin install context-management@sagar-dev-skills

# Plain-English diff summaries
/plugin install diff-explain@sagar-dev-skills

# Structured debugging from errors and stack traces
/plugin install debug-triage@sagar-dev-skills

# End-of-session review (capture corrections, preferences, decisions)
/plugin install starter-session-audit@sagar-dev-skills
```

## Tier 4: Open Source and Maintenance

For open source contributors and repo maintenance.

```
# Fork management and upstream compliance
/plugin install oss-contrib@sagar-dev-skills

# Repository hygiene (.gitignore, README, LICENSE)
/plugin install repo-polish@sagar-dev-skills
```

## Tier 5: Official Plugins (from claude-plugins-official)

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
