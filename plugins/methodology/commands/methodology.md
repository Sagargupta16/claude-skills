---
description: Choose and apply a development methodology (TDD, BDD, SDD, plan-driven) based on the current task
user_invocable: true
---

# /methodology

Help the user choose and apply the right development methodology for their current task.

## Steps

1. **Assess the task**: Ask what the user is trying to build or fix
2. **Recommend methodology**: Based on the decision tree:
   - Clear acceptance criteria as behaviors → BDD
   - API contract or multi-team interface → SDD
   - New feature or bug fix with testable behavior → TDD
   - Large change spanning 5+ files → Plan-Driven
   - Exploration or unfamiliar codebase → Context Engineering
3. **Bootstrap the workflow**: Create the first artifact:
   - TDD: Write the first failing test
   - BDD: Write Gherkin scenarios
   - SDD: Draft the OpenAPI/schema spec
   - Plan-Driven: Create numbered implementation plan
   - Context Engineering: Audit CLAUDE.md and context state
4. **Guide execution**: Walk through the methodology step by step
