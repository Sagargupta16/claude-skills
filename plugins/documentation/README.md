# Documentation Plugin

Documentation patterns for READMEs, ADRs, changelogs, API docs, and technical specs.

## Skills

- **documentation**: README structure, architecture decision records, Keep-a-Changelog format, code comment guidelines, docstring patterns, technical spec template, and documentation maintenance rules.

## Commands

- `/write-docs`: Generate or improve project documentation

## Example

```
> /write-docs README

Analyzed codebase: FastAPI + React + MongoDB
Generated README.md:
  - Project description (from package metadata)
  - Tech stack section
  - Prerequisites (Python 3.13+, Node 22+, MongoDB)
  - Installation steps (backend + frontend)
  - Environment setup (.env.example reference)
  - API endpoints table (from route handlers)
  - License
```

## Installation

```
/plugin install documentation@sagar-dev-skills
```
