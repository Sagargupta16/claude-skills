# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Claude Code plugin marketplace (`sagar-dev-skills`) containing 11 reusable plugins. Each plugin provides skills (background knowledge that auto-activates) and/or commands (user-invocable slash commands). This is a content-only repo -- no build system, no runtime code. All files are Markdown and JSON.

## Architecture

```
.claude-plugin/marketplace.json       # Plugin registry -- lists all plugins with metadata
plugins/{name}/
  ├── .claude-plugin/plugin.json      # Per-plugin manifest (name, description, version)
  ├── README.md                       # Plugin overview (for GitHub display)
  ├── skills/{name}/SKILL.md          # Skill definition (YAML frontmatter + Markdown body)
  ├── skills/{name}/references/       # Optional supplementary reference files
  └── commands/{cmd}.md               # Slash command definitions (YAML frontmatter + steps)
```

**marketplace.json** is the entry point. Uses `metadata.pluginRoot: "./plugins"` so each plugin's `source` is just its directory name. Each entry has `name`, `source`, `description`, `version`, `author`, `license`, `keywords`, and `category`. Claude Code reads this to discover available plugins.

**plugin.json** (at `.claude-plugin/plugin.json` inside each plugin) is the plugin manifest. With `strict: true` (the default), this file is the authority for component definitions. Skills and commands are auto-discovered from conventional `skills/` and `commands/` directories.

**SKILL.md frontmatter** follows a strict format:
```yaml
---
name: plugin-name
description: Use when [triggering conditions]. Covers [capabilities].
---
```
The description must start with "Use when..." -- this is how Claude Code decides when to activate the skill.

**Command frontmatter**:
```yaml
---
description: Short description of what the command does
user_invocable: true
---
```
Followed by numbered steps the AI agent executes.

## Validation

```bash
bash scripts/validate-plugins.sh
```

This checks: marketplace.json validity, plugin directory existence, SKILL.md frontmatter format, "Use when..." descriptions, file length limits, and command frontmatter. Also runs in CI via `.github/workflows/validate.yml`.

## Plugin Inventory

| Plugin | Type | Has Commands |
|--------|------|-------------|
| dev-workflow | skill + 7 commands | `/commit`, `/review`, `/test`, `/fix`, `/pr`, `/status`, `/check-pr` |
| dev-rules | skill only (auto-activates) | none |
| farm-stack | skill + 1 command | `/scaffold-farm` |
| testing | skill + 1 command | `/write-tests` |
| api-design | skill + 1 command | `/design-api` |
| database | skill + 1 command | `/design-schema` |
| ci-cd | skill + 1 command | `/setup-ci` |
| docker-deploy | skill + 1 command | `/dockerize` |
| deps-audit | skill + 1 command | `/audit-deps` |
| oss-contrib | skill + 2 commands | `/sync-upstream`, `/prep-pr` |
| repo-polish | skill + 1 command | `/polish-repo` |

## Key Conventions

- **Skill descriptions** always start with "Use when..." to define activation triggers
- **Quick Reference tables** go at the top of every SKILL.md for fast scanning
- **Anti-Patterns tables** show what NOT to do with a "Do Instead" column
- **SKILL.md target**: under 500 lines; split excess into `references/` subdirectory
- **No hardcoded usernames or paths** -- skills must be generic and work for any user
- **Language-agnostic where possible** -- most plugins support Python, Node.js, Go, Rust
- **Version numbers in code examples** include comments linking to upstream for freshness checks
- **One plugin per PR** when contributing

## Making Changes

When adding a new plugin:
1. Create `plugins/{name}/` with `.claude-plugin/plugin.json`, README.md, skills, and optional commands
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
