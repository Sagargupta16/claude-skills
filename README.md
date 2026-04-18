# Claude Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Plugins](https://img.shields.io/badge/plugins-25-green.svg)](#plugins)
[![Version](https://img.shields.io/badge/version-4.2.0-orange.svg)](CHANGELOG.md)
[![CI](https://img.shields.io/github/actions/workflow/status/Sagargupta16/claude-skills/validate.yml?label=validate)](https://github.com/Sagargupta16/claude-skills/actions)

Custom Claude Code plugin marketplace with reusable skills, agents, and hooks for full-stack development, testing, API design, databases, CI/CD, Docker, security, performance, logging, refactoring, documentation, git workflows, open source contributions, repository maintenance, context management, session management, planning, verification, CLAUDE.md generation, infrastructure as code, and monorepo management.

These plugins work with any project -- install the ones relevant to your stack.

## Plugins

### Development Essentials

| Plugin | Commands | Agents | Hooks | What It Does |
|--------|----------|--------|-------|-------------|
| **dev-workflow** | `/commit`, `/review`, `/test`, `/fix`, `/pr`, `/status`, `/check-pr` | code-reviewer, debugger | auto-format | Everyday dev commands -- commit, review, test, fix, PR, status |
| **dev-rules** | _(auto-activates)_ | guardrail-checker | secret-guard, no-force-push, branch-guard | Guardrails: git safety, security, PR workflow, context optimization, CLAUDE.md authoring |

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
| **infrastructure** | `/infra-check` | infra-reviewer | - | Terraform, AWS CDK, CloudFormation -- module design, state management, security scanning |

### General Purpose

| Plugin | Commands | Agents | Hooks | What It Does |
|--------|----------|--------|-------|-------------|
| **refactoring** | `/refactor` | refactorer | - | Code smell detection, extract/rename/move, migration patterns (JS->TS, CJS->ESM) |
| **documentation** | `/write-docs` | doc-generator | - | README, ADR, changelog, API docs, technical spec generation |
| **git-advanced** | `/resolve-conflict` | git-assistant | commit-lint | Rebase, cherry-pick, bisect, stash, conflict resolution, undo |
| **performance** | `/optimize` | performance-profiler | - | Profiling, caching, N+1 detection, bundle analysis, benchmarking |
| **security-hardening** | `/security-audit` | security-scanner | secret-scanner | OWASP top 10, STRIDE threat modeling, supply chain security, API security |
| **logging-observability** | `/setup-logging` | observability-checker | debug-log-check | Structured logging, health checks, error tracking, metrics |

### Open Source and Maintenance

| Plugin | Commands | Agents | Hooks | What It Does |
|--------|----------|--------|-------|-------------|
| **oss-contrib** | `/sync-upstream`, `/prep-pr` | pr-analyzer | upstream-sync-check | Fork sync, upstream compliance, CLA/DCO signing, AI disclosure, PR quality bar |
| **repo-polish** | `/polish-repo` | repo-auditor | - | .gitignore, .env.example, README, LICENSE generation, secret detection, CLAUDE.md auditing |

### Workflow and Meta

| Plugin | Commands | Agents | Hooks | What It Does |
|--------|----------|--------|-------|-------------|
| **methodology** | `/methodology` | methodology-coach | - | TDD, BDD, SDD, plan-driven, prototype-over-PRD, interview-then-execute |
| **context-management** | `/manage-context` | context-advisor | - | Context rot detection, compaction timing, branching strategy, sub-agent isolation |
| **session-management** | `/handoff` | session-advisor | - | Session lifecycle, handoff summaries, multi-session workflows, resume patterns |
| **planning** | `/plan` | plan-reviewer | - | Plan mode, interview-then-execute, prototype over PRD, plan review |
| **verification** | `/verify` | verifier | - | Pre-completion checklists for backend, frontend, infra, and general changes |
| **claude-md-generator** | `/scaffold-claude-md` | claude-md-auditor | - | CLAUDE.md templates for 7 stacks, loading rules, `<important>` tag patterns |
| **monorepo** | `/workspace-check` | workspace-auditor | - | CLAUDE.md loading rules, workspace org, cross-package deps, convention consistency |

## Component Types

| Type | Count | What It Does |
|------|-------|-------------|
| **Skills** | 25 | Background knowledge that auto-activates based on context |
| **Commands** | ~28 | User-invocable slash commands (`/commit`, `/test`, `/verify`, etc.) |
| **Agents** | 29 | Autonomous sub-conversations for code review, debugging, scanning, etc. |
| **Hooks** | 9 | Shell scripts that auto-execute on events (block secrets, validate commits, etc.) |

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
/plugin install methodology@sagar-dev-skills
/plugin install context-management@sagar-dev-skills
/plugin install session-management@sagar-dev-skills
/plugin install planning@sagar-dev-skills
/plugin install verification@sagar-dev-skills
/plugin install claude-md-generator@sagar-dev-skills
/plugin install infrastructure@sagar-dev-skills
/plugin install monorepo@sagar-dev-skills
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
│   ├── context-management/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/context-management/SKILL.md
│   │   ├── commands/manage-context.md
│   │   └── agents/context-advisor.md
│   ├── verification/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/verification/SKILL.md
│   │   ├── commands/verify.md
│   │   └── agents/verifier.md
│   └── ... (21 more plugins with same structure)
├── configs/
│   ├── settings.template.json
│   └── recommended-plugins.md
├── CODEOWNERS
├── CONTRIBUTING.md
├── CHANGELOG.md
└── README.md
```

## Language Support

| Language | dev-workflow | testing | farm-stack | api-design | database | ci-cd | docker-deploy | deps-audit | infrastructure | repo-polish |
|----------|-------------|---------|-----------|------------|----------|-------|---------------|------------|---------------|-------------|
| Python | Yes | Yes | Primary | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Node.js | Yes | Yes | Frontend | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Go | Yes | Yes | - | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Rust | Yes | Yes | - | - | Yes | Yes | Yes | Yes | - | Yes |
| C# / Unity | Yes | - | - | - | - | - | - | - | - | Yes |
| HCL/Terraform | - | - | - | - | - | - | - | - | Primary | Yes |

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
