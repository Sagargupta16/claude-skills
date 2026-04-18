---
name: infrastructure
description: Use when writing or reviewing Terraform, AWS CDK, CloudFormation, or other infrastructure as code. Covers module design, state management, security scanning, multi-environment patterns, and IaC best practices.
---

# Infrastructure as Code Patterns

## Quick Reference

| Tool | Config Language | State | Best For |
|------|----------------|-------|----------|
| Terraform | HCL | Remote (S3, GCS) | Multi-cloud, mature ecosystem |
| AWS CDK | TypeScript/Python | CloudFormation | AWS-native, programmatic |
| CloudFormation | YAML/JSON | AWS-managed | AWS-native, declarative |
| Pulumi | TypeScript/Python/Go | Pulumi Cloud / S3 | Multi-cloud, programmatic |

## Terraform Patterns

### File Organization

```
project/
├── main.tf              # Provider config, terraform block
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── locals.tf            # Local values
├── versions.tf          # Required providers and versions
├── data.tf              # Data sources
├── vpc.tf               # One resource type per file
├── security_groups.tf
├── iam.tf
├── modules/
│   └── service/         # Reusable modules
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/
    ├── dev.tfvars
    ├── staging.tfvars
    └── prod.tfvars
```

### Module Design

| Principle | Example |
|-----------|---------|
| Single responsibility | Module does one thing (VPC, ECS service, RDS) |
| Sensible defaults | Variables have defaults for common cases |
| Minimal required inputs | Only require what can't be defaulted |
| Outputs for composition | Output IDs, ARNs, endpoints for other modules |
| Version pinning | Pin module sources and provider versions |

### State Management

```hcl
# Remote state with locking
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "project/env/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

| Rule | Why |
|------|-----|
| Always use remote state | Local state gets lost, can't collaborate |
| Enable state locking | Prevents concurrent modifications |
| Encrypt state at rest | State contains sensitive data |
| Separate state per environment | Isolate blast radius |
| Never commit .tfstate files | Contains secrets |

### Security Scanning

```bash
# Lint
tflint --recursive

# Security scan
checkov -d . --framework terraform

# Cost estimation
infracost breakdown --path .
```

### Common Checkov Rules

| Rule | ID | Fix |
|------|-----|-----|
| S3 bucket not encrypted | CKV_AWS_19 | Add `server_side_encryption_configuration` |
| Security group open to 0.0.0.0/0 | CKV_AWS_24 | Restrict CIDR blocks |
| CloudWatch log group not encrypted | CKV_AWS_158 | Add KMS key |
| RDS not encrypted | CKV_AWS_16 | Set `storage_encrypted = true` |
| IAM policy with wildcard | CKV_AWS_1 | Use least privilege actions |

## AWS CDK Patterns

### Stack Organization

```typescript
// One stack per logical unit
const app = new cdk.App();

new NetworkStack(app, "Network", { env });
new DatabaseStack(app, "Database", { env, vpc: networkStack.vpc });
new ServiceStack(app, "Service", { env, vpc, database });
```

### CDK Best Practices

| Practice | Why |
|----------|-----|
| Use L2/L3 constructs over L1 | Better defaults, less boilerplate |
| Synth and diff before deploy | Catch issues before they hit AWS |
| Use `cdk.Tags.of(scope).add()` | Consistent tagging |
| Pin CDK version across packages | Avoid version mismatch issues |
| Use context for env-specific values | `cdk.json` or `-c key=value` |

## Multi-Environment Patterns

### Terraform Workspaces vs Directories

| Approach | Pros | Cons |
|----------|------|------|
| Workspaces | DRY, same code | Shared state backend, harder isolation |
| Directories per env | Full isolation | Code duplication |
| tfvars per env | DRY + isolation | Need CI discipline |

### Recommended: tfvars per Environment

```bash
# Dev
terraform plan -var-file="environments/dev.tfvars" -out=tfplan

# Prod
terraform plan -var-file="environments/prod.tfvars" -out=tfplan
```

## Tagging Standards

All resources should have at minimum:

```hcl
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.team
  }
}
```

## Anti-Patterns

| Anti-Pattern | Problem | Do Instead |
|-------------|---------|-----------|
| Hardcoded credentials in .tf | Secrets exposed in state and repo | Use IAM roles, env vars, or secret managers |
| No state locking | Concurrent runs corrupt state | Use DynamoDB locking (Terraform) |
| `terraform apply` without plan | Unexpected destructive changes | Always plan first, review, then apply |
| Monolithic single-file config | Hard to navigate, merge conflicts | One resource type per file |
| No tagging | Can't track costs or ownership | Tag everything with project, env, owner |
| Wildcard IAM permissions | Security risk | Least privilege, specific actions and resources |
| Local state in production | Can't collaborate, state loss risk | Remote state with encryption |
| No security scanning | Vulnerabilities in infrastructure | Run checkov/tflint in CI |
