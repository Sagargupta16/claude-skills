# Changelog

## [2.1.0] - 2026-04-05

### Added
- `dev-workflow` plugin: 7 everyday commands - `/commit`, `/review`, `/test`, `/fix`, `/pr`, `/status`, `/check-pr`
- `dev-rules` plugin: Auto-activating guardrails for git safety, security, PR workflow, and context optimization
- Anyone installing these plugins gets a complete dev setup via the marketplace - no manual config copying needed

## [2.0.0] - 2026-04-05

### Added
- `ci-cd` plugin: GitHub Actions workflow templates, caching, matrix builds, secrets management, release automation, and CI debugging
- `docker-deploy` plugin: Multi-stage Dockerfiles for Python/Node.js/Go/Rust, compose patterns, image optimization, health checks, and security hardening
- `deps-audit` plugin: Multi-language dependency auditing, vulnerability scanning, outdated package detection, and update strategies
- `CONTRIBUTING.md` with skill quality standards and PR guidelines
- Language support matrix in README
- Shields.io badges in README

### Changed
- All skill descriptions now use "Use when..." format following Anthropic quality standards
- `farm-stack`: Added anti-patterns table, Pydantic v2 model_config, non-root Docker user
- `oss-contrib`: Made generic (removed project-specific hardcoding), added stale PR management, improved fork recovery docs
- `repo-polish`: Removed hardcoded names from templates, added Go/Rust .gitignore templates, added project type detection table
- README overhauled with better plugin table, installation instructions, and structure diagram
- Bumped version to 2.0.0

### Removed
- `portfolio-updater` plugin (too user-specific, not reusable)

## [1.0.0] - 2026-03-16

- Fix stale portfolio path and LICENSE year

## [0.1.0] - 2026-03-14

- Initial Claude Code skills marketplace
- Skills: farm-stack, oss-contrib, repo-polish, portfolio-updater
