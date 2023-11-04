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
  storage_profiles = {
    "performance" = "vsanDatastore"
    "capacity"    = "vsanDatastore"
    "standard"    = "vsanDatastore"
  }

  // Security profiles to security group mappings
  security_profiles = {
    "web-server" = "Web_Server_Security_Group"
    "db-server"  = "DB_Server_Security_Group"
  }

  // Backup policies to specific configurations
  backup_policies = {
    "daily"   = "Daily_Backup_Policy"
    "weekly"  = "Weekly_Backup_Policy"
    "monthly" = "Monthly_Backup_Policy"
  }
}