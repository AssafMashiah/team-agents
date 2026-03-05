# Terraform Reference

## Common Provider Patterns

### Cloudflare

```hcl
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
```

### Common Cloudflare Resources

```hcl
# DNS record
resource "cloudflare_record" "www" {
  zone_id = var.zone_id
  name    = "www"
  value   = "192.0.2.1"
  type    = "A"
  ttl     = 3600
}

# Pages project
resource "cloudflare_pages_project" "slides" {
  account_id        = var.account_id
  name              = "slides"
  production_branch = "main"
}
```

## Variable Management

```bash
# Use .tfvars files (gitignored)
terraform apply -var-file="production.tfvars"

# Or environment variables
export TF_VAR_cloudflare_api_token="..."
```

## Backends (Remote State)

```hcl
# Terraform Cloud
terraform {
  backend "remote" {
    organization = "my-org"
    workspaces {
      name = "production"
    }
  }
}

# S3 backend
terraform {
  backend "s3" {
    bucket = "my-tf-state"
    key    = "production/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Debugging

```bash
# Verbose logging
TF_LOG=DEBUG terraform apply

# Show provider schema
terraform providers schema -json
```
