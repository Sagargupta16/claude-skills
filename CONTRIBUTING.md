# Contributing

Contributions are welcome. Here's how to add or improve skills, agents, and hooks.

## Adding a New Plugin

1. Create the directory structure:
   ```
   plugins/your-plugin/
   ├── .claude-plugin/
   │   └── plugin.json
   ├── README.md
   ├── skills/your-plugin/
   │   └── SKILL.md
   ├── commands/           (optional)
   │   └── your-command.md
   ├── agents/             (optional)
   │   └── your-agent.md
   └── hooks/              (optional)
       └── your-hook.sh
   ```

2. Write the SKILL.md with proper frontmatter:
   ```yaml
   ---
   name: your-plugin
   description: Use when [specific triggering conditions]. Covers [what it handles].
   ---
   ```

3. Create `.claude-plugin/plugin.json`:
   ```json
   {
     "name": "your-plugin",
     "description": "Short description.",
     "version": "4.0.0"
   }
   ```
   Skills, commands, agents, and hooks are auto-discovered from their conventional directories.

4. Add the plugin to `.claude-plugin/marketplace.json` (source is just the directory name)

5. Update the README.md plugin table

6. Add a CHANGELOG.md entry

7. Run `bash scripts/validate-plugins.sh` to verify

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

## Agent Format

Agents are autonomous sub-conversations that handle complex, multi-step tasks. Place them in `plugins/{name}/agents/{agent-name}.md`.

```yaml
---
name: agent-name
description: "Use this agent to [purpose]. [When to use it].\n\nExamples:\n\n- User: \"...\"\n  Assistant: \"I'll launch the agent-name agent to ...\""
model: sonnet
---
```

Guidelines:
- **model**: Use `sonnet` for tasks requiring deep reasoning (code review, debugging, refactoring). Use `haiku` for fast/mechanical tasks (running tests, auditing files, scanning)
- **description**: Include examples showing user request and assistant response
- **body**: Define a clear process with numbered steps and an output format
- **naming**: Use kebab-case, descriptive names (e.g., `code-reviewer`, `test-runner`)

## Hook Format

Hooks are shell scripts that auto-execute on events. Place them in `plugins/{name}/hooks/{hook-name}.sh`.

Guidelines:
- **shebang**: Always start with `#!/usr/bin/env bash`
- **safety**: Always include `set -euo pipefail`
- **exit codes**: Exit 0 to allow the action, exit non-zero to block it
- **blocking vs warning**: Only block (exit 1) for genuinely dangerous operations (committing secrets, force pushing to main). Warn (exit 0 with message) for everything else
- **naming**: Use kebab-case, describe what the hook guards (e.g., `secret-guard`, `commit-lint`)
- **comments**: Include a header comment explaining the hook event and purpose

## Pull Request Guidelines

- One plugin per PR
- Include a description of what the skill covers and who it's for
- Test the skill by installing it locally before submitting
- Follow conventional commit format: `feat: add docker-deploy plugin`
