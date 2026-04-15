# Claude Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Plugins](https://img.shields.io/badge/plugins-17-green.svg)](#plugins)
[![Version](https://img.shields.io/badge/version-4.0.0-orange.svg)](CHANGELOG.md)
[![CI](https://img.shields.io/github/actions/workflow/status/Sagargupta16/claude-skills/validate.yml?label=validate)](https://github.com/Sagargupta16/claude-skills/actions)

Custom Claude Code plugin marketplace with reusable skills, agents, and hooks for full-stack development, testing, API design, databases, CI/CD, Docker, security, performance, logging, refactoring, documentation, git workflows, open source contributions, and repository maintenance.

These plugins work with any project -- install the ones relevant to your stack.

## Plugins

### Development Essentials

| Plugin | Commands | Agents | Hooks | What It Does |
|--------|----------|--------|-------|-------------|
| **dev-workflow** | `/commit`, `/review`, `/test`, `/fix`, `/pr`, `/status`, `/check-pr` | code-reviewer, debugger | - | Everyday dev commands -- commit, review, test, fix, PR, status |
| **dev-rules** | _(auto-activates)_ | guardrail-checker | secret-guard, no-force-push, branch-guard | Guardrails: git safety, security, PR workflow, context optimization |

### Stack-Specific

| Plugin | Commands | Agents | Hooks | What It Does |
|--------|----------|--------|-------|-------------|
| **farm-stack** | `/scaffold-farm` | farm-scaffolder | - | FastAPI + React + MongoDB patterns, project scaffolding, config, Docker |
| **testing** | `/write-tests` | test-runner, test-generator | - | Test strategy, framework patterns (pytest, jest, go, cargo), mocking, coverage |
| **api-design** | `/design-api` | api-reviewer, api-scaffolder | - | REST API design -- URLs, status codes, error formats, pagination, auth |
| **database** | `/design-schema` | schema-reviewer | migration-guard | Schema design, migrations (Alembic, Prisma, Drizzle), indexing, optimization |
| **ci-cd** | `/setup-ci` | ci-fixer | - | GitHub Actions workflows, caching, matrix builds, release automation |
| **docker-deploy** | `/dockerize` | dockerfile-optimizer | - | Multi-stage Dockerfiles, compose patterns, image optimization, security |
| **deps-audit** | `/audit-deps` | dependency-auditor | - | Vulnerability scanning, outdated packages, unused deps, update strategies |

### General Purpose

| Plugin | Commands | Agents | Hooks | What It Does |
|--------|----------|--------|-------|-------------|
| **refactoring** | `/refactor` | refactorer | - | Code smell detection, extract/rename/move, migration patterns (JS->TS, CJS->ESM) |
| **documentation** | `/write-docs` | doc-generator | - | README, ADR, changelog, API docs, technical spec generation |
| **git-advanced** | `/resolve-conflict` | git-assistant | commit-lint | Rebase, cherry-pick, bisect, stash, conflict resolution, undo |
| **performance** | `/optimize` | performance-profiler | - | Profiling, caching, N+1 detection, bundle analysis, benchmarking |
| **security-hardening** | `/security-audit` | security-scanner | secret-scanner | OWASP top 10, security headers, rate limiting, input validation |
| **logging-observability** | `/setup-logging` | observability-checker | debug-log-check | Structured logging, health checks, error tracking, metrics |

### Open Source and Maintenance

| Plugin | Commands | Agents | Hooks | What It Does |
|--------|----------|--------|-------|-------------|
| **oss-contrib** | `/sync-upstream`, `/prep-pr` | pr-analyzer | upstream-sync-check | Fork sync, upstream compliance, code style matching, PR preparation |
| **repo-polish** | `/polish-repo` | repo-auditor | - | .gitignore, .env.example, README, LICENSE generation, secret detection |

## Component Types

| Type | Count | What It Does |
|------|-------|-------------|
| **Skills** | 17 | Background knowledge that auto-activates based on context |
| **Commands** | ~20 | User-invocable slash commands (`/commit`, `/test`, etc.) |
| **Agents** | 20 | Autonomous sub-conversations for code review, debugging, scanning, etc. |
| **Hooks** | 8 | Shell scripts that auto-execute on events (block secrets, validate commits, etc.) |

## Installation

### Add the full marketplace

```
/plugin marketplace add Sagargupta16/claude-skills
```

### Install individual plugins

```
/plugin install dev-workflow@sagar-dev-skills
/plugin install dev-rules@sagar-dev-skills
/plugin install farm-stack@sagar-dev-skills
/plugin install testing@sagar-dev-skills
/plugin install api-design@sagar-dev-skills
/plugin install database@sagar-dev-skills
/plugin install ci-cd@sagar-dev-skills
/plugin install docker-deploy@sagar-dev-skills
/plugin install deps-audit@sagar-dev-skills
/plugin install oss-contrib@sagar-dev-skills
/plugin install repo-polish@sagar-dev-skills
/plugin install refactoring@sagar-dev-skills
/plugin install documentation@sagar-dev-skills
/plugin install git-advanced@sagar-dev-skills
/plugin install performance@sagar-dev-skills
/plugin install security-hardening@sagar-dev-skills
/plugin install logging-observability@sagar-dev-skills
```

## Structure

```
claude-skills/
├── .claude-plugin/
│   └── marketplace.json
├── .github/
│   └── workflows/
│       └── validate.yml
├── scripts/
│   └── validate-plugins.sh
├── plugins/
│   ├── dev-workflow/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/dev-workflow/SKILL.md
│   │   ├── commands/{commit,review,test,fix,pr,status,check-pr}.md
│   │   └── agents/{code-reviewer,debugger}.md
│   ├── dev-rules/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/dev-rules/SKILL.md
│   │   ├── agents/guardrail-checker.md
│   │   └── hooks/{secret-guard,no-force-push,branch-guard}.sh
│   ├── testing/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/testing/SKILL.md
│   │   ├── commands/write-tests.md
│   │   └── agents/{test-runner,test-generator}.md
│   └── ... (14 more plugins with same structure)
├── configs/
│   ├── settings.template.json
│   └── recommended-plugins.md
├── CODEOWNERS
├── CONTRIBUTING.md
├── CHANGELOG.md
└── README.md
```

## Language Support

| Language | dev-workflow | testing | farm-stack | api-design | database | ci-cd | docker-deploy | deps-audit | repo-polish |
|----------|-------------|---------|-----------|------------|----------|-------|---------------|------------|-------------|
| Python | Yes | Yes | Primary | Yes | Yes | Yes | Yes | Yes | Yes |
| Node.js | Yes | Yes | Frontend | Yes | Yes | Yes | Yes | Yes | Yes |
| Go | Yes | Yes | - | Yes | Yes | Yes | Yes | Yes | Yes |
| Rust | Yes | Yes | - | - | Yes | Yes | Yes | Yes | Yes |
| C# / Unity | Yes | - | - | - | - | - | - | - | Yes |

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
