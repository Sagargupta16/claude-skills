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
       ├── hooks.json      (required if you ship any hook script)
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
   Skills, commands, and agents are auto-discovered from their conventional directories. Hook **scripts** are not -- they only run if `hooks/hooks.json` registers them (see [Hook Format](#hook-format)).

4. Add the plugin to `.claude-plugin/marketplace.json` with `source` as the full relative path (`./plugins/your-plugin`). A bare directory name breaks `plugin install` and `plugin update` because the CLI does not resolve `metadata.pluginRoot` -- see the 4.2.1 entry in [CHANGELOG.md](CHANGELOG.md). The validator accepts both forms for backwards compatibility, so it will not catch this for you.

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
user-invocable: true
---
```

The field is hyphenated: [`user-invocable`](https://code.claude.com/docs/en/slash-commands) is the documented name and `user_invocable` is not a field Claude Code reads. Both spellings happen to behave the same here because `user-invocable` defaults to `true`, but the underscore form is a silent typo, so the validator errors on it. Every field is optional; `description` is the one worth writing.

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

Hooks are shell scripts that Claude Code runs on tool events. Place the script in `plugins/{name}/hooks/{hook-name}.sh` and **register it in `plugins/{name}/hooks/hooks.json`**. A script that is not registered never runs, no matter where it sits.

### Registration

`hooks.json` uses the plugin wrapper format -- events nested under a top-level `hooks` key:

```json
{
  "description": "What these hooks do.",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/secret-guard.sh\"",
            "timeout": 20
          }
        ]
      }
    ]
  }
}
```

Always reference the script through `${CLAUDE_PLUGIN_ROOT}` so the path resolves wherever the plugin is installed. `matcher` is a case-sensitive regex over the tool name (`Bash`, `Write|Edit`, `*`).

The event name has to be one Claude Code dispatches. This marketplace only uses `PreToolUse` and `PostToolUse`; the full set is in the [hook events reference](https://code.claude.com/docs/en/hooks#hook-events), and `validate-plugins.sh` checks a manifest's keys against it. There is no `PreToolCall` or `PostToolCall`.

Hooks load at session start, so restart Claude Code after changing `hooks.json` or a script.

### Reading input

Claude Code passes the tool call as JSON on **stdin**, not as arguments. Read it with `jq`:

```bash
INPUT=$(cat || true)
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT" 2>/dev/null || true)   # Bash
FILE=$(jq -r '.tool_input.file_path // empty' <<<"$INPUT" 2>/dev/null || true) # Write/Edit
```

`.hook_event_name` and `.tool_name` are on the same payload. Check them, because a hook can be registered against more than one event and a `Bash` matcher fires on *every* Bash call:

```bash
[ "$(jq -r '.tool_name // empty' <<<"$INPUT")" = "Bash" ] || exit 0
```

Then gate on the command you actually care about. Matching the raw string is not enough -- `grep -rn "git commit" docs/` contains `git commit` and is read-only -- so split on shell separators and require the statement to *start* with the program:

```bash
while IFS= read -r segment; do
  segment="${segment#"${segment%%[![:space:]]*}"}"
  [[ "$segment" =~ ^git([[:space:]]|$) ]] || continue
  grep -qE '(^|[[:space:]])commit([[:space:]]|$)' <<<"$segment" && RUN=1
