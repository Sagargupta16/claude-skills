# context-management

Context window management -- compaction timing, context rot prevention, branching strategies (Continue/Rewind/Clear/Compact/Subagent), and sub-agent isolation patterns.

## Components

| Type | Name | Description |
|------|------|-------------|
| Skill | context-management | Context rot detection, compaction timing, branching strategy |
| Command | `/manage-context` | Assess context health and recommend next action |
| Agent | context-advisor | Evaluate context and suggest compaction strategy |

## Key Concepts

- **Context rot** starts at ~300-400K tokens -- manual `/compact` at 50% beats auto-compaction
- **Every turn is a branching point**: Continue, /rewind, /clear, /compact, or sub-agent
- **Rewind over correct**: Drop failed attempts instead of adding corrections to context
- **Sub-agent isolation**: Research in child context, only results bubble up to main

## Install

```bash
claude plugin add sagar-dev-skills/context-management
```
