---
description: Create a structured implementation plan for a multi-file feature or change
user_invocable: true
---

Create a structured implementation plan:

1. Analyze the codebase to understand current architecture and patterns
2. Identify all files that need to be created or modified
3. Determine the correct order of operations (dependencies first)
4. Write a numbered plan with:
   - **Scope**: What's changing and what's explicitly NOT changing
   - **Steps**: Numbered, dependency-ordered, each with specific files and verification
   - **Risks**: What could go wrong, how to mitigate or rollback
5. Each step should have:
   - Files to create/modify
   - What specifically to do
   - How to verify the step works (test command or manual check)

If requirements are unclear, ask clarifying questions first using AskUserQuestion before creating the plan.
