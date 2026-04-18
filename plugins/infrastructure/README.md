# infrastructure

Infrastructure as code patterns -- Terraform, AWS CDK, CloudFormation best practices, module design, state management, security scanning, and multi-environment patterns.

## Components

| Type | Name | Description |
|------|------|-------------|
| Skill | infrastructure | IaC patterns, module design, state management |
| Command | `/infra-check` | Validate IaC with linting and security scanning |
| Agent | infra-reviewer | Review infrastructure code for security and best practices |

## Key Concepts

- **File organization**: One resource type per file, modules for reusability
- **State management**: Always remote, always locked, always encrypted
- **Security scanning**: checkov, tflint, never hardcode credentials
- **Multi-environment**: tfvars per environment, separate state per env

## Install

```bash
claude plugin add sagar-dev-skills/infrastructure
```
