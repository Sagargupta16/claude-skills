# verification

Pre-completion verification -- backend, frontend, infrastructure, and general code change checklists to run before claiming work is done or creating PRs.

## Components

| Type | Name | Description |
|------|------|-------------|
| Skill | verification | Verification checklists by change type |
| Command | `/verify` | Run pre-completion verification checks |
| Agent | verifier | Automated verification with pass/fail reporting |

## Key Concepts

- **Never claim done** based solely on type checks or linting -- verify the actual feature works
- **Backend**: Run server, hit endpoints, check error handling
- **Frontend**: Start dev server, test golden path AND edge cases in browser
- **Pre-PR checklist**: Tests, build, types, lint, no secrets, branch up to date

## Install

```bash
claude plugin add sagar-dev-skills/verification
```
