---
name: documentation
description: Use when writing or improving project documentation -- READMEs, API docs, architecture decision records (ADRs), changelogs, inline code comments, or technical specs. Covers documentation structure, writing style, and maintenance patterns.
---

# Documentation Patterns

## Quick Reference

| Task | Approach |
|------|----------|
| README | Project overview, setup, usage, contributing |
| API docs | OpenAPI spec or endpoint reference table |
| ADR | Title, status, context, decision, consequences |
| Changelog | Keep-a-changelog format, link to PRs/issues |
| Code comments | Explain WHY, not WHAT -- only for non-obvious logic |
| Technical spec | Problem, constraints, proposed solution, alternatives |

## README Structure

Every project README should answer these questions in order:

```markdown
# Project Name

What this project does (1-2 sentences).

## Features (optional, for larger projects)

## Getting Started

### Prerequisites
### Installation
### Configuration

## Usage

## API Reference (or link to docs)

## Contributing (or link to CONTRIBUTING.md)

## License
```

Rules:
- Lead with what it does, not how it's built
- Installation steps must be copy-pasteable
- Include the minimum viable example in Usage
- Don't document things that can be discovered by reading the code

## Architecture Decision Records (ADRs)

Use ADRs to document significant technical decisions.

```markdown
# ADR-001: Use PostgreSQL over MongoDB

## Status
Accepted (2026-03-15)

## Context
We need a database for the user management service.
The data is highly relational (users, roles, permissions).
Team has more SQL experience than NoSQL.

## Decision
Use PostgreSQL with SQLAlchemy ORM.

## Consequences
- Positive: Strong data integrity, complex queries are natural
- Positive: Team familiarity reduces ramp-up time
- Negative: Schema migrations required for changes
- Negative: Horizontal scaling is harder than MongoDB
```

Store in `docs/adr/` or `docs/decisions/`. Number sequentially. Never delete -- mark superseded ADRs with status "Superseded by ADR-XXX".

## Changelog

Follow [Keep a Changelog](https://keepachangelog.com) format:

```markdown
# Changelog

## [Unreleased]

## [1.2.0] - 2026-04-01

### Added
- User role management API endpoints

### Changed
- Improved error messages for validation failures

### Fixed
- Race condition in concurrent order processing

### Removed
- Deprecated v1 authentication endpoints
```

Categories: Added, Changed, Deprecated, Removed, Fixed, Security.

Rules:
- Write for humans, not machines
- Most recent version first
- Link version headers to git diffs or tags
- Every user-facing change gets an entry

## Code Comments

### When to Comment

| Comment | Not Comment |
|---------|------------|
| WHY a non-obvious approach was chosen | WHAT the code does (the code says that) |
| Business rules that aren't obvious from code | Obvious type annotations or variable names |
| Workarounds with links to issues/bugs | Every function or class |
| Performance justifications | Closing braces or end-of-block markers |
| Legal/compliance requirements | Commented-out code (delete it) |

### Good vs Bad Comments

```python
# BAD: restates the code
# Increment counter by 1
counter += 1

# GOOD: explains a non-obvious business rule
# Free shipping threshold is $50 before tax, per marketing agreement Q1-2026
if subtotal >= 5000:  # cents
    shipping = 0
```

### Docstrings

Only add docstrings to public APIs and non-obvious functions. Match the project's existing style:

**Python (Google style):**
```python
def calculate_shipping(weight: float, destination: str) -> int:
    """Calculate shipping cost in cents.

    Uses zone-based pricing from the carrier rate table.
    Returns 0 for orders qualifying for free shipping.

    Args:
        weight: Package weight in kg.
        destination: ISO 3166-1 country code.

    Returns:
        Shipping cost in cents.

    Raises:
        ValueError: If destination is not a supported country.
    """
```

**TypeScript (TSDoc):**
```typescript
/**
 * Calculate shipping cost in cents.
 *
 * Uses zone-based pricing from the carrier rate table.
 *
 * @param weight - Package weight in kg
 * @param destination - ISO 3166-1 country code
 * @returns Shipping cost in cents
 * @throws {Error} If destination is not supported
 */
```

## Technical Spec Template

For proposing significant changes before implementation:

```markdown
# Title

## Problem
What problem are we solving? Why now?

## Constraints
- Performance: must handle X requests/sec
- Compatibility: must work with existing Y
- Timeline: needed by Z date

## Proposed Solution
High-level approach with key design decisions.

## Alternatives Considered
| Option | Pros | Cons |
|--------|------|------|
| Option A | ... | ... |
| Option B | ... | ... |

## Implementation Plan
1. Step 1
2. Step 2
3. Step 3

## Open Questions
- Question 1?
- Question 2?
```

## Documentation Maintenance

| Rule | Why |
|------|-----|
| Update docs in the same PR as code changes | Docs drift when updated separately |
| Delete docs for removed features | Stale docs are worse than no docs |
| Date-stamp decisions and assumptions | Readers need to know if info is current |
| Link to source code, not copy it | Copied code goes stale immediately |
| Test setup instructions on a clean machine | "Works on my machine" docs help no one |

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Document every function/class | Only document public APIs and non-obvious logic |
| Write "self-documenting code" as excuse for zero docs | Document architecture, setup, and decisions |
| Keep commented-out code "for reference" | Delete it -- git history preserves it |
| Write docs after the project is "done" | Write alongside code, in the same PR |
| Copy-paste code into docs | Link to source files or use auto-generated docs |
| Use screenshots of text | Use actual text -- it's searchable and accessible |
