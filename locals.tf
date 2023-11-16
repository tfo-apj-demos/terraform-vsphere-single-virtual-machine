locals {
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

  // vSphere Tags to associate with the virtual machine
  tag_ids = [
    data.vsphere_tag.environment[var.environment].id,
    data.vsphere_tag.site[var.site].id,
    data.vsphere_tag.tier[var.tier].id,
    data.vsphere_tag.backup_policy[var.backup_policy].id,
    data.vsphere_tag.storage_profile[var.storage_profile].id,
    data.vsphere_tag.security_profile[var.security_profile].id,
  ]
}

# Fetching tag categories
data "vsphere_tag_category" "environment_category" {
  name = "environment"
}

data "vsphere_tag_category" "site_category" {
  name = "site"
}

data "vsphere_tag_category" "tier_category" {
  name = "tier"
}

data "vsphere_tag_category" "backup_policy" {
  name = "backup_policy"
}

data "vsphere_tag_category" "storage_profile" {
  name = "storage_profile"
}

data "vsphere_tag_category" "security_profile" {
  name = "security_profile"
}

data "vsphere_tag" "environment" {
  for_each    = toset(["dev", "test", "prod"])
  category_id = data.vsphere_tag_category.environment_category.id
  name        = each.key
}

data "vsphere_tag" "site" {
  for_each    = toset(["sydney", "canberra", "melbourne"])
  category_id = data.vsphere_tag_category.site_category.id
  name        = each.key
}

data "vsphere_tag" "tier" {
  for_each    = toset(["gold", "silver", "bronze"])
  category_id = data.vsphere_tag_category.tier_category.id
  name        = each.key
}

# Fetching tags for each category
data "vsphere_tag" "backup_policy" {
  for_each    = toset(["daily", "weekly", "monthly"])
  category_id = data.vsphere_tag_category.backup_policy.id
  name        = each.key
}

data "vsphere_tag" "storage_profile" {
  for_each    = toset(["performance", "capacity", "standard"])
  category_id = data.vsphere_tag_category.storage_profile.id
  name        = each.key
}

data "vsphere_tag" "security_profile" {
  for_each    = toset(["web-server", "db-server"])
  category_id = data.vsphere_tag_category.security_profile.id
  name        = each.key
}