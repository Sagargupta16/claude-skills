---
description: Audit and fix repository hygiene - .gitignore, .env.example, README, LICENSE
user_invocable: true
---

Audit the current repository and fix any missing or incomplete hygiene files.

Steps:
1. Sync from remote first: `git pull`
2. Detect the project type (Node.js, Python, Unity, academic, etc.)
3. Audit these files:
   - `.gitignore` -- exists? covers the right patterns for project type?
   - `.env.example` -- needed? (search for `process.env` or `os.getenv` usage)
   - `README.md` -- exists? has meaningful content (not just the repo name)?
   - `LICENSE` -- exists?
4. For each missing/incomplete item:
   - Generate appropriate content using the repo-polish skill templates
   - Show what will be created/changed
5. Check for committed secrets:
   - Search for `.env` files with real values
   - Search for hardcoded API keys or passwords
   - Flag any findings as critical
6. Stage specific files (never `git add .`)
7. Commit with: `chore: add missing repo hygiene files`
8. Show summary of all changes made

Use the repo-polish skill for all templates and patterns. Never commit .env files with real credentials.
