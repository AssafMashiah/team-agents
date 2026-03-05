---
name: infra
description: Manage infrastructure with Terraform or Pulumi. Use when running plan/apply/destroy, detecting config drift, importing existing resources, reading state, or troubleshooting provider errors. Also covers basic infra audits (open ports, unused resources).
---

# Infra (Terraform / Pulumi)

See `references/terraform.md` or `references/pulumi.md` for tool-specific patterns.

## Terraform Quick Reference

```bash
# Init / plan / apply
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Destroy (careful!)
terraform destroy

# Show current state
terraform show
terraform state list

# Drift detection
terraform plan   # non-zero exit = drift exists

# Import existing resource
terraform import <resource_type>.<name> <resource_id>

# Target a single resource
terraform apply -target=<resource_type>.<name>
```

### State Management

```bash
# Lock state (remote backends do this automatically)
terraform force-unlock <lock-id>

# Move resource in state
terraform state mv <old> <new>

# Remove from state without destroying
terraform state rm <resource>
```

---

## Pulumi Quick Reference

```bash
# Preview changes
pulumi preview

# Deploy
pulumi up

# Destroy
pulumi destroy

# Show stack outputs
pulumi stack output

# Refresh state from cloud
pulumi refresh

# Import existing resource
pulumi import <type> <name> <id>
```

---

## Drift Detection Workflow

1. Run `terraform plan` (or `pulumi preview`)
2. If output shows changes you didn't make → drift detected
3. Investigate: was it a manual change in console? Another process?
4. Either: import the change into state, or revert the manual change
5. Document finding in a GitHub issue

---

## Safety Rules

- Always `plan` before `apply`
- Never `apply` without reviewing the plan output
- For destructive changes (`-/+ destroy`), confirm with Assaf before proceeding
- State files may contain secrets — never commit `terraform.tfstate`
