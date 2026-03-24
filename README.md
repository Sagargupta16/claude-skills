# Claude Skills

Custom Claude Code plugin marketplace with reusable skills for full-stack development, open source contributions, and repository maintenance.

These skills work with any project -- install the ones relevant to your stack.

## Plugins

| Plugin | Skills | Commands | Description |
|--------|--------|----------|-------------|
| `farm-stack` | farm-stack | `/scaffold-farm` | FastAPI + React + MongoDB patterns and scaffolding |
| `oss-contrib` | oss-contrib | `/sync-upstream`, `/prep-pr` | Open source contribution workflow and compliance |
| `repo-polish` | repo-polish | `/polish-repo` | Repository hygiene -- .gitignore, README, LICENSE, .env.example |
| `portfolio-updater` | portfolio-updater | `/update-portfolio` | Portfolio data file management and sync |

## Installation

### Add as marketplace

```
/plugin marketplace add Sagargupta16/claude-skills
```

### Install individual plugins

```
/plugin install farm-stack@sagar-dev-skills
/plugin install oss-contrib@sagar-dev-skills
/plugin install repo-polish@sagar-dev-skills
/plugin install portfolio-updater@sagar-dev-skills
```

## Structure

```
claude-skills/
├── .claude-plugin/
│   └── marketplace.json    # Marketplace definition
├── plugins/
│   ├── farm-stack/         # FARM stack development
│   │   ├── skills/farm-stack/SKILL.md
│   │   └── commands/scaffold-farm.md
│   ├── oss-contrib/        # Open source contributions
│   │   ├── skills/oss-contrib/SKILL.md
│   │   ├── skills/oss-contrib/references/airflow.md
│   │   └── commands/{sync-upstream,prep-pr}.md
│   ├── repo-polish/        # Repository hygiene
│   │   ├── skills/repo-polish/SKILL.md
│   │   └── commands/polish-repo.md
│   └── portfolio-updater/  # Portfolio data management
│       ├── skills/portfolio-updater/SKILL.md
│       └── commands/update-portfolio.md
└── README.md
```

## License

MIT
