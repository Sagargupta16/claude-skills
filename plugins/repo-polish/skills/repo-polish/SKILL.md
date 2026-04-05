---
name: repo-polish
description: Use when setting up new repositories, auditing existing ones, or preparing repos for public visibility. Generates .gitignore, .env.example, README, and LICENSE files. Detects committed secrets and flags security issues.
---

# Repository Polish

## Audit Checklist

| Item | Required | Check |
|------|----------|-------|
| `.gitignore` | Yes | Covers OS files, editor files, language artifacts, .env, secrets |
| `.env.example` | If .env used | Documents all env vars with placeholder values |
| `README.md` | Yes | Project name, description, setup, usage, tech stack |
| `LICENSE` | Yes | MIT for personal, match upstream for forks |
| No committed secrets | Critical | No .env, credentials, API keys in git history |

## Workflow

1. **Sync first**: `git pull` before making changes (skip for forks)
2. **Detect**: Identify project type from config files
3. **Audit**: Check what exists and what's missing
4. **Fix**: Create/update files using templates below
5. **Verify**: Search for committed secrets
6. **Commit**: `chore: add missing repo hygiene files`

## .gitignore Templates

### Node.js / React / Next.js
```
node_modules/
dist/
build/
.next/
.env
.env.local
.env.*.local
*.log
npm-debug.log*
.DS_Store
Thumbs.db
.vscode/
.idea/
coverage/
```

### Python / FastAPI / ML
```
__pycache__/
*.py[cod]
*$py.class
*.so
venv/
.venv/
.env
*.egg-info/
dist/
build/
.pytest_cache/
.coverage
htmlcov/
*.h5
*.pkl
*.model
*.weights
.ipynb_checkpoints/
.DS_Store
Thumbs.db
.vscode/
.idea/
```

### Go
```
bin/
vendor/
*.exe
*.test
*.out
.env
.DS_Store
Thumbs.db
.vscode/
.idea/
```

### Rust
```
target/
Cargo.lock
*.pdb
.env
.DS_Store
Thumbs.db
.vscode/
.idea/
```

### Unity / C#
```
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
[Ll]ogs/
[Uu]ser[Ss]ettings/
*.csproj
*.sln
*.suo
*.user
*.pdb
.DS_Store
Thumbs.db
```

## .env.example Generation

1. **Search for env var usage** in the codebase:
   - Node.js: `process.env.VAR_NAME`
   - Python: `os.environ["VAR"]`, `os.getenv("VAR")`, `dotenv`
   - Go: `os.Getenv("VAR")`
   - Config files: YAML, JSON, TOML loaders

2. **Write placeholders** - never real values:
   ```
   # Database
   DATABASE_URL=postgresql://localhost:5432/dbname

   # Authentication
   JWT_SECRET=your-secret-key-here

   # External APIs
   API_KEY=your-api-key-here
   ```

3. **Group by category** with comments.

## README Template

Adapt based on the actual project - never write generic filler.

```markdown
# Project Name

Brief description of what this project does and why.

## Features

- Feature 1
- Feature 2

## Tech Stack

- Technology 1
- Technology 2

## Getting Started

### Prerequisites

- Runtime version (e.g., Node.js 22+, Python 3.13+)

### Installation

1. Clone the repo
2. Install dependencies
3. Set up environment: `cp .env.example .env`
4. Run the project

## License

MIT
```

## LICENSE

Use MIT for personal projects (replace placeholders with actual values):

```
MIT License

Copyright (c) <YEAR> <YOUR NAME>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

For forks: always match the upstream project's license.

## Security Checks

Before pushing, verify:
- No `.env` files with real values are staged
- No API keys, passwords, or tokens in any file
- Secret config files (e.g., `secrets.yml`) are git-ignored
- `.env.example` contains only placeholders
- No database connection strings with real credentials

If real credentials are found in git history, they must be rotated immediately - removing from future commits does not invalidate exposed secrets.

## Project Type Detection

Detect the project type by checking for these files:

| File | Project Type |
|------|-------------|
| `package.json` | Node.js / React / Next.js |
| `requirements.txt` / `pyproject.toml` | Python |
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `*.csproj` / `*.sln` | C# / Unity |
| `Makefile` only | C / C++ |

Use the appropriate .gitignore template based on detected type. For multi-language projects, combine relevant templates.
