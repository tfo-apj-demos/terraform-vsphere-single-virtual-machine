# Terraform vSphere Single Virtual Machine - v2.0.0 (Cattle Version)

> **⚠️ Important:** This is the **CATTLE version** of the wrapper module. VMs created with this version **will be replaced** when templates are updated.
>
> 🐾 **Looking for the PETS version?** Use **v1.6.0** instead for long-lived infrastructure.

## Overview

This wrapper module simplifies VM provisioning with **t-shirt sizing** and **automatic template updates**, ideal for:

- 🐄 **Immutable infrastructure** - Web servers, API servers, application tiers
- 🔄 **Auto-scaling workloads** - VMs that should update with latest templates
- 🚀 **CI/CD environments** - Development and staging infrastructure

### Key Features (v2.0.0)

**Automatic Template Updates:**
- ✅ VMs are **automatically replaced** when HCP Packer templates are updated
- ✅ Ensures all VMs run the latest approved OS image
- ✅ Seamless integration with Packer template rotation workflows

**T-Shirt Sizing:**
- 👕 Pre-defined sizes: `small`, `medium`, `large`, `xlarge`, `2xlarge`, `4xlarge`
- 📍 Environment-aware: Automatically selects cluster based on `dev`/`test`/`prod`
- 💾 Storage profiles: `performance`, `capacity`, `standard`

**HCP Packer Integration:**
- 🔗 Automatically fetches latest templates from HCP Packer
- 🔄 Template updates don't trigger VM replacement (pets behavior)
- 🏷️ Supports multiple OS types: Ubuntu, RHEL, Windows Server
- 🛡️ **Template Management:** See [TEMPLATE_MANAGEMENT.md](TEMPLATE_MANAGEMENT.md) for handling missing templates

## Quick Start

### Linux VM (Ubuntu)

```hcl
module "web_server" {
  source  = "app.terraform.io/tfo-apj-demos/single-virtual-machine/vsphere"
  version = "2.0.0"  # Cattle version

  hostname = "web-server-01"

  # OS Configuration
  os_type            = "linux"
  linux_distribution = "ubuntu"

  # T-Shirt Sizing
  size = "medium"  # 2 vCPU, 2GB RAM

  # Environment & Location
  environment     = "dev"
  site            = "sydney"
  storage_profile = "standard"
  tier            = "bronze"

  # Tagging
  security_profile = "web-server"
  backup_policy    = "daily"

  # Active Directory
  ad_domain             = "corp.example.com"
  domain_admin_user     = var.domain_admin_user
  domain_admin_password = var.domain_admin_password
}
```

### API Server (RHEL)

```hcl
module "api_server" {
  source  = "app.terraform.io/tfo-apj-demos/single-virtual-machine/vsphere"
  version = "2.0.0"

  hostname = "api-server-01"

  # OS Configuration
  os_type            = "linux"
  linux_distribution = "rhel"

  # T-Shirt Sizing
  size = "large"  # 4 vCPU, 4GB RAM

  # Environment & Location
  environment     = "prod"
  site            = "sydney"
  storage_profile = "performance"
  tier            = "gold"

  # Tagging
  security_profile = "app-server"
  backup_policy    = "weekly"

  # Active Directory
  ad_domain             = "corp.example.com"
  domain_admin_user     = var.domain_admin_user
  domain_admin_password = var.domain_admin_password
}
```

## How It Works

### HCP Packer Integration

The module automatically fetches templates from HCP Packer:

```hcl
# In locals.tf (managed by module)
data "hcp_packer_artifact" "base_rhel_9" {
  bucket_name  = "base-rhel-9"
  channel_name = "latest"  # Always uses latest
  platform     = "vsphere"
  region       = "Datacenter"
}
```

**Cattle Behavior (v2.0.0):**
1. HCP Packer builds new template → `latest` channel updates
2. `terraform plan` → Shows **VM replacement** (template changed)
3. `terraform apply` → VM is replaced with new template
4. Old template can be safely cleaned up from vSphere ✅

### T-Shirt Sizes

| Size | vCPU | Memory | Use Case |
|------|------|--------|----------|
| `small` | 1 | 1GB | Development, testing |
| `medium` | 2 | 2GB | Standard applications |
| `large` | 4 | 4GB | **Databases, high-traffic apps** |
| `xlarge` | 8 | 8GB | Large databases |
| `2xlarge` | 16 | 16GB | Enterprise applications |
| `4xlarge` | 32 | 32GB | Mission-critical workloads |

### Environment Mapping

The module automatically maps environments to clusters:

```hcl
# Defined in locals.tf
environments = {
  "dev"  = "cluster"
  "test" = "cluster"
  "prod" = "cluster"
}
```

Customize in your fork if you have separate clusters per environment.

## Handling Template Updates

### Automatic Updates (Recommended)

When using HCP Packer's `latest` channel (default in this module):

```hcl
# In module's locals.tf
channel_name = "latest"  # Automatically tracks newest template
```

**Workflow:**
1. HCP Packer builds new template
2. Webhook triggers cleanup of old template
3. Next `terraform plan` → Shows VM replacement
4. `terraform apply` → Deploys new template

### Controlled Updates

