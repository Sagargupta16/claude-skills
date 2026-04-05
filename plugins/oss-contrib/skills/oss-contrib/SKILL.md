---
name: oss-contrib
description: Use when contributing to open source projects from forked repositories. Handles upstream sync, CONTRIBUTING.md compliance, code style matching, PR preparation, and project-specific patterns. Activates for fork management, PR template filling, and upstream workflow compliance.
---

# Open Source Contribution Workflow

## Quick Reference

| Step | Action |
|------|--------|
| 1. Sync | `git fetch upstream && git merge upstream/main` |
| 2. Research | Read CONTRIBUTING.md, PR templates, CLA requirements |
| 3. Branch | Create feature branch from synced default branch |
| 4. Code | Match upstream style exactly - no personal preferences |
| 5. Test | Run upstream's test suite, match their test patterns |
| 6. PR | Follow their PR template, fill all required fields |

## Pre-Contribution Checklist

Before writing any code:

1. **Sync fork with upstream**
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   git push origin main
   ```

2. **Read contribution guide**
   - `CONTRIBUTING.md` in repo root
   - `.github/PULL_REQUEST_TEMPLATE.md`
   - CLA/DCO signing requirements
   - Required CI checks and labels

3. **Create feature branch**
   ```bash
   git checkout -b fix/issue-description
   ```

4. **Scope the change**
   - Only modify files directly related to the issue
   - Never refactor or "improve" unrelated code
   - Never add features beyond what was requested

## Code Style Matching

**The most important rule: match the upstream project's style exactly.**

Before writing code, check:
- Indentation (spaces vs tabs, 2 vs 4)
- Quote style (single vs double)
- Import ordering and grouping
- Naming conventions (snake_case vs camelCase)
- Test patterns and fixtures
- Docstring format (Google, NumPy, Sphinx)
- Error handling patterns
- Linter/formatter config (`.editorconfig`, `pyproject.toml`, `.eslintrc`)

Do NOT apply personal preferences. Do NOT run your own formatters unless they match upstream's config.

## PR Best Practices

1. **Title**: Match upstream convention (check recent merged PRs for format)
2. **Description**: Fill every section of their PR template
3. **Commits**: Squash to clean history if they prefer, keep atomic if they prefer
4. **Tests**: Always include tests - match their test patterns exactly
5. **Scope**: One logical change per PR
6. **CI**: Ensure all required checks pass before requesting review

## Adding Project-Specific Patterns

Create reference files in `references/` for projects you regularly contribute to. Each file should document:
- Test fixture patterns and markers
- Import style and ordering rules
- PR template requirements
- Commit message format
- Any AI disclosure or CLA requirements

## Common Pitfalls

| Mistake | Prevention |
|---------|-----------|
| Forgetting to sync upstream before branching | Always `git fetch upstream` first |
| Applying personal code style | Run upstream's linter, check recent merged PRs |
| Modifying files outside fix scope | Review `git diff` before committing |
| Missing PR template fields | Read template file, fill every section |
| Not running full test suite locally | Run tests before pushing |
| Adding unnecessary refactoring | Keep changes minimal and focused |
| Ignoring CI failures | Fix all failures before requesting review |

## Fork Recovery

If fork relationship is broken (e.g., repo was made private then public):
1. Clone the branch with your changes locally
2. Delete the broken fork on GitHub
3. Re-fork from upstream
4. Push your branch to the fresh fork
5. Create new PR

## Stale PR Management

When PRs go unreviewed:
- Wait 1-2 weeks, then leave a polite ping comment
- If no response after 4 weeks, consider closing with a note
- Check if the maintainer is active on other PRs/issues
- Some projects have seasonal review cycles - check their activity patterns
