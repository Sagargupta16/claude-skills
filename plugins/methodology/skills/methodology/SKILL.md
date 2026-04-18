---
name: methodology
description: Use when choosing or following a structured development methodology -- TDD red-green-refactor, BDD behavior specs, spec-driven development, plan-driven execution, or context engineering patterns. Covers workflow selection, step-by-step processes, and integration with Claude Code features.
---

# Development Methodologies

## Quick Reference

| Methodology | When to Use | Key Artifact |
|-------------|-------------|-------------|
| TDD | New features, bug fixes, refactoring | Failing test first |
| BDD | User-facing features, acceptance criteria | Gherkin scenarios |
| SDD | API contracts, multi-team projects | OpenAPI/schema spec |
| Plan-Driven | Large features, multi-file changes | Written plan with steps |
| Context Engineering | Long sessions, complex codebases | CLAUDE.md + progressive loading |

## TDD - Test-Driven Development

### Red-Green-Refactor Cycle

```
1. RED    - Write a failing test for the next behavior
2. GREEN  - Write minimal code to make the test pass
3. REFACTOR - Clean up while keeping tests green
4. REPEAT - Next behavior
```

### TDD with Claude Code

```bash
# Step 1: Write the test
# Tell Claude what behavior you want, ask for test first
"Write a failing test for user registration with email validation"

# Step 2: Run the test, confirm it fails
/test

# Step 3: Implement just enough to pass
"Make this test pass with minimal code"

# Step 4: Run tests again, confirm green
/test

# Step 5: Refactor
"Refactor the implementation -- tests must stay green"
/test
```

### TDD Anti-Patterns

| Anti-Pattern | Problem | Do Instead |
|-------------|---------|-----------|
| Writing tests after code | Tests confirm bias, not behavior | Always test first |
| Testing implementation details | Brittle tests that break on refactor | Test public behavior only |
| Skipping the red step | Can't verify the test actually tests anything | Always see it fail first |
| Large test steps | Hard to debug when green fails | One behavior per cycle |
| Mocking everything | Tests pass but production breaks | Mock boundaries only |

## BDD - Behavior-Driven Development

### Gherkin Workflow

```gherkin
Feature: User Registration
  As a new user
  I want to create an account
  So that I can access the platform

  Scenario: Successful registration with valid email
    Given I am on the registration page
    When I enter email "user@example.com" and password "SecurePass123!"
    And I click "Register"
    Then I should see "Welcome! Check your email to verify."
    And a verification email should be sent to "user@example.com"

  Scenario: Registration with invalid email
    Given I am on the registration page
    When I enter email "not-an-email" and password "SecurePass123!"
    And I click "Register"
    Then I should see "Please enter a valid email address"
```

### BDD with Claude Code

1. Write Gherkin scenarios in `.feature` files
2. Ask Claude to generate step definitions from the scenarios
3. Run steps -- they fail (no implementation yet)
4. Implement features to satisfy each scenario
5. Run again -- all scenarios pass

### When BDD Over TDD

- User-facing features where behavior matters more than implementation
- Cross-team communication (product, QA, dev share Gherkin specs)
- Acceptance criteria already exist as user stories

## SDD - Spec-Driven Development

### Contract-First Workflow

```
1. Define the spec (OpenAPI, GraphQL schema, Protobuf)
2. Generate types/interfaces from the spec
3. Implement against the generated interfaces
4. Validate implementation matches the spec
```

### SDD with Claude Code

```bash
# Step 1: Write the spec
"Create an OpenAPI 3.1 spec for a task management API with CRUD endpoints"

# Step 2: Generate types
"Generate TypeScript interfaces from this OpenAPI spec"

# Step 3: Implement
"Implement the /tasks endpoints matching the OpenAPI spec exactly"

# Step 4: Validate
"Verify all endpoints match the spec -- check routes, request bodies, responses"
```

### SDD Best For

- API teams where frontend and backend develop in parallel
- Microservices where contracts prevent breaking changes
- Code generation workflows (OpenAPI -> SDK)

## Plan-Driven Development

### Structured Planning Workflow

