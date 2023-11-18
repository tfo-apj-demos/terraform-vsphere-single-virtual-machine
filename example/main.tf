module "single-virtual-machine" {
  source  = "app.terraform.io/tfo-apj-demos/single-virtual-machine/vsphere"
  version = "1.1.2"

  backup_policy    = "daily"
  environment      = "dev"
  security_profile = "web-server"
  site             = "sydney"
  size             = "medium"
  storage_profile  = "standard"
  tier             = "gold"
}