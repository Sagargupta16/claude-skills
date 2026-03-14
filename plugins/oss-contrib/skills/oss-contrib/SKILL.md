---
name: oss-contrib
description: Activates when contributing to open source projects from forked repositories. Handles upstream sync, CONTRIBUTING.md compliance, code style matching, and project-specific patterns for Apache Airflow, ChromaDB, DSPy, Unsloth, and AWS MCP. Use when preparing PRs, syncing forks, or navigating upstream contribution workflows.
---

# Open Source Contribution Workflow

## Quick Reference

| Step | Action |
|------|--------|
| 1. Sync | `git fetch upstream && git merge upstream/main` |
| 2. Research | Read CONTRIBUTING.md, PR templates, CLA requirements |
| 3. Branch | Create feature branch from synced main |
| 4. Code | Match upstream style exactly -- no personal preferences |
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
   - Check for `CONTRIBUTING.md` in repo root
   - Check for `.github/PULL_REQUEST_TEMPLATE.md`
   - Check if CLA signing is required
   - Note required CI checks

3. **Create feature branch**
   ```bash
   git checkout -b fix/issue-description
   ```

4. **Scope the change**
   - Only modify files directly related to the issue
   - Never refactor or "improve" unrelated code
   - Never add features beyond what was requested

## Project-Specific Patterns

### Apache Airflow

Read [references/airflow.md](references/airflow.md) for detailed patterns.

Key rules:
- Template rendering tests: use `create_task_instance_of_operator` fixture, NOT `dag_maker`
- DB tests: mark with `@pytest.mark.db_test`
- PR template: AI disclosure checkbox is **required**
- Style: Follow their existing patterns exactly -- Airflow has very specific conventions
- Import sorting: Uses isort with their own config
- Type hints: Required on all new code

### ChromaDB (chroma-core/chroma)

- Rust + Python hybrid codebase
- Tests: `pytest` for Python, `cargo test` for Rust
- Error handling: Custom exception hierarchy -- match existing patterns
- PRs: Link to related issue, describe testing done

### DSPy (stanfordnlp/dspy)

- Python-heavy ML framework
- Tests: pytest with fixtures
- Documentation: Docstrings required on public APIs
- Type hints: Required

### Unsloth (unslothai/unsloth)

- ML/LLM fine-tuning library
- Heavy use of torch and transformers
- Match their optimization patterns

### AWS MCP (awslabs/mcp)

- Contributor statement must include exact license link text
- TypeScript + Python multi-language repo
- Follow their specific PR template

## Code Style Matching

The most important rule: **match the upstream project's style exactly**.

This means:
- Same indentation (spaces vs tabs, 2 vs 4)
- Same quote style (single vs double)
- Same import ordering
- Same naming conventions (snake_case vs camelCase)
- Same test patterns and fixtures
- Same docstring format
- Same error handling patterns

Do NOT apply personal preferences. Do NOT run your own formatters unless they match upstream's config.

## PR Best Practices

1. **Title**: Match their convention (e.g., Airflow uses `[component] Description`)
2. **Description**: Fill every section of their PR template
3. **Commits**: Squash to clean history if they prefer, or keep atomic commits
4. **Tests**: Always include tests -- match their test patterns exactly
5. **Scope**: Keep PRs focused -- one logical change per PR
6. **CI**: Ensure all required checks pass before requesting review

## Common Pitfalls

- Forgetting to sync upstream before branching (leads to merge conflicts)
- Applying personal code style instead of matching upstream
- Modifying files outside the scope of the fix
- Missing required PR template fields
- Not running the full test suite locally before pushing
- Adding Co-Authored-By trailers (never do this)

## Fork Recovery

If fork relationship is broken (e.g., repo was made private then public):
1. Clone the branch with your changes
2. Delete the broken fork on GitHub
3. Re-fork from upstream
4. Push your branch to the fresh fork
5. Create new PR
