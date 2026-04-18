---
description: Validate infrastructure code with linting, security scanning, and plan review
user_invocable: true
---

Validate infrastructure as code:

1. Detect the IaC tool in use:
   - `*.tf` files -> Terraform
   - `cdk.json` / CDK imports -> AWS CDK
   - CloudFormation templates -> CloudFormation

2. Run validation checks:
   - **Terraform**: `terraform validate`, `terraform fmt -check`, `tflint --recursive`
   - **CDK**: `cdk synth`, `cdk diff`
   - **CloudFormation**: Template validation

3. Run security scanning if tools available:
   - `checkov -d . --framework terraform`
   - Check for common issues: open security groups, unencrypted storage, wildcard IAM

4. Check for anti-patterns:
   - Hardcoded credentials
   - Missing state locking configuration
   - Untagged resources
   - Wildcard permissions
   - Local state files

5. Report findings with severity (critical, warning, info) and specific fix suggestions
