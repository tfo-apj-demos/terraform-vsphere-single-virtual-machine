module "vm" {
  source = "github.com/tfo-apj-demos/terraform-vsphere-virtual-machine"

  template          = local.cloud_image_id
  hostname          = var.hostname
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
  folder_path = var.folder_path
  disk_0_size = var.disk_0_size

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