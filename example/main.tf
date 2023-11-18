module "single-virtual-machine" {
  source  = "app.terraform.io/tfo-apj-demos/single-virtual-machine/vsphere"
  version = "1.0.9"

  backup_policy    = "daily"
  environment      = "dev"
  hostname         = "vm-01"
  security_profile = "web-server"
  site             = "sydney"
  size             = "medium"
  storage_profile  = "standard"
  tier             = "gold"
}