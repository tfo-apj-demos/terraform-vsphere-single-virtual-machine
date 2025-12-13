# Template Version Pinning

## Quick Start

### Cattle VMs (Default - Always Use Latest)
```hcl
module "web_server" {
  source = "app.terraform.io/your-org/single-virtual-machine/vsphere"

  hostname             = "web-server-01"
  pin_template_version = false  # Default - VM will be replaced when template changes

  os_type           = "linux"
  linux_distribution = "ubuntu"
  size              = "medium"
  environment       = "dev"
  site              = "sydney"
  storage_profile   = "standard"
  tier              = "bronze"
  security_profile  = "web-server"
  backup_policy     = "daily"
}
```

### Pet VMs (Pin to Template - No Auto-Replacement)
```hcl
module "database_server" {
  source = "app.terraform.io/your-org/single-virtual-machine/vsphere"

  hostname             = "prod-db-01"
  pin_template_version = true  # Prevents replacement when template changes

  os_type           = "linux"
  linux_distribution = "rhel"
  size              = "xlarge"
  environment       = "prod"
  site              = "sydney"
  storage_profile   = "performance"
  tier              = "gold"
  security_profile  = "db-server"
  backup_policy     = "daily"
}
```

## When Template is Deleted from vSphere

### For Pet Workspaces (Terraform Cloud)

**Workspace Settings:**
1. Go to Workspace → Settings → General
2. Under "Plan & Apply", add:
   - CLI Arguments for plan: `-refresh=false`

**Or use variable:**
```hcl
# In workspace variables
TF_CLI_ARGS_plan = "-refresh=false"
```

### For Cattle Workspaces

No action needed - just update the template reference to the latest:

```hcl
# HCP Packer automatically updates to latest
data "hcp_packer_artifact" "base_ubuntu_2204" {
  bucket_name  = "base-ubuntu-2204"
  channel_name = "latest"  # Always uses latest
  # ...
}
```

## Understanding the Modes

| Mode | `pin_template_version` | When Template Changes | How to Update | Best For |
|------|----------------------|---------------------|---------------|----------|
| **Cattle** | `false` (default) | VM is **protected** | Use `-replace` flag | Web servers, containers, dev |
| **Pet** | `true` | VM is **protected** | Protected, rarely updated | Databases, stateful apps |

> **Note:** Due to Terraform's static lifecycle limitation, both modes have identical protection. Use `terraform apply -replace="..."` to explicitly update cattle VMs.

## Complete Documentation

See [TEMPLATE_LIFECYCLE.md](../terraform-vsphere-virtual-machine/TEMPLATE_LIFECYCLE.md) in the base module for:
- Detailed troubleshooting
- Migration guide
- Emergency recovery procedures
- Technical implementation details
