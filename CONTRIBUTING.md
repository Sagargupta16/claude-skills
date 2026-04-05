# Contributing

Contributions are welcome. Here's how to add or improve skills.

## Adding a New Plugin

1. Create the directory structure:
   ```
   plugins/your-plugin/
   ├── README.md
   ├── skills/your-plugin/
   │   └── SKILL.md
   └── commands/
       └── your-command.md
   ```

2. Write the SKILL.md with proper frontmatter:
   ```yaml
   ---
   name: your-plugin
   description: Use when [specific triggering conditions]. Covers [what it handles].
   ---
   ```

3. Add the plugin to `.claude-plugin/marketplace.json`

4. Update the README.md plugin table

5. Add a CHANGELOG.md entry

## Skill Quality Standards

- **Description**: Start with "Use when..." and describe triggering conditions, not workflow
- **Quick Reference table**: At the top for scanning
- **Anti-Patterns section**: What NOT to do and why
- **Language-agnostic where possible**: Support multiple ecosystems
- **No hardcoded usernames or paths**: Skills must work for anyone
- **Concise**: Keep SKILL.md under 500 lines, split into reference files if needed
- **Code examples**: One excellent example beats many mediocre ones

## Command Format

Commands use this frontmatter:
```yaml
---
description: Short description of what the command does
user_invocable: true
---
```

Follow with numbered steps that the AI agent will execute.

## Pull Request Guidelines

- One plugin per PR
- Include a description of what the skill covers and who it's for
- Test the skill by installing it locally before submitting
- Follow conventional commit format: `feat: add docker-deploy plugin`
