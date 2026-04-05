---
name: dev-rules
description: Use when writing code, making git operations, handling secrets, reviewing PRs, or working with dependencies. Enforces git safety, security best practices, PR workflow discipline, and context-efficient development patterns. Auto-activates as guardrails.
---

# Development Rules and Guardrails

## Git Safety

| Rule | Why |
|------|-----|
| Never force push to main/master | Destroys team history, breaks CI |
| Never `git reset --hard` without confirmation | Irreversible data loss |
| Never amend published commits | Creates divergent history for collaborators |
| Never skip pre-commit hooks (`--no-verify`) | Hooks catch real issues |
| Stage specific files by name | `git add .` risks committing secrets or binaries |
| Never commit .env, credentials, API keys | Secrets in git history are permanent |
| Verify current branch before pushing | Avoid pushing to wrong branch |

## Security

### Secrets and Credentials
- Never commit `.env` files, API keys, tokens, passwords, or connection strings
- Always use `.env.example` with placeholder values, never real credentials
- If real credentials are found in git history, flag immediately - they must be rotated
- Add secret config files to `.gitignore` (e.g., `config/secrets.yml`)

### Code Security
- Validate all user input at system boundaries (API endpoints, form submissions)
- Use parameterized queries - never string concatenation for database queries
- Sanitize data before rendering in templates (prevent XSS)
- Use bcrypt or argon2 for password hashing, never MD5 or SHA for passwords
- Set CORS origins from environment variables, never wildcard in production

### Dependency Security
- Check for known vulnerabilities before adding new packages
- Prefer well-maintained packages with active security response
- Pin dependency versions in lock files

## PR Workflow

When working with pull requests:

1. **Always read comments first** before making changes
   - `gh api repos/{owner}/{repo}/issues/{num}/comments`
   - `gh api repos/{owner}/{repo}/pulls/{num}/comments`
2. **Check merge readiness** before acting
   - `gh api repos/{owner}/{repo}/pulls/{num} --jq '{mergeable, mergeable_state, draft}'`
3. **Check how far behind** the base branch
   - `gh api repos/{owner}/{repo}/compare/{base}...{head} --jq '{behind_by, ahead_by}'`
4. **After fixing/rebasing** - comment back on the PR summarizing what was done
5. **Before deleting a fork** - verify zero open PRs from that fork
6. **When rebasing** - squash into clean commits, match project's commit style
7. **Never force-push to someone else's branch** - only to your own fork branches

## Context Optimization

### Progressive Disclosure
- Load metadata first (names, descriptions) before full content
- Only read files when actually needed - don't preemptively read everything
- For long files, read specific sections rather than the entire file

### Scripts as Black Boxes
- Run helper scripts with `--help` first to understand their interface
- Only read script source code if `--help` is insufficient or if debugging
- Prefer calling tools over reading their implementation

### Efficient Patterns
- Present quick-reference tables upfront when multiple approaches exist
- Route to specific patterns based on the task at hand
- Don't load all reference material - load what's relevant

### Anti-Patterns
- Don't read every file in a directory when a targeted search suffices
- Don't duplicate work between main context and sub-agents
- Don't re-read files that were recently read in the same session
