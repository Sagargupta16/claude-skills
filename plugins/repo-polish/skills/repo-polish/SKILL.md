---
name: repo-polish
description: Activates when polishing, auditing, or maintaining repositories. Handles .gitignore generation, .env.example creation, README writing, LICENSE addition, and general repo hygiene. Use when setting up new repos, auditing existing ones, or preparing repos for public visibility.
---

# Repository Polish Skill

## Audit Checklist

When polishing a repository, check each item:

| Item | Required | Check |
|------|----------|-------|
| `.gitignore` | Yes | Covers OS files, editor files, language artifacts, .env, secrets |
| `.env.example` | If .env used | Documents all env vars with placeholder values |
| `README.md` | Yes | Project name, description, setup, usage, tech stack |
| `LICENSE` | Yes | MIT for personal projects, match upstream for forks |
| No committed secrets | Critical | No .env, credentials, API keys in git history |

## Workflow

1. **Sync first**: Always `git pull` before making changes
2. **Audit**: Check what exists and what's missing
3. **Fix**: Create/update files as needed
4. **Commit**: Use conventional commits (`chore: add .gitignore and .env.example`)
5. **Push**: Push changes to remote

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
*.swp
*.swo
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
env/
.env
*.egg-info/
dist/
build/
.eggs/
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

### Unity / C# Games
```
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
[Ll]ogs/
[Uu]ser[Ss]ettings/
*.csproj
*.unityproj
*.sln
*.suo
*.tmp
*.user
*.userprefs
*.pidb
*.booproj
*.svd
*.pdb
*.mdb
*.opendb
*.VC.db
.DS_Store
Thumbs.db
```

### Academic / DSA
```
*.class
*.o
*.exe
*.out
__pycache__/
*.py[cod]
.ipynb_checkpoints/
.DS_Store
Thumbs.db
.vscode/
.idea/
```

## .env.example Generation

To create an accurate .env.example:

1. **Search for env var usage** in the codebase:
   - Node.js: `process.env.VAR_NAME`
   - Python: `os.environ["VAR"]`, `os.getenv("VAR")`, `dotenv`
   - Config files: YAML, JSON config loaders

2. **Write placeholders** -- never real values:
   ```
   DATABASE_URL=mongodb://localhost:27017/dbname
   JWT_SECRET=your-secret-key-here
   API_KEY=your-api-key-here
   PORT=3000
   ```

3. **Group by category** with comments:
   ```
   # Database
   MONGODB_URI=mongodb://localhost:27017/dbname

   # Authentication
   JWT_SECRET=your-secret-key-here

   # External APIs
   OPENAI_API_KEY=your-openai-api-key
   ```

## README Template

```markdown
# Project Name

Brief description of what this project does.

## Features

- Feature 1
- Feature 2

## Tech Stack

- Technology 1
- Technology 2

## Getting Started

1. Clone the repo:
   ```bash
   git clone https://github.com/Sagargupta16/repo-name.git
   cd repo-name
   ```

2. Install dependencies:
   ```bash
   npm install  # or pip install -r requirements.txt
   ```

3. Set up environment:
   ```bash
   cp .env.example .env
   # Edit .env with your values
   ```

4. Run:
   ```bash
   npm run dev  # or uvicorn main:app --reload
   ```

## License

MIT
```

Adapt based on the actual project type and features. Never write generic filler -- describe what the project actually does.

## LICENSE

Use MIT for personal projects:

```
MIT License

Copyright (c) 2024 Sagar Gupta

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

For forks: match the upstream project's license.

## Security Checks

Before pushing, verify:
- No `.env` files with real values are staged
- No API keys, passwords, or tokens in any file
- `config/secrets.yml` is git-ignored (FARM projects)
- `.env.example` contains only placeholders
- No MongoDB connection strings with real credentials

If real credentials are found in git history, they must be rotated immediately -- removing from future commits does not invalidate exposed secrets.