done < <(tr ';|&\n' '\n' <<<"$CMD")
```

### Exit codes

| Exit | Meaning |
| --- | --- |
| `0` | No decision. The tool call proceeds. |
| `2` | **Block.** On `PreToolUse` the call is prevented and stderr is the reason Claude sees. `PostToolUse` cannot block, but stderr still reaches Claude. |
| other | Non-blocking error. The tool call proceeds and the hook looks broken. |

`exit 1` does not block, despite being the conventional shell failure code. Use `exit 2` and write the reason to stderr.

### Warning without blocking

A warn-only hook cannot just `echo`. On `PreToolUse` and `PostToolUse`, [stdout from a hook that exits 0 goes to the debug log and is never shown](https://code.claude.com/docs/en/hooks#exit-code-0) -- only `UserPromptSubmit`, `UserPromptExpansion`, `SessionStart`, and `PostModelSwitch` surface it. To reach the user, exit 0 and print a [`systemMessage`](https://code.claude.com/docs/en/hooks#json-output) object, and nothing else, on stdout:

```bash
jq -n --arg msg "branch-guard: you are committing directly to '$BRANCH'." '{systemMessage: $msg}'
exit 0
```

Claude Code parses stdout as JSON only when it starts with `{` and ends with `}`, so any stray `echo` alongside it turns the whole thing back into ignored plain text.

### Guidelines

- **shebang**: Always start with `#!/usr/bin/env bash`
- **safety**: Always include `set -euo pipefail`, and make sure no expected-failure path (a missing formatter, an absent remote) trips it
- **blocking vs warning**: Only block (`exit 2`) for genuinely dangerous operations (committing secrets, force pushing to main). Warn (`exit 0` with a `systemMessage`) for everything else
- **judge the real target**: A guard has to inspect what the command would actually do, not a proxy for it. `no-force-push` reads the push refspec, not just the checked-out branch, because `git push --force origin main` from a feature branch is the dangerous case
- **degrade quietly**: If `jq` is missing the hook cannot read its input. Say so once in a `systemMessage` and `exit 0` for a guard; stay silent for a warn-only hook. Never block on your own inability to check
- **naming**: Use kebab-case, describe what the hook guards (e.g., `secret-guard`, `commit-lint`)
- **comments**: Include a header comment naming the real event and matcher
- **testing**: Pipe a full payload in and check the exit code before you open the PR. Test the allow cases too, or you ship a guard that blocks unrelated shell calls:
  ```bash
  payload='{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}'
  bash plugins/dev-rules/hooks/no-force-push.sh <<<"$payload"; echo "rc=$?"   # expect 2
  ```

## Pull Request Guidelines

- One plugin per PR
- Include a description of what the skill covers and who it's for
- Test the skill by installing it locally before submitting
- Follow conventional commit format: `feat: add docker-deploy plugin`
- Fill in the PR template (`.github/pull_request_template.md`) -- especially the validator checkbox and the version-bump selection

## Versioning

The marketplace follows [semver](https://semver.org/) via the `metadata.version` field in `.claude-plugin/marketplace.json`. Per-plugin versions in each `plugin.json` also follow semver.

**When to bump:**

| Change | Marketplace version | Per-plugin version |
| --- | --- | --- |
| Typo / doc polish / CI fix | patch (`x.y.Z`) | patch |
| Validator improvement | patch | -- |
| New plugin | minor (`x.Y.0`) | new plugin: `x.0.0` or aligned with marketplace minor |
| New skill / command / agent / hook in existing plugin | minor | plugin: minor (`x.Y.0`) |
| Enhancement (expanded content, new anti-patterns, better examples) | minor | plugin: minor |
| Breaking change (plugin removed, renamed, frontmatter field removed, CLI compatibility break) | major (`X.0.0`) | affected plugin: major |

**Rules:**

- Always bump the marketplace version in the same PR that ships the change.
- Bump the affected plugin's version in its `plugin.json` when that plugin's content changes. Leave other plugins' versions alone.
- Never re-use a published version number.
- New plugins enter at `1.0.0`. The six added in 5.0.0 and 5.1.0 all did. Plugins carrying a `4.x` version predate that convention -- do not renumber them.
- CHANGELOG.md gets one entry per marketplace version under a heading like `## [4.3.0] - 2026-05-13`, grouped by Added / Changed / Fixed / Removed.
- Tag the marketplace version (`git tag v5.3.0`) and publish a GitHub Release with the CHANGELOG body for that version, so users can pin a known-good marketplace as SECURITY.md promises.
