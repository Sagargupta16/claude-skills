---
description: Prepare a PR for an upstream open source project with proper template compliance
user_invocable: true
---

Prepare and validate a pull request for an upstream open source contribution.

Steps:
1. Check for CONTRIBUTING.md in the repo and read it
2. Check for `.github/PULL_REQUEST_TEMPLATE.md` and read it
3. Review all changes on the current branch vs main: `git diff main...HEAD`
4. Verify scope -- flag any files changed outside the intended fix area
5. Check if tests exist for the changes and if they pass
6. Generate a PR title matching the upstream convention
7. Generate a PR description filling all template fields
8. Check for CLA requirements
9. Show the prepared PR for review before creating

For Airflow specifically:
- Ensure AI disclosure checkbox is included
- Use `[component] Description` title format
- Verify template rendering tests use `create_task_instance_of_operator`

Do NOT create the PR automatically -- show the prepared content for user review first.
