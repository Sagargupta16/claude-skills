---
name: Plugin or skill request
about: Propose a new plugin, skill, command, agent, or hook.
title: "request: <plugin or capability name>"
labels: enhancement
---

## What should this do

<!-- One paragraph. The problem it solves and the situations it triggers in. -->

## Trigger conditions

<!-- When should Claude reach for this? Write it as a "Use when..." description. -->

Use when the user ...

## Scope

- **Kind**: `skill` / `command` / `agent` / `hook` / full `plugin`
- **Target plugin**: <existing plugin to extend, or "new plugin">
- **Ecosystems**: <Python / Node.js / Go / Rust / language-agnostic>
- **Similar existing plugins**: <list any that overlap, even partially>

## Sketch

<!-- Rough SKILL.md / command / agent content. Doesn't have to be final. -->

```markdown
---
name: example
description: Use when ...
---

# Example

## Quick Reference

| ... | ... |
```

## Why not an existing plugin

<!-- Explain why this can't just be added to dev-workflow, dev-rules, etc. -->

## Acceptance

- [ ] Skill description starts with "Use when ..."
- [ ] SKILL.md under 500 lines
- [ ] Language-agnostic or clearly scoped
- [ ] No overlap with an existing plugin (or clear story for the overlap)
