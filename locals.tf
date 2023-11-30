locals {
  // HCP Packer Image Selection
  cloud_image_id = var.os_type == "windows" ? data.hcp_packer_image.base-windows-2022.cloud_image_id : data.hcp_packer_image.base-ubuntu-2204.cloud_image_id
  
  // T-shirt size mappings for CPU and memory
  sizes = {
    "small"  = { cpu = 1, memory = 1024 }
    "medium" = { cpu = 2, memory = 2048 }
    "large"  = { cpu = 4, memory = 4096 }
  }

  // Environment to cluster mappings
  environments = {
    "dev"  = "cluster"
    "test" = "cluster"
    "prod" = "cluster"
  }

  // Site to datacenter mappings
  sites = {
    "sydney"    = "Datacenter"
    "canberra"  = "Datacenter"
    "melbourne" = "Datacenter"
  }

  // Tier to resource pool mappings
  tiers = {
    "gold"   = "workload"
    "silver" = "workload"
    "bronze" = "workload"
  }

  // Storage profiles to datastore mappings
  storage_profile = {
    "performance" = "vsanDatastore"
    "capacity"    = "vsanDatastore"
    "standard"    = "vsanDatastore"
  }

  // Security profiles to security group mappings
  security_profile = {
    "web-server" = "web-server"
    "db-server"  = "db-server"
  }

  // Backup policies to specific configurations
  backup_policy = {
    "daily"   = "daily"
    "weekly"  = "weekly"
    "monthly" = "monthly"

  }
}

// Fetching HCP Packer Images
data "hcp_packer_image" "base-ubuntu-2204" {
  bucket_name    = "base-ubuntu-2204"
  channel        = "latest"
  cloud_provider = "vsphere"
  region         = "Datacenter"
}

data "hcp_packer_image" "base-windows-2022" {
  bucket_name    = "base-windows-2022"
  channel        = "latest"
  cloud_provider = "vsphere"
  region         = "Datacenter"
}