```
1. UNDERSTAND - Read the codebase, identify scope
2. PLAN       - Write step-by-step implementation plan
3. VALIDATE   - Review plan for gaps, dependencies, risks
4. EXECUTE    - Implement one step at a time, verify each
5. VERIFY     - Run tests, check for regressions
```

### Plan-Driven with Claude Code

```bash
# Step 1: Enter plan mode
# Ask Claude to analyze and create a plan before coding
"I need to add OAuth2 login. Analyze the codebase and create a plan."

# Step 2: Review the plan
# Claude outputs numbered steps with files to create/modify

# Step 3: Execute step by step
"Execute step 1 of the plan"
/test
"Execute step 2 of the plan"
/test
# ... repeat until complete

# Step 4: Final verification
/review
```

### When to Use Plan-Driven

- Changes spanning 5+ files
- Architectural changes (new auth system, database migration)
- When you need team alignment before coding
- Unfamiliar codebases -- plan forces understanding first

## Context Engineering

### Principle

Treat context (what Claude knows during a session) as a deliberate design element.

### Techniques

| Technique | When | How |
|-----------|------|-----|
| Progressive disclosure | Large codebases | Load metadata first, details on demand |
| CLAUDE.md as contract | Every project | Codify rules, conventions, commands |
| Sub-agent isolation | Complex tasks | Spawn agents for focused subtasks |
| Reference splitting | Long skills | Split >500 lines into references/ |
| Fresh context restart | After long sessions | Start new session with clear task |

### Context Budget Rules

- **Under 50K tokens**: Work freely, no special handling
- **50K-100K tokens**: Start being selective about file reads
- **100K-200K tokens**: Use sub-agents for independent subtasks
- **Over 200K tokens**: Consider fresh session with focused scope

### CLAUDE.md as Executable Contract

```markdown
## Behavioral Rules

### Always run tests after changes
After modifying any source file, run the test suite.
Do not report completion without confirming tests pass.

### Match existing patterns
Before creating new patterns, grep for existing ones.
Follow the established pattern if >3 occurrences exist.
```

## Prototype Over PRD

When requirements are uncertain, build instead of specifying:

### When to Prototype
- New product ideas where you don't know what you want yet
- UI/UX exploration -- seeing beats describing
- API design -- try using the API before specifying it
- Algorithm selection -- benchmark, don't theorize

### Pattern
```
Instead of: Write a 10-page PRD → review → implement → discover it's wrong
Do: Build rough prototype → iterate 5-10 times → extract the spec from what works
```

### Prototype Workflow with Claude Code
```bash
# Session 1: Quick prototype
"Build a rough prototype of [feature]. Don't worry about edge cases or production quality."

# Sessions 2-5: Iterate
"Here's what works and doesn't work about the prototype: [feedback]. Iterate."

# Session 6: Extract spec
"The prototype is solid. Extract a clean spec from what we built, then reimplement properly."
```

### When NOT to Prototype
- Well-defined bug fixes (just fix it)
- API contracts between teams (spec first, SDD approach)
- Database migrations (plan carefully, prototyping is dangerous)
- Security-critical code (spec and review first)

## Interview-Then-Execute

For unclear requirements, have Claude interview you before coding:

### Pattern
```
Session 1 (Planning):
1. "I need [vague feature]. Interview me to understand the requirements."
2. Claude asks 5-10 targeted clarifying questions
3. You answer, refining scope and constraints
4. Claude produces a plan based on answers
5. Review and adjust the plan

Session 2 (Execution):
1. Start fresh with the finalized plan
2. Execute step by step with verification
```

### Why Separate Sessions
- Planning session fills context with requirements discussion
- Execution session gets clean context with only the finalized plan
- Produces better code than doing both in one session

## Choosing a Methodology

```
Is the change well-defined with clear acceptance criteria?
├── Yes: Are the criteria written as user behaviors?
│   ├── Yes → BDD (write Gherkin scenarios first)
│   └── No: Is it an API or contract?
│       ├── Yes → SDD (write OpenAPI/schema first)
│       └── No → TDD (write test first)
└── No: Is the change large (5+ files)?
    ├── Yes → Plan-Driven (plan first, execute step by step)
    ├── Requirements unclear? → Interview-Then-Execute
    ├── Feasibility unknown? → Prototype First
    └── Small and exploratory → Context Engineering
```
