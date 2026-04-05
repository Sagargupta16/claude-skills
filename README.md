# Claude Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Plugins](https://img.shields.io/badge/plugins-11-green.svg)](#plugins)
[![Version](https://img.shields.io/badge/version-3.0.0-orange.svg)](CHANGELOG.md)
[![CI](https://img.shields.io/github/actions/workflow/status/Sagargupta16/claude-skills/validate.yml?label=validate)](https://github.com/Sagargupta16/claude-skills/actions)

Custom Claude Code plugin marketplace with reusable skills for full-stack development, testing, API design, databases, CI/CD, Docker, dependency management, open source contributions, repository maintenance, and everyday dev workflows.

These skills work with any project -- install the ones relevant to your stack.

## Plugins

### Development Essentials

| Plugin | Commands | What It Does |
|--------|----------|-------------|
| **dev-workflow** | `/commit`, `/review`, `/test`, `/fix`, `/pr`, `/status`, `/check-pr` | Everyday dev commands -- commit, review, test, fix, PR, status |
| **dev-rules** | _(auto-activates)_ | Guardrails: git safety, security, PR workflow, context optimization |

### Stack-Specific

| Plugin | Commands | What It Does |
|--------|----------|-------------|
| **farm-stack** | `/scaffold-farm` | FastAPI + React + MongoDB patterns, project scaffolding, config, Docker |
| **testing** | `/write-tests` | Test strategy, framework patterns (pytest, jest, go, cargo), mocking, coverage |
| **api-design** | `/design-api` | REST API design -- URLs, status codes, error formats, pagination, auth |
| **database** | `/design-schema` | Schema design, migrations (Alembic, Prisma, Drizzle), indexing, optimization |
| **ci-cd** | `/setup-ci` | GitHub Actions workflows, caching, matrix builds, release automation |
| **docker-deploy** | `/dockerize` | Multi-stage Dockerfiles, compose patterns, image optimization, security |
| **deps-audit** | `/audit-deps` | Vulnerability scanning, outdated packages, unused deps, update strategies |

### Open Source and Maintenance

| Plugin | Commands | What It Does |
|--------|----------|-------------|
| **oss-contrib** | `/sync-upstream`, `/prep-pr` | Fork sync, upstream compliance, code style matching, PR preparation |
| **repo-polish** | `/polish-repo` | .gitignore, .env.example, README, LICENSE generation, secret detection |

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
│   ├── dev-workflow/              # Everyday dev commands
│   │   ├── plugin.json
│   │   ├── skills/dev-workflow/SKILL.md
│   │   └── commands/{commit,review,test,fix,pr,status,check-pr}.md
│   ├── dev-rules/                 # Development guardrails
│   │   ├── plugin.json
│   │   └── skills/dev-rules/SKILL.md
│   ├── farm-stack/                # FARM stack development
│   │   ├── plugin.json
│   │   ├── skills/farm-stack/SKILL.md
│   │   └── commands/scaffold-farm.md
│   ├── testing/                   # Test strategy and patterns
│   │   ├── plugin.json
│   │   ├── skills/testing/SKILL.md
│   │   └── commands/write-tests.md
│   ├── api-design/                # REST API design
│   │   ├── plugin.json
│   │   ├── skills/api-design/SKILL.md
│   │   └── commands/design-api.md
│   ├── database/                  # Database patterns
│   │   ├── plugin.json
│   │   ├── skills/database/SKILL.md
│   │   └── commands/design-schema.md
│   ├── ci-cd/                     # GitHub Actions CI/CD
│   │   ├── plugin.json
│   │   ├── skills/ci-cd/SKILL.md
│   │   └── commands/setup-ci.md
│   ├── docker-deploy/             # Docker and deployment
│   │   ├── plugin.json
│   │   ├── skills/docker-deploy/SKILL.md
│   │   └── commands/dockerize.md
│   ├── deps-audit/                # Dependency management
│   │   ├── plugin.json
│   │   ├── skills/deps-audit/SKILL.md
│   │   └── commands/audit-deps.md
│   ├── oss-contrib/               # Open source contributions
│   │   ├── plugin.json
│   │   ├── skills/oss-contrib/SKILL.md
│   │   └── commands/{sync-upstream,prep-pr}.md
│   └── repo-polish/               # Repository hygiene
│       ├── plugin.json
│       ├── skills/repo-polish/SKILL.md
│       └── commands/polish-repo.md
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

## Full Setup Guide

Want the complete curated Claude Code setup (plugins + permissions + recommended config)?

1. **Copy the template settings** to get started:
   - See [configs/settings.template.json](configs/settings.template.json) -- a ready-to-use settings file
   - Copy to `~/.claude/settings.json` and customize

2. **Read the recommended plugin stack** for a tiered approach:
   - See [configs/recommended-plugins.md](configs/recommended-plugins.md) -- organized by use case with tips

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding new skills or improving existing ones.

## License

MIT
