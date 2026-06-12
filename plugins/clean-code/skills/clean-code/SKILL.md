---
name: clean-code
description: Use when writing, fixing, editing, reviewing, refactoring, or debugging any Python code, names, comments/docstrings, functions, or tests. Applies the Boy Scout Rule plus Robert Martin's complete Clean Code catalog -- naming, functions, comments, DRY, boundary conditions, and tests.
when_to_use: |
  Also trigger on: "while you're at it", "any quick wins", "improve this a bit", "anything else obviously wrong"; single-letter or cryptic identifiers (`d`, `x`, `proc`), Hungarian notation (`str_name`, `lst_users`), `I`-prefixed classes, names hiding side effects, or asks like "rename this", "clearer name"; commented-out code blocks, TODO/FIXME banners, metadata in comments, redundant comments (`i += 1  # increment i`), stale docstrings; functions with 4+ parameters, boolean flag parameters, argument mutation, dead helpers, "too many arguments", "split this function"; duplicated logic (G5), magic numbers (G25), long if/elif chains (G23), train wrecks like `a.b.c.d` (G36), clever one-liners (G16); slow or flaky tests, skip-marked tests, happy-path-only tests, missing boundary cases, "coverage gap", "edge case", "did we test".
---

# Clean Code (Python)

> "Always leave the campground cleaner than you found it."
> — Robert Baden-Powell

> "Always check a module in cleaner than when you checked it out."
> — Robert C. Martin, *Clean Code*

## Rule Chapters

Load the chapter that matches the work. Rule IDs (N1, C5, G25, F3, T9...) are defined in these files:

| Chapter | When |
|---------|------|
| [references/full-catalog.md](references/full-catalog.md) | Reviewing any Python -- the complete rule index (master) |
| [references/names.md](references/names.md) | Naming variables, functions, classes, modules |
| [references/comments.md](references/comments.md) | Writing or editing comments and docstrings |
| [references/functions.md](references/functions.md) | Creating or refactoring functions |
| [references/general.md](references/general.md) | Code quality review -- DRY, intent, abstractions |
| [references/tests.md](references/tests.md) | Writing or reviewing tests |

## The Philosophy

You don't have to make every module perfect. You simply have to make it **a little bit better** than when you found it.

If we all followed this simple rule:
- Our systems would gradually get better as they evolved
- Teams would care for the system as a whole
- The relentless deterioration of software would end

## When Working on Code

Every time you touch code, look for **at least one small improvement**:

### Quick Wins (Do These Immediately)
- Rename a poorly named variable → [references/names.md](references/names.md)
- Delete a redundant comment → [references/comments.md](references/comments.md)
- Remove dead code or unused imports
- Replace a magic number with a named constant
- Extract a deeply nested block into a well-named function

### Deeper Improvements (When Time Allows)
- Split a function that does multiple things → [references/functions.md](references/functions.md)
- Remove duplication (DRY) → [references/general.md](references/general.md)
- Add missing boundary checks
- Improve test coverage → [references/tests.md](references/tests.md)

## The Rule in Practice

```python
# You're asked to fix a bug in this function:
def proc(d, x, flag=False):
    # process data
    for i in d:
        if i > 0:
            if flag:
                x.append(i * 1.0825)  # tax
            else:
                x.append(i)
    return x

# Don't just fix the bug and leave.
# Leave it cleaner:
TAX_RATE = 0.0825

def process_positive_values(
    values: list[float],
    apply_tax: bool = False
) -> list[float]:
    """Filter positive values, optionally applying tax."""
    rate = 1 + TAX_RATE if apply_tax else 1
    return [v * rate for v in values if v > 0]
```

**What changed:**
- ✅ Descriptive function name (N1)
- ✅ Clear parameter names (N1)
- ✅ Type hints (P3)
- ✅ Named constant for magic number (G25)
- ✅ No output argument mutation (F2)
- ✅ Useful docstring (C4)

## The Mindset

**Don't:**
- Leave code worse than you found it
- Say "that's not my code"
- Wait for a dedicated refactoring sprint
- Make massive changes unrelated to your task

**Do:**
- Make one small improvement with every commit
- Fix what you see, even if you didn't break it
- Keep changes proportional to your task
- Leave a trail of quality improvements

## AI Behavior

When working on code:
1. Complete the requested task first
2. Identify at least one small cleanup opportunity
3. Apply the appropriate rule chapter from the table above
4. Note the improvement made (e.g., "Also cleaned up: renamed `x` to `results` for clarity")

When reviewing code:
1. Load [references/full-catalog.md](references/full-catalog.md) for comprehensive rule checking
2. Flag violations by rule number
3. Suggest incremental improvements, not complete rewrites

## The Boy Scout Promise

Every piece of code you touch gets a little better. Not perfect—just better.

Over time, better compounds into excellent.
