# Changelog

## [4.2.0] - 2026-04-18

### Added
- **7 new plugins** bringing total from 18 to 25, adding workflow and meta-development capabilities:
  - **context-management** -- context rot detection, compaction timing, branching strategy (Continue/Rewind/Clear/Compact/Subagent), sub-agent isolation patterns. Command: `/manage-context`. Agent: `context-advisor` (haiku).
  - **session-management** -- session lifecycle, handoff summaries, multi-session workflows, resume patterns. Command: `/handoff`. Agent: `session-advisor` (haiku).
  - **planning** -- plan mode usage, interview-then-execute, prototype over PRD, plan review. Command: `/plan`. Agent: `plan-reviewer` (sonnet).
  - **verification** -- pre-completion checklists for backend, frontend, infrastructure, and general code changes. Command: `/verify`. Agent: `verifier` (haiku).
  - **claude-md-generator** -- CLAUDE.md templates for Python, React, Terraform, MERN, Go, Rust, and monorepo. `<important>` tag patterns, loading rules. Command: `/scaffold-claude-md`. Agent: `claude-md-auditor` (haiku).
  - **infrastructure** -- Terraform, AWS CDK, CloudFormation best practices, module design, state management, security scanning (checkov, tflint). Command: `/infra-check`. Agent: `infra-reviewer` (sonnet).
  - **monorepo** -- CLAUDE.md loading rules (ancestor/descendant/sibling), workspace organization, cross-package dependencies, convention consistency. Command: `/workspace-check`. Agent: `workspace-auditor` (haiku).

### Changed
- **dev-rules**: Added CLAUDE.md authoring rules (`<important>` tag patterns, length/structure guidelines, conditional important tags), context health guidance (manual compact at 50%, rewind-over-correct, sub-agent isolation). Bumped to 4.2.0.
- **oss-contrib**: Added PR template compliance section (AI disclosure checkboxes, CLA/DCO signing, contributor statements, PR quality bar). Extended common pitfalls table. Bumped to 4.2.0.
- **methodology**: Added prototype-over-PRD workflow (when to prototype, pattern, when NOT to), interview-then-execute pattern (separate planning and execution sessions). Updated decision tree. Bumped to 4.2.0.
- **repo-polish**: Added CLAUDE.md audit checklist (length, structure, conventions, important tags, accuracy). Added Terraform/CDK to project type detection. Bumped to 4.2.0.
- **security-hardening**: Added STRIDE threat modeling table, supply chain security section (typosquatting, post-install scripts, CVE scanning), API security checklist. Extended anti-patterns. Bumped to 4.2.0.
- Marketplace version bumped to 4.2.0. All enhanced plugin plugin.json versions synced.
- README.md updated with new "Workflow and Meta" plugin category, updated counts, infrastructure in language matrix.
- CLAUDE.md plugin inventory table updated (25 plugins, ~28 commands, 29 agents, 9 hooks).
- reference.yaml updated with new plugins, skills, commands, agents, and decision entries.

## [4.1.0] - 2026-04-16

### Added
- **methodology plugin** -- new plugin with TDD, BDD, SDD, plan-driven, and context engineering workflows
  - Skill: decision tree for choosing the right methodology
  - Command: `/methodology` for guided workflow selection
  - Agent: `methodology-coach` (sonnet) for step-by-step execution guidance
- **auto-format hook** for dev-workflow -- detects project formatter (prettier, biome, black, ruff, gofmt, rustfmt, shfmt, terraform fmt) and runs it after file writes
- **threat-db.yaml** reference for security-hardening -- structured threat database with 12 secret patterns, 6 injection patterns, 3 auth weaknesses, 4 config issues, 4 prompt injection patterns, and 3 MCP risks
- **reference.yaml** at repo root -- AI-optimized index mapping keywords to plugin files, commands, agents, hooks, and references

### Changed
- **code-reviewer agent** now includes anti-hallucination verification protocol -- pattern verification with occurrence thresholds and confidence levels (Confirmed/Likely/Possible)
- **security-scanner agent** now includes verification protocol -- false positive prevention for secret detection, vulnerability path tracing, and dependency CVE version checks

## [4.0.0] - 2026-04-15

