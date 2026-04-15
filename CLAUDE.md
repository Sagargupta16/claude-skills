# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Claude Code plugin marketplace (`sagar-dev-skills`) containing 17 reusable plugins. Each plugin provides skills (background knowledge that auto-activates), commands (user-invocable slash commands), agents (autonomous sub-conversations), and/or hooks (shell scripts that auto-execute on events). This is a content-only repo -- no build system, no runtime code. All files are Markdown, JSON, and shell scripts.

## Architecture

```
.claude-plugin/marketplace.json       # Plugin registry -- lists all plugins with metadata
plugins/{name}/
  ├── .claude-plugin/plugin.json      # Per-plugin manifest (name, description, version)
  ├── README.md                       # Plugin overview (for GitHub display)
  ├── skills/{name}/SKILL.md          # Skill definition (YAML frontmatter + Markdown body)
  ├── skills/{name}/references/       # Optional supplementary reference files
  ├── commands/{cmd}.md               # Slash command definitions (YAML frontmatter + steps)
  ├── agents/{agent}.md               # Agent definitions (YAML frontmatter + process)
  └── hooks/{hook}.sh                 # Hook scripts (bash, auto-execute on events)
```

### Component Types

| Type | Format | Required Fields | Purpose |
|------|--------|-----------------|---------|
| **Skill** | Markdown | name, description (must start with "Use when") | Background knowledge, auto-activates |
| **Command** | Markdown | description, user_invocable: true | User-invocable via `/command-name` |
| **Agent** | Markdown | name, description, model (haiku/sonnet) | Autonomous sub-conversation |
| **Hook** | Shell script | shebang, set -euo pipefail | Auto-executes on events |

### Key Format Details

**marketplace.json** is the entry point. Uses `metadata.pluginRoot: "./plugins"` so each plugin's `source` is just its directory name. Each entry has `name`, `source`, `description`, `version`, `author`, `license`, `keywords`, and `category`.

**SKILL.md frontmatter**:
```yaml
---
name: plugin-name
description: Use when [triggering conditions]. Covers [capabilities].
---
```

**Command frontmatter**:
```yaml
---
description: Short description of what the command does
user_invocable: true
---
```

**Agent frontmatter**:
```yaml
---
name: agent-name
description: "Use this agent to [purpose].\n\nExamples:\n\n- User: \"...\"\n  Assistant: \"...\""
model: sonnet
---
```
Model options: `haiku` (fast/mechanical tasks), `sonnet` (deep reasoning), `opus` (most capable).

**Hook scripts**: Must start with `#!/usr/bin/env bash` and `set -euo pipefail`. Exit 0 to allow, non-zero to block.

## Validation

```bash
bash scripts/validate-plugins.sh
```

This checks: marketplace.json validity, plugin directory existence, SKILL.md frontmatter format, "Use when..." descriptions, file length limits, command frontmatter, agent frontmatter (name/description/model), and hook structure (shebang, safety flags). Also runs in CI via `.github/workflows/validate.yml`.

## Plugin Inventory

| Plugin | Skills | Commands | Agents | Hooks |
|--------|--------|----------|--------|-------|
| dev-workflow | 1 | 7 | 2 (code-reviewer, debugger) | - |
| dev-rules | 1 | - | 1 (guardrail-checker) | 3 (secret-guard, no-force-push, branch-guard) |
| farm-stack | 1 | 1 | 1 (farm-scaffolder) | - |
| testing | 1 | 1 | 2 (test-runner, test-generator) | - |
| api-design | 1 | 1 | 2 (api-reviewer, api-scaffolder) | - |
| database | 1 | 1 | 1 (schema-reviewer) | 1 (migration-guard) |
| ci-cd | 1 | 1 | 1 (ci-fixer) | - |
| docker-deploy | 1 | 1 | 1 (dockerfile-optimizer) | - |
| deps-audit | 1 | 1 | 1 (dependency-auditor) | - |
| oss-contrib | 1 | 2 | 1 (pr-analyzer) | 1 (upstream-sync-check) |
| repo-polish | 1 | 1 | 1 (repo-auditor) | - |
| refactoring | 1 | 1 | 1 (refactorer) | - |
| documentation | 1 | 1 | 1 (doc-generator) | - |
| git-advanced | 1 | 1 | 1 (git-assistant) | 1 (commit-lint) |
| performance | 1 | 1 | 1 (performance-profiler) | - |
| security-hardening | 1 | 1 | 1 (security-scanner) | 1 (secret-scanner) |
| logging-observability | 1 | 1 | 1 (observability-checker) | 1 (debug-log-check) |

**Totals**: 17 skills, ~20 commands, 20 agents, 8 hooks

## Key Conventions

- **Skill descriptions** always start with "Use when..." to define activation triggers
- **Quick Reference tables** go at the top of every SKILL.md for fast scanning
- **Anti-Patterns tables** show what NOT to do with a "Do Instead" column
- **SKILL.md target**: under 500 lines; split excess into `references/` subdirectory
- **No hardcoded usernames or paths** -- skills must be generic and work for any user
- **Language-agnostic where possible** -- most plugins support Python, Node.js, Go, Rust
- **Version numbers in code examples** include comments linking to upstream for freshness checks
- **Agent model selection**: `sonnet` for reasoning-heavy tasks, `haiku` for fast/mechanical tasks
- **Hook exit codes**: exit 0 = allow (or warn only), exit non-zero = block the action
- **One plugin per PR** when contributing

## Making Changes

When adding a new plugin:
1. Create `plugins/{name}/` with `.claude-plugin/plugin.json`, README.md, skills, and optional commands/agents/hooks
2. Add the plugin entry to `.claude-plugin/marketplace.json` (source is just the directory name thanks to `pluginRoot`)
3. Update the README.md plugin tables and install commands
4. Add a CHANGELOG.md entry
5. Run `bash scripts/validate-plugins.sh` to verify
6. Use conventional commits: `feat: add {name} plugin`

When modifying an existing plugin:
- Keep the SKILL.md frontmatter `description` in sync with what the skill actually does
- Keep `.claude-plugin/plugin.json` version in sync with marketplace version
- Maintain the Quick Reference table if adding new capabilities
- Bump version in marketplace.json `metadata.version` for significant changes

## Additional Assets

- `configs/settings.template.json` -- ready-to-use Claude Code settings with all plugins enabled plus recommended official plugins
- `configs/recommended-plugins.md` -- tiered installation guide (essentials -> stack-specific -> OSS/maintenance -> official plugins)
- `CODEOWNERS` -- auto-assigns @Sagargupta16 for PR reviews