For more control, fork the module and use specific iterations:

```hcl
# In your forked module's locals.tf
data "hcp_packer_artifact" "base_ubuntu_2204" {
  bucket_name   = "base-ubuntu-2204"
  iteration_id  = "01HQXYZ..."  # Pin to specific iteration
  # ...
}
```

**Workflow:**
1. Test new template in dev/staging first
2. Update `iteration_id` when ready for production
3. Roll out to production VMs

### Deleted Templates

If a template is deleted before replacement:
- ❌ `terraform plan` will fail (template not found)
- ✅ **Solution:** Module will auto-fetch latest via HCP Packer
- ✅ Run `terraform apply` → New VM with latest template

## Inputs

### Required

| Name | Description | Type | Example |
|------|-------------|------|---------|
| `os_type` | OS type (`linux`, `windows`, `mssql`) | `string` | `"linux"` |
| `linux_distribution` | Linux distro (`ubuntu`, `rhel`) - required if `os_type="linux"` | `string` | `"rhel"` |
| `size` | T-shirt size | `string` | `"large"` |
| `environment` | Environment (`dev`, `test`, `prod`) | `string` | `"prod"` |
| `site` | Site location (`sydney`, `canberra`, `melbourne`) | `string` | `"sydney"` |
| `storage_profile` | Storage tier (`performance`, `capacity`, `standard`) | `string` | `"performance"` |
| `tier` | Resource tier (`gold`, `silver`, `bronze`, `management`) | `string` | `"gold"` |
| `security_profile` | Security profile (`web-server`, `db-server`, `app-server`) | `string` | `"db-server"` |
| `backup_policy` | Backup frequency (`daily`, `weekly`, `monthly`) | `string` | `"daily"` |
| `ad_domain` | Active Directory domain | `string` | `"corp.example.com"` |

### Optional

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `hostname` | VM hostname (auto-generated if not provided) | `string` | `null` |
| `disk_0_size` | Primary disk size (GB) | `number` | `60` |
| `folder_path` | vSphere folder path | `string` | `"Demo Workloads"` |
| `custom_text` | Custom text for cloud-init | `string` | `"some text to be rendered"` |
| `admin_password` | Windows admin password | `string` (sensitive) | `""` |
| `domain_admin_user` | Domain admin username | `string` (sensitive) | `""` |
| `domain_admin_password` | Domain admin password | `string` (sensitive) | `""` |

## Outputs

| Name | Description |
|------|-------------|
| `virtual_machine_id` | vSphere VM ID |
| `virtual_machine_name` | VM hostname |
| `ip_address` | Primary IP address |
| `guest_id` | Guest OS identifier |

## Version Comparison

| Version | Type | Template Changes | Base Module | Use Case |
|---------|------|-----------------|-------------|----------|
| **v1.6.0** | 🐾 **Pets** | Protected | v1.6.0 | Long-lived VMs |
| **v2.0.0** (this) | 🐄 **Cattle** | Triggers replacement | v2.0.0 | Immutable infrastructure |

## Migration Guide

### Upgrading from v1.0.x to v2.0.0

No breaking changes! Simply update the version:

```hcl
module "my_vm" {
  source  = "app.terraform.io/tfo-apj-demos/single-virtual-machine/vsphere"
  version = "2.0.0"  # Was 1.0.x

  # All existing inputs remain the same
}
```

Run `terraform plan` - may show changes if template has updated.

### Downgrading to v1.6.0 (Pets)

For long-lived infrastructure:

```hcl
module "my_vm" {
  source  = "app.terraform.io/tfo-apj-demos/single-virtual-machine/vsphere"
  version = "1.6.0"  # Pets version

  # Same inputs
}
```

**Note:** Changing versions won't replace existing VMs. The version only affects behavior for future template changes.

## Architecture

```
terraform-vsphere-single-virtual-machine (v1.6.0)
├── Simplified inputs (size, environment, etc.)
├── HCP Packer integration (auto-fetch latest templates)
└── Calls base module ──→ terraform-vsphere-virtual-machine (v1.6.0)
                          ├── Template lifecycle protection
                          └── vSphere resource creation
```

## Advanced Configuration

### Custom Userdata

```hcl
module "web_server" {
  source = "..."

  custom_text = templatefile("${path.module}/userdata.yaml", {
    packages = ["nginx", "certbot"]
  })
}
```

### Larger Disk

```hcl
module "database" {
  source = "..."

  disk_0_size = 500  # 500 GB for database
}
```

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.5 |
| vSphere Provider | >= 2.6 |
| HCP Provider | >= 0.76 |

## Related Documentation

- 📘 **[Base Module](https://github.com/your-org/terraform-vsphere-virtual-machine)** - Direct vSphere VM provisioning
- 📗 **[Template Pinning Guide](./TEMPLATE_PINNING.md)** - Pets vs Cattle comparison
- 🔧 **[Examples](./example/)** - Working examples

## Support

For issues or questions:
- Internal: Your organization's support channel
- Base module: See base module repository

---

**Remember:** This is the **CATTLE version (v2.0.0)** - VMs will be replaced when templates change. Use **v1.6.0** for pets behavior (protection from template changes).
