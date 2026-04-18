---
description: Audit monorepo workspace health -- CLAUDE.md coverage, cross-package deps, and conventions
user_invocable: true
---

Audit monorepo workspace health:

1. **CLAUDE.md coverage**:
   - Check if root CLAUDE.md exists and is under 200 lines
   - List packages with and without their own CLAUDE.md
   - Verify critical rules are wrapped in `<important>` tags
   - Check `.claude/rules/` for split rule files

2. **Cross-package dependencies**:
   - Map workspace package dependencies
   - Identify circular dependencies
   - Check if shared packages have proper exports

3. **Convention consistency**:
   - Compare linter/formatter configs across packages
   - Check for consistent test framework usage
   - Verify consistent package manager usage

4. **Workspace commands**:
   - Verify root-level scripts exist for build-all, test-all, lint-all
   - Check if `pnpm -r` / `npm --workspaces` commands work

5. Report findings and suggest improvements for workspace health
