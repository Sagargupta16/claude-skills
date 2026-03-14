---
description: Scan repositories and update portfolio-react data files
user_invocable: true
---

Update the portfolio-react project data files based on current repository state.

Steps:
1. Read current `src/data/projects.json` from portfolio-react
2. Scan GitHub repos for new/updated projects:
   - Use `gh repo list Sagargupta16 --json name,description,url,updatedAt,topics,language --limit 100`
   - Compare with existing entries in projects.json
3. For open source contributions:
   - Use `gh search prs --author=Sagargupta16 --state=merged --limit=50`
   - Use `gh search prs --author=Sagargupta16 --state=open --limit=50`
   - Update `open_source_contributions` array with current status
4. Show proposed changes as a diff
5. If approved, update the JSON file
6. Validate: all ids unique, dates in "Month Year" format, URLs valid
7. Optionally run `npm run dev` to verify locally

Portfolio location: `c:/Code/GitHub/My Repos/portfolios/portfolio-react/`

Use the portfolio-updater skill for data format conventions.
