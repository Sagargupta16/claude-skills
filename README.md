# Claude Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Plugins](https://img.shields.io/badge/plugins-8-green.svg)](#plugins)
[![Version](https://img.shields.io/badge/version-2.1.0-orange.svg)](CHANGELOG.md)

Custom Claude Code plugin marketplace with reusable skills for full-stack development, CI/CD, Docker, dependency management, open source contributions, repository maintenance, and everyday dev workflows.

These skills work with any project - install the ones relevant to your stack.

## Plugins

### Development Essentials

| Plugin | Commands | What It Does |
|--------|----------|-------------|
| **dev-workflow** | `/commit`, `/review`, `/test`, `/fix`, `/pr`, `/status`, `/check-pr` | Everyday dev commands - commit, review, test, fix, PR, status |
| **dev-rules** | _(auto-activates)_ | Guardrails: git safety, security, PR workflow, context optimization |

### Stack-Specific

| Plugin | Commands | What It Does |
|--------|----------|-------------|
| **farm-stack** | `/scaffold-farm` | FastAPI + React + MongoDB patterns, project scaffolding, config, Docker |
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
├── plugins/
│   ├── dev-workflow/              # Everyday dev commands
│   │   ├── skills/dev-workflow/SKILL.md
│   │   └── commands/{commit,review,test,fix,pr,status,check-pr}.md
│   ├── dev-rules/                 # Development guardrails
│   │   └── skills/dev-rules/SKILL.md
│   ├── farm-stack/                # FARM stack development
│   │   ├── skills/farm-stack/SKILL.md
│   │   └── commands/scaffold-farm.md
│   ├── oss-contrib/               # Open source contributions
│   │   ├── skills/oss-contrib/SKILL.md
│   │   ├── skills/oss-contrib/references/airflow.md
│   │   └── commands/{sync-upstream,prep-pr}.md
│   ├── repo-polish/               # Repository hygiene
│   │   ├── skills/repo-polish/SKILL.md
│   │   └── commands/polish-repo.md
│   ├── ci-cd/                     # GitHub Actions CI/CD
│   │   ├── skills/ci-cd/SKILL.md
│   │   └── commands/setup-ci.md
│   ├── docker-deploy/             # Docker and deployment
│   │   ├── skills/docker-deploy/SKILL.md
│   │   └── commands/dockerize.md
│   └── deps-audit/                # Dependency management
│       ├── skills/deps-audit/SKILL.md
│       └── commands/audit-deps.md
├── CONTRIBUTING.md
├── CHANGELOG.md
└── README.md
```

## Language Support

| Language | dev-workflow | farm-stack | ci-cd | docker-deploy | deps-audit | repo-polish |
|----------|-------------|-----------|-------|---------------|------------|-------------|
| Python | Yes | Primary | Yes | Yes | Yes | Yes |
| Node.js | Yes | Frontend | Yes | Yes | Yes | Yes |
| Go | Yes | - | Yes | Yes | Yes | Yes |
| Rust | Yes | - | Yes | Yes | Yes | Yes |
| C# / Unity | Yes | - | - | - | - | Yes |

## Full Setup Guide

Want the complete curated Claude Code setup (plugins + permissions + recommended config)?

1. **Copy the template settings** to get started:
   - See [configs/settings.template.json](configs/settings.template.json) - a ready-to-use settings file
   - Copy to `~/.claude/settings.json` and customize

2. **Read the recommended plugin stack** for a tiered approach:
   - See [configs/recommended-plugins.md](configs/recommended-plugins.md) - organized by use case with tips

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding new skills or improving existing ones.

## License

MIT