### Added
- **20 agents** across all 17 plugins for autonomous code review, debugging, test generation, security scanning, and more
  - dev-workflow: `code-reviewer` (sonnet), `debugger` (sonnet)
  - dev-rules: `guardrail-checker` (haiku)
  - testing: `test-runner` (haiku), `test-generator` (sonnet)
  - security-hardening: `security-scanner` (sonnet)
  - deps-audit: `dependency-auditor` (haiku)
  - ci-cd: `ci-fixer` (sonnet)
  - docker-deploy: `dockerfile-optimizer` (haiku)
  - git-advanced: `git-assistant` (sonnet)
  - oss-contrib: `pr-analyzer` (sonnet)
  - repo-polish: `repo-auditor` (haiku)
  - api-design: `api-reviewer` (sonnet), `api-scaffolder` (sonnet)
  - database: `schema-reviewer` (sonnet)
  - documentation: `doc-generator` (haiku)
  - logging-observability: `observability-checker` (haiku)
  - performance: `performance-profiler` (sonnet)
  - refactoring: `refactorer` (sonnet)
  - farm-stack: `farm-scaffolder` (sonnet)
- **8 hooks** across 6 plugins for automated safety guardrails
  - dev-rules: `secret-guard` (blocks commits with secrets), `no-force-push` (blocks force push to main), `branch-guard` (warns on direct main commits)
  - security-hardening: `secret-scanner` (warns on secrets in new files)
  - git-advanced: `commit-lint` (validates conventional commit format)
  - oss-contrib: `upstream-sync-check` (warns if fork behind upstream)
  - database: `migration-guard` (warns on destructive migrations)
  - logging-observability: `debug-log-check` (flags print/console.log in production code)
- Updated validation script to validate agents and hooks exist
- Updated CONTRIBUTING.md with agent and hook guidelines
- Updated CLAUDE.md with complete component architecture

### Changed
- Bumped all 17 plugins from 3.x to 4.0.0
- README.md now documents agents and hooks columns in plugin tables
- All plugin READMEs updated with agents and hooks sections

## [3.1.0] - 2026-04-05

### Added
- `refactoring` plugin: Code smell detection, extract/rename/move patterns, migration strategies (JS->TS, CJS->ESM), safe refactoring workflow, and `/refactor` command
- `documentation` plugin: README structure, ADRs, changelogs, code comment guidelines, docstring patterns, technical specs, and `/write-docs` command
- `git-advanced` plugin: Rebase workflows, cherry-pick, conflict resolution, bisect, stash management, undo operations, reflog recovery, and `/resolve-conflict` command
- `performance` plugin: Profiling workflow, caching strategies, N+1 detection, bundle optimization, connection pooling, benchmarking, and `/optimize` command
- `security-hardening` plugin: OWASP top 10 prevention, security headers, rate limiting, CORS, input validation, password hashing, and `/security-audit` command
- `logging-observability` plugin: Structured logging (structlog/pino/slog), health checks, request correlation IDs, error handling, metrics, and `/setup-logging` command
- Marketplace now has 17 plugins total

## [3.0.0] - 2026-04-05

### Added
- `testing` plugin: Test strategy, framework patterns (pytest, jest/vitest, go test, cargo test), mocking, fixtures, coverage guidance, and `/write-tests` command
- `api-design` plugin: REST API design patterns, URL structure, HTTP conventions, RFC 9457 error format, pagination, authentication, versioning, and `/design-api` command
- `database` plugin: Schema design for Postgres/MongoDB, migration tools (Alembic, Prisma, Drizzle, goose), indexing, query optimization, connection pooling, and `/design-schema` command
- `plugin.json` manifest for every plugin -- makes each plugin self-describing with explicit skill and command listings
- GitHub Actions CI workflow (`validate.yml`) that validates marketplace.json, plugin structure, and skill quality
- Validation script (`scripts/validate-plugins.sh`) enforcing CONTRIBUTING.md quality standards
- `CODEOWNERS` file for automatic PR review assignment
- Example sections in all plugin READMEs showing what each command does in practice
- `CLAUDE.md` for Claude Code context when working in this repo

### Changed
- Version comments added to all hardcoded runtime versions in farm-stack, ci-cd, and docker-deploy skills -- prevents silent staleness
- Base image table in docker-deploy now uses `<version>` placeholders instead of pinned numbers
- Removed `references/airflow.md` from oss-contrib (too project-specific for a generic marketplace)
- Updated oss-contrib SKILL.md to remove airflow reference
- Bumped version to 3.0.0

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
