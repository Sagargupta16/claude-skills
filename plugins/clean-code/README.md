# clean-code

Auto-activating Clean Code discipline for Python. Combines the Boy Scout Rule ("leave the campground cleaner than you found it") with Robert C. Martin's complete rule catalog -- naming (N), comments (C), functions (F), general/DRY (G), and tests (T).

## What it does

- Activates whenever you write, fix, review, refactor, or debug Python
- Loads only the rule chapter that matches the work: names, comments, functions, general quality, or tests
- Flags violations by rule ID (N1, C5, G25, F3, T9...) so feedback is traceable to the catalog
- Pushes one small improvement per touch -- proportional cleanups, never drive-by rewrites

## Install

```
/plugin install clean-code@sagar-dev-skills
```

## Structure

| File | Purpose |
|------|---------|
| `skills/clean-code/SKILL.md` | Trigger conditions, philosophy, AI behavior |
| `skills/clean-code/references/full-catalog.md` | Master rule index |
| `skills/clean-code/references/names.md` | Naming rules (N) |
| `skills/clean-code/references/comments.md` | Comment and docstring rules (C) |
| `skills/clean-code/references/functions.md` | Function design rules (F) |
| `skills/clean-code/references/general.md` | DRY, intent, abstraction rules (G) |
| `skills/clean-code/references/tests.md` | Test quality rules (T) |
