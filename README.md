# Claude Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Plugins](https://img.shields.io/badge/plugins-16-green.svg)](#plugins)
[![Version](https://img.shields.io/badge/version-5.1.0-orange.svg)](CHANGELOG.md)
[![CI](https://github.com/Sagargupta16/claude-skills/actions/workflows/validate.yml/badge.svg)](https://github.com/Sagargupta16/claude-skills/actions)

Focused Claude Code plugin marketplace. 16 plugins covering everyday dev workflow, git, open-source contributions, Docker, dependency audits, repo hygiene, refactoring, FARM stack, context management, diff explanation, debug triage, Renovate triage, end-of-session audit, Python clean code, and animation/motion.

Plugins are individually installable. Pick the ones relevant to your stack.

## Philosophy

This marketplace encodes an opinionated workflow developed across 60+ repos and active open-source contributions: terse commits, scoped PRs, no force-pushes to main, no `git add .`, no `Co-Authored-By` trailers, real feature verification over "type-check passes," and a 7+/10 quality bar before opening upstream PRs.

Most plugins are language-agnostic and adapt to your stack (Python, Node, Go, Rust, etc.). A few are intentionally narrow:

- **`farm-stack`** -- FastAPI + React + MongoDB only. Skip if you're not on that stack.
- **`oss-contrib`** -- assumes GitHub + `gh` CLI.
- **`context-management`, `starter-session-audit`** -- about Claude Code itself. Useful if you use Claude Code. Not portable to other AI coding tools.

**5.0.0 cull:** this marketplace went from 25 plugins to 14 on 2026-05-13. Removed plugins that duplicated Anthropic-official skills (`planning`, `methodology`, `verification`), that sat idle (`api-design`, `testing`, `database`, `ci-cd`, `infrastructure`, `performance`, `security-hardening`, `logging-observability`), or that overlapped each other (`documentation`, `session-management`, `claude-md-generator`, `monorepo`). See [CHANGELOG.md](CHANGELOG.md) for the full list.

## Plugins

### Development Essentials

| Plugin | Commands | Agents | Hooks | What It Does |
|--------|----------|--------|-------|-------------|
| **dev-workflow** | `/commit`, `/review`, `/test`, `/fix`, `/pr`, `/status`, `/check-pr` | code-reviewer, debugger | auto-format | Everyday dev commands. Commands use `!` dynamic context injection for grounded first-attempt responses. |
| **dev-rules** | _(auto-activates)_ | guardrail-checker | secret-guard, no-force-push, branch-guard | Guardrails: git safety, security, PR workflow, context optimization, CLAUDE.md authoring |
| **refactoring** | `/refactor` | refactorer | - | Code smell detection, extract/rename/move, migration patterns (JS->TS, CJS->ESM) |
| **git-advanced** | `/resolve-conflict` | git-assistant | commit-lint | Rebase, cherry-pick, bisect, stash, conflict resolution, undo |
| **diff-explain** | _(skill only)_ | - | - | One-paragraph plain-English summary of a diff. Groups by concern, flags risks. |
| **debug-triage** | _(skill only)_ | - | - | Cause-fix-test triage from a pasted stack trace. No lectures. |
| **clean-code** | _(skill only)_ | - | - | Boy Scout Rule + Robert Martin's full Clean Code catalog for Python. Violations flagged by rule ID. |

### Stack-Specific

| Plugin | Commands | Agents | Hooks | What It Does |
|--------|----------|--------|-------|-------------|
| **farm-stack** | `/scaffold-farm` | farm-scaffolder | - | FastAPI + React + MongoDB patterns, project scaffolding, config, Docker |
| **docker-deploy** | `/dockerize` | dockerfile-optimizer | - | Multi-stage Dockerfiles, compose patterns, image optimization, security |
| **motion** | `/motion audit\|add\|fix` | - | - | Animation in three modes: 12-principles audit, add micro-interactions, fix jank |

### Security & Dependencies

| Plugin | Commands | Agents | Hooks | What It Does |
|--------|----------|--------|-------|-------------|
| **deps-audit** | `/audit-deps` | dependency-auditor | - | Vulnerability scanning, outdated packages, unused deps, update strategies |
| **renovate-triage** | _(skill only)_ | - | - | Batch-triage open Renovate PRs across all your repos into merge / close / defer |

### Open Source and Maintenance

| Plugin | Commands | Agents | Hooks | What It Does |
|--------|----------|--------|-------|-------------|
| **oss-contrib** | `/sync-upstream`, `/prep-pr` | pr-analyzer | upstream-sync-check | Fork sync, upstream compliance, CLA/DCO signing, AI disclosure, PR quality bar |
| **repo-polish** | `/polish-repo` | repo-auditor | - | .gitignore, .env.example, README, LICENSE generation, secret detection, CLAUDE.md auditing |

### Claude Code Meta

| Plugin | Commands | Agents | Hooks | What It Does |
|--------|----------|--------|-------|-------------|
| **context-management** | `/manage-context` | context-advisor | - | Context rot detection, compaction timing, branching strategy, sub-agent isolation |
| **starter-session-audit** | _(skill only)_ | - | - | End-of-session audit. Scans conversation for uncaptured corrections, preferences, decisions; proposes where to save each. |

## Component Types

| Type | Count | What It Does |
|------|-------|-------------|
| **Skills** | 16 | Background knowledge that auto-activates based on context |
| **Commands** | 16 | User-invocable slash commands (`/commit`, `/test`, etc.) |
| **Agents** | 11 | Autonomous sub-conversations for code review, debugging, scanning |
| **Hooks** | 6 | Shell scripts that auto-execute on events (block secrets, validate commits, etc.) |

## Installation

### Add the full marketplace

```text
/plugin marketplace add Sagargupta16/claude-skills
```

### Install individual plugins

```text
/plugin install dev-workflow@sagar-dev-skills
/plugin install dev-rules@sagar-dev-skills
/plugin install farm-stack@sagar-dev-skills
/plugin install docker-deploy@sagar-dev-skills
/plugin install deps-audit@sagar-dev-skills
/plugin install oss-contrib@sagar-dev-skills
/plugin install repo-polish@sagar-dev-skills
/plugin install refactoring@sagar-dev-skills
/plugin install git-advanced@sagar-dev-skills
/plugin install context-management@sagar-dev-skills
/plugin install diff-explain@sagar-dev-skills
/plugin install debug-triage@sagar-dev-skills
/plugin install renovate-triage@sagar-dev-skills
/plugin install starter-session-audit@sagar-dev-skills
/plugin install clean-code@sagar-dev-skills
/plugin install motion@sagar-dev-skills
```

## Structure

```text
claude-skills/
├── .claude-plugin/
│   └── marketplace.json
├── .github/
│   ├── workflows/validate.yml
│   ├── ISSUE_TEMPLATE/
│   └── pull_request_template.md
├── scripts/
│   └── validate-plugins.sh
├── plugins/
│   ├── dev-workflow/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/dev-workflow/SKILL.md
│   │   ├── commands/{commit,review,test,fix,pr,status,check-pr}.md
│   │   └── agents/{code-reviewer,debugger}.md
│   └── ... (13 more plugins with same structure)
├── configs/
│   ├── settings.template.json
│   └── recommended-plugins.md
├── CODEOWNERS
├── CONTRIBUTING.md
├── SECURITY.md
├── CHANGELOG.md
└── README.md
```

## Language Support

Plugins marked **Generic** are language-agnostic -- they work the same way in any stack.

### Stack-specific plugins

| Language | dev-workflow | farm-stack | docker-deploy | deps-audit | repo-polish |
|----------|-------------|-----------|---------------|------------|-------------|
| Python | Yes | Primary | Yes | Yes | Yes |
| Node.js | Yes | Frontend | Yes | Yes | Yes |
| Go | Yes | - | Yes | Yes | Yes |
| Rust | Yes | - | Yes | Yes | Yes |
| HCL/Terraform | - | - | - | - | Yes |

### Generic plugins (any language or no language)

| Plugin | Scope |
|---|---|
| **dev-rules** | Generic -- git safety, secrets, PR workflow, CLAUDE.md authoring |
| **refactoring** | Generic -- code smells, extract/rename/move across any language |
| **git-advanced** | Generic -- rebase, cherry-pick, bisect, conflict resolution |
| **oss-contrib** | Generic -- fork sync, upstream compliance, PR quality bar (assumes GitHub + `gh` CLI) |
| **diff-explain** | Generic -- PR / branch / diff summary |
| **debug-triage** | Generic -- stack trace triage |
| **renovate-triage** | Generic -- batch Renovate PR triage |
| **context-management** | Claude Code only -- context rot, compaction, sub-agent isolation |
| **starter-session-audit** | Claude Code only -- end-of-session audit for uncaptured learnings |

## Companion Plugins

These standalone plugin marketplaces complement this collection:

| Plugin | Install | What It Does |
|--------|---------|-------------|
| [claude-cost-optimizer](https://github.com/Sagargupta16/claude-cost-optimizer) | `/plugin marketplace add Sagargupta16/claude-cost-optimizer` | Cost-mode skill that saves 30-60% through concise responses, model routing, and budget hooks |

## Full Setup Guide

Want the complete curated Claude Code setup (plugins + permissions + recommended config)?

1. **Copy the template settings** to get started:
   - See [configs/settings.template.json](configs/settings.template.json) -- a ready-to-use settings file
   - Copy to `~/.claude/settings.json` and customize

2. **Read the recommended plugin stack** for a tiered approach:
   - See [configs/recommended-plugins.md](configs/recommended-plugins.md) -- organized by use case with tips

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding new skills, agents, or hooks.

## License

MIT
