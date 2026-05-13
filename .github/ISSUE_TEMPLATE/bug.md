---
name: Bug report
about: A plugin misbehaves, a skill doesn't trigger, a hook breaks something, docs are wrong.
title: "bug: <short summary>"
labels: bug
---

## What's broken

<!-- Which plugin / skill / command / agent / hook. One sentence. -->

## Expected behavior

<!-- What should happen. -->

## Actual behavior

<!-- What happens instead. Paste error messages, unexpected output, or the wrong skill triggering. -->

## Reproduction

1. Install: `/plugin install <plugin>@sagar-dev-skills`
2. In a <project type> repo, do: ...
3. Observe: ...

## Environment

- Claude Code CLI version: <output of `claude --version`>
- OS: <macOS / Linux / WSL / Windows+bash>
- Marketplace version: <from `marketplace.json` metadata.version>

## Validator output (if applicable)

```
<paste `bash scripts/validate-plugins.sh` output if relevant>
```

## Additional context

<!-- Screenshots, logs, related issues. Delete if none. -->
