---
name: portfolio-updater
description: Activates when updating portfolio website data, syncing project information, or managing the portfolio-react data files. Handles projects.json updates, achievement syncing, open source contribution tracking, and statistics maintenance. Use when adding new projects, updating existing entries, or refreshing portfolio data.
---

# Portfolio Data Updater

## Data Architecture

The portfolio site (`portfolio-react`) uses a data-driven design. All content lives in JSON files under `src/data/`:

```
src/data/
├── personal.json          # Bio, contact, social links
├── projects.json          # All project categories
├── skills.json            # Technical skills by category
├── experience.json        # Work history
├── education.json         # Academic info
├── achievements.json      # Certifications (Credly synced)
├── services.json          # Service offerings
├── contact.json           # Contact form config
└── dataLoader.ts          # Typed getter functions
```

Components consume this data via typed getters in `dataLoader.ts` -- they never hardcode content.

## projects.json Structure

Five categories of projects:

```json
{
  "featured_projects": [
    {
      "id": 15,
      "title": "Project Name",
      "description": "What the project does",
      "date": "January 2026",
      "tools_tech": ["React", "FastAPI", "MongoDB"],
      "features": ["Feature 1", "Feature 2"],
      "github": "https://github.com/Sagargupta16/repo-name",
      "live": "https://live-url.com"
    }
  ],
  "collaborative_projects": [
    {
      "id": 10,
      "title": "Project Name",
      "description": "...",
      "date": "March 2025",
      "tools_tech": ["React 19", "TypeScript", "Express"],
      "features": ["..."],
      "github": "https://github.com/org/repo",
      "live": "",
      "team": "Team Name",
      "organization": "NIT Warangal",
      "contributors": ["Person 1", "Person 2"]
    }
  ],
  "other_projects": [],
  "community_projects": [],
  "open_source_contributions": [
    {
      "repo": "org/project",
      "title": "PR Title",
      "url": "https://github.com/org/project/pull/123",
      "status": "merged"
    }
  ]
}
```

## Adding a New Project

1. Determine the correct category (featured, collaborative, other, community)
2. Assign the next sequential `id` number
3. Fill all required fields:
   - `title`: Project name
   - `description`: 1-2 sentences about what it does
   - `date`: Month Year format
   - `tools_tech`: Array of technologies used
   - `features`: Array of key features
   - `github`: GitHub URL (or empty string)
   - `live`: Live URL (or empty string if not deployed)
4. For collaborative projects, also add: `team`, `organization`, `contributors`

## Updating Open Source Contributions

When a PR is merged or a new contribution is made:

1. Read current `projects.json`
2. Find `open_source_contributions` array
3. Add new entry or update `status` field:
   - `"open"` -- PR is still under review
   - `"merged"` -- PR was accepted

To auto-detect contributions, use `gh` CLI:
```bash
# List PRs by user across repos
gh search prs --author=Sagargupta16 --state=merged --limit=50
gh search prs --author=Sagargupta16 --state=open --limit=50
```

## Updating Statistics

`personal.json` contains statistics that may need periodic updates:
- `coding_questions`: Total solved on LeetCode + GFG + other platforms
- `leetcode_rating`: Current LeetCode contest rating

## Deployment

The portfolio deploys to GitHub Pages:
- Domain: sagargupta.online
- Build: `npm run build` -> `dist/` directory
- Deploy: `gh-pages` branch or GitHub Actions

After updating data files:
1. Verify locally with `npm run dev`
2. Build: `npm run build`
3. Commit and push to trigger deployment

## Data Validation Rules

- `id` must be unique within each category
- `date` format: "Month Year" (e.g., "January 2026")
- `tools_tech` should use official names (e.g., "React" not "react", "FastAPI" not "fastapi")
- URLs must be full URLs starting with `https://`
- Empty URLs should be empty strings, not null
- `status` in open_source_contributions: only "merged" or "open"
