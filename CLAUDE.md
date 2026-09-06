# CLAUDE.md

> This file stacks on top of the workspace root at `C:\Code\GitHub\`:
> - Root [`CLAUDE.md`](../../CLAUDE.md) -- voice, rules, routing map, references, skills, slash commands, conventions.
> - Root [`MEMORY.md`](../../MEMORY.md) -- live facts across repos.
> - Root [`STATUS.md`](../../STATUS.md) -- live PR/CI/security dashboard.
> - [`.claude/resources/`](../../.claude/resources/README.md) -- deep reference for collaboration, workflow, git, OSS, debugging, voice.
>
> Read those first. The guidance below only adds **repo-specific context** -- it does not override anything in the root.


This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Claude Code plugin marketplace (`sagar-dev-skills`) containing 16 focused plugins. Each plugin provides skills (background knowledge that auto-activates), commands (user-invocable slash commands), agents (autonomous sub-conversations), and/or hooks (shell scripts that auto-execute on events). This is a content-only repo -- no build system, no runtime code. All files are Markdown, JSON, and shell scripts.

**5.0.0 cull (2026-05-13):** marketplace reduced from 25 -> 14 plugins. Removed plugins that duplicated Anthropic-official skills, sat unused, or overlapped each other. Added 4 promoted from local workspace: diff-explain, debug-triage, renovate-triage, starter-session-audit.

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
  ├── hooks/hooks.json                # Hook registration (event -> matcher -> script). Required for hooks to run
  └── hooks/{hook}.sh                 # Hook scripts (bash, read the tool call as JSON on stdin)
```

### Component Types

| Type | Format | Required Fields | Purpose |
|------|--------|-----------------|---------|
| **Skill** | Markdown | name, description (must start with "Use when") | Background knowledge, auto-activates |
| **Command** | Markdown | description (all fields optional) | User-invocable via `/command-name` |
| **Agent** | Markdown | name, description, model (haiku/sonnet) | Autonomous sub-conversation |
| **Hook** | Shell script + `hooks/hooks.json` | shebang, set -euo pipefail, an entry in hooks.json | Runs on tool events. Unregistered scripts never run |

### Key Format Details

**marketplace.json** is the entry point. Each plugin's `source` is a full relative path (`./plugins/{name}`) -- the CLI does not resolve `metadata.pluginRoot` on `plugin install`/`plugin update`, so bare directory names break. Each entry has `name`, `source`, `description`, `version`, `author`, `license`, `keywords`, and `category`.

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
user-invocable: true
---
```
Every field is optional. `user-invocable` is the hyphenated field name Claude Code documents and it already defaults to `true`, so this line is explicit rather than load-bearing. `user_invocable` is not a field Claude Code reads, so the validator errors on that spelling.

**Agent frontmatter**:
```yaml
---
name: agent-name
description: "Use this agent to [purpose].\n\nExamples:\n\n- User: \"...\"\n  Assistant: \"...\""
model: sonnet
---
```
Model options: `haiku` (fast/mechanical tasks), `sonnet` (deep reasoning). `opus` is accepted by the validator but unused in this marketplace -- prefer `sonnet` for reasoning-heavy work.

**Hook registration** (`hooks/hooks.json`, plugin wrapper format -- events nested under a `hooks` key):
```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [{ "type": "command", "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/secret-guard.sh\"" }] }
    ]
  }
}
```
This marketplace's hooks use `PreToolUse` and `PostToolUse` (there is no `PreToolCall`); `validate-plugins.sh` checks manifest keys against the [full event list](https://code.claude.com/docs/en/hooks#hook-events). Scripts are never auto-discovered -- an unregistered script is dead weight.

**Hook scripts**: Must start with `#!/usr/bin/env bash` and `set -euo pipefail`. The tool call arrives as JSON on **stdin** (`.hook_event_name`, `.tool_name`, `.tool_input.command`, `.tool_input.file_path`), not as arguments. A `Bash` matcher fires on every Bash call, so gate on the event, the tool, and then the command. Exit 0 = no decision, exit 2 = block (stderr is the reason Claude sees), any other code = non-blocking error. On tool events, exit-0 stdout only reaches the debug log, so a warn-only hook has to print a [`systemMessage`](https://code.claude.com/docs/en/hooks#json-output) JSON object to be seen at all.

## Validation

```bash
bash scripts/validate-plugins.sh
bash scripts/check-links.sh
```

`validate-plugins.sh` checks: marketplace.json validity, plugin directory existence, SKILL.md frontmatter format, "Use when..." descriptions, file length limits, command frontmatter (`user-invocable`, not `user_invocable`), agent frontmatter (name/description/model), and hook structure (shebang, safety flags, every script registered in a valid `hooks/hooks.json`, every manifest reference pointing at a script that exists, and every manifest key naming a real event). `check-links.sh` resolves every relative markdown link across tracked `*.md`, and reports how many targets it skipped for resolving outside the repo. Both run in CI via `.github/workflows/validate.yml`, alongside skillcheck.

## Plugin Inventory

| Plugin | Skills | Commands | Agents | Hooks |
|--------|--------|----------|--------|-------|
| dev-workflow | 1 | 7 | 2 (code-reviewer, debugger) | 1 (auto-format) |
| dev-rules | 1 | - | 1 (guardrail-checker) | 3 (secret-guard, no-force-push, branch-guard) |
| farm-stack | 1 | 1 | 1 (farm-scaffolder) | - |
| docker-deploy | 1 | 1 | 1 (dockerfile-optimizer) | - |
| deps-audit | 1 | 1 | 1 (dependency-auditor) | - |
| oss-contrib | 1 | 2 | 1 (pr-analyzer) | 1 (upstream-sync-check) |
| repo-polish | 1 | 1 | 1 (repo-auditor) | - |
| refactoring | 1 | 1 | 1 (refactorer) | - |
| git-advanced | 1 | 1 | 1 (git-assistant) | 1 (commit-lint) |
| context-management | 1 | 1 | 1 (context-advisor) | - |
| diff-explain | 1 | - | - | - |
| debug-triage | 1 | - | - | - |
| renovate-triage | 1 | - | - | - |
| starter-session-audit | 1 | - | - | - |
| clean-code | 1 | - | - | - |
| motion | 1 | - | - | - |

**Totals**: 16 skills, 16 commands, 11 agents, 6 hooks

## Key Conventions

- **Skill descriptions** always start with "Use when..." to define activation triggers
- **Quick Reference tables** go at the top of SKILL.md for fast scanning (convention per CONTRIBUTING.md; about half the skills have one, short promoted skills skip it)
- **Anti-Patterns tables** show what NOT to do with a "Do Instead" column
- **SKILL.md target**: under 500 lines; split excess into `references/` subdirectory
- **No hardcoded usernames or paths** -- skills must be generic and work for any user
- **Language-agnostic where possible** -- most plugins support Python, Node.js, Go, Rust
- **Version numbers in code examples** include comments linking to upstream for freshness checks
- **Agent model selection**: `sonnet` for reasoning-heavy tasks, `haiku` for fast/mechanical tasks
- **Hook exit codes**: exit 0 = allow (warn via a `systemMessage` JSON object, not a bare echo), exit 2 = block. `exit 1` is a non-blocking error, not a block
- **One plugin per PR** when contributing

## Making Changes

When adding a new plugin:
1. Create `plugins/{name}/` with `.claude-plugin/plugin.json`, README.md, skills, and optional commands/agents/hooks
2. Add the plugin entry to `.claude-plugin/marketplace.json` (source is the full relative path `./plugins/{name}`)
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