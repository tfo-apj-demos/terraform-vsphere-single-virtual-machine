module "vm" {
  source  = "app.terraform.io/tfo-apj-demos/virtual-machine/vsphere"
  version = "1.4.0"

  template          = local.cloud_image_id
  hostname          = local.hostname
  num_cpus          = local.sizes[var.size].cpu
  memory            = local.sizes[var.size].memory
  cluster           = local.environments[var.environment]
  datacenter        = local.sites[var.site]
  primary_datastore = local.storage_profile[var.storage_profile]
  resource_pool     = local.tiers[var.tier]
  tags = {
    environment      = var.environment
    site             = var.site
    backup_policy    = var.backup_policy
    tier             = var.tier
    storage_profile  = var.storage_profile
    security_profile = var.security_profile
  }
  folder_path           = var.folder_path
  disk_0_size           = var.disk_0_size
  admin_password        = var.admin_password
  ad_domain             = var.ad_domain
  domain_admin_user     = var.domain_admin_user
  domain_admin_password = var.domain_admin_password

  networks = {
    "seg-general" = "dhcp"
  }

  userdata = templatefile("${path.module}/templates/userdata.yaml.tmpl", {
    custom_text = var.custom_text
    hostname    = var.hostname
  })

  metadata = templatefile("${path.module}/templates/metadata.yaml.tmpl", {
    dhcp     = true
    hostname = var.hostname
  })
}

# # Conditional creation of AD computer object
# resource "ad_computer" "windows_computer" {
#   count = var.os_type == "windows" ? 1 : 0

#   name        = local.hostname
#   pre2kname   = local.hostname
#   container   = "OU=Terraform Managed Computers,DC=hashicorp,DC=local"
#   description = "Terraform Managed Windows Computer"
# }

module "domain-name-system-management" {
  source  = "app.terraform.io/tfo-apj-demos/domain-name-system-management/dns"
  version = "~> 1.0"

  a_records = [
    {
      name      = local.hostname
      addresses = [module.vm.ip_address]
    }
  ]
}
