# Repo Polish Plugin

Repository hygiene - .gitignore, .env.example, README, LICENSE generation, and secret detection.

## Skills

- **repo-polish**: Audit checklist, .gitignore templates for Node.js/Python/Go/Rust/C#, .env.example generation, README template, LICENSE generation, and security checks.

## Commands

| Command | Description |
|---------|-------------|
| `/polish-repo` | Audit and fix missing hygiene files in the current repo |

## Agents

| Agent | Model | Description |
|-------|-------|-------------|
| `repo-auditor` | haiku | Full repository health audit -- README, LICENSE, .gitignore, CI, dependencies |

## Example

```
> /polish-repo

Detected: Python (FastAPI) from requirements.txt + main.py

Audit results:
  .gitignore    MISSING -- generated (Python template)
  .env.example  MISSING -- generated (found 8 env vars in code)
  README.md     EXISTS  -- OK
  LICENSE       MISSING -- generated (MIT)
  Secrets       CLEAN   -- no credentials found in git history
```

## Installation

```
/plugin install repo-polish@sagar-dev-skills
```
