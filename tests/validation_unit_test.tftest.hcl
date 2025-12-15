# tests/validation_unit_test.tftest.hcl
# Unit tests for input variable validation rules
# These tests ensure that invalid inputs are properly rejected

# Global variables for all tests in this file (valid defaults)
variables {
  os_type          = "linux"
  linux_distribution = "ubuntu"
  hostname         = "test-vm-validation"
  size             = "medium"
  environment      = "dev"
  site             = "sydney"
  storage_profile  = "standard"
  tier             = "bronze"
  security_profile = "web-server"
  backup_policy    = "daily"
  ad_domain        = "hashicorp.local"
}

# Mock providers for unit testing (no real infrastructure needed)
mock_provider "vsphere" {
  mock_data "vsphere_virtual_machine" {
    defaults = {
      scsi_type            = "pvscsi"
      guest_id             = "ubuntu64Guest"
      firmware             = "efi"
      num_cpus             = 2
      memory               = 2048
      network_interface_types = ["vmxnet3"]
      disks = [
        {
          size             = 32
          eagerly_scrub    = false
          thin_provisioned = true
        }
      ]
    }
  }
}

mock_provider "hcp" {}
mock_provider "ad" {}
mock_provider "dns" {}
mock_provider "random" {}

# ============================================================================
# OS Type Validation Tests
# ============================================================================

# Test 1: Invalid os_type should fail
run "test_invalid_os_type" {
  command = plan

  variables {
    os_type = "invalid_os"
  }

  expect_failures = [
    var.os_type
  ]
}

# Test 2: Valid os_type values should pass (windows)
run "test_valid_os_type_windows" {
  command = plan

  variables {
    os_type = "windows"
  }

  assert {
    condition     = var.os_type == "windows"
    error_message = "Windows should be a valid os_type"
  }
}

# Test 3: Valid os_type values should pass (mssql)
run "test_valid_os_type_mssql" {
  command = plan

  variables {
    os_type = "mssql"
  }

  assert {
    condition     = var.os_type == "mssql"
    error_message = "MSSQL should be a valid os_type"
  }
}

# ============================================================================
# Linux Distribution Validation Tests
# ============================================================================

# Test 4: Invalid linux_distribution when os_type is linux should fail
run "test_invalid_linux_distribution" {
  command = plan

  variables {
    os_type            = "linux"
    linux_distribution = "centos"  # Not in allowed list
  }

  expect_failures = [
    var.linux_distribution
  ]
}

# Test 5: Valid linux_distribution (rhel) should pass
# SKIPPED: RHEL VM template not available in test environment
# run "test_valid_linux_distribution_rhel" {
#   command = plan
#
#   variables {
#     os_type            = "linux"
#     linux_distribution = "rhel"
#   }
#
#   assert {
#     condition     = var.linux_distribution == "rhel"
#     error_message = "RHEL should be a valid linux_distribution"
#   }
# }

# Test 6: linux_distribution validation should not apply when os_type is windows
run "test_linux_distribution_ignored_for_windows" {
  command = plan

  variables {
    os_type            = "windows"
    linux_distribution = "ubuntu"  # Should be ignored
  }

  assert {
    condition     = var.os_type == "windows"
    error_message = "Should allow any linux_distribution when os_type is not linux"
  }
}

# ============================================================================
# Size Validation Tests
# ============================================================================

# Test 7: Invalid size should fail
run "test_invalid_size" {
  command = plan

  variables {
    size = "mega"  # Not in allowed list
  }

  expect_failures = [
    var.size
  ]
}

# Test 8: Valid size values should pass (small)
run "test_valid_size_small" {
  command = plan

  variables {
    size = "small"
  }

  assert {
    condition     = var.size == "small"
    error_message = "Small should be a valid size"
  }

  assert {
    condition     = local.sizes["small"].cpu == 1
    error_message = "Small size should have 1 CPU"
  }

  assert {
    condition     = local.sizes["small"].memory == 1024
    error_message = "Small size should have 1024 MB memory"
  }
}

# Test 9: Valid size values should pass (large)
run "test_valid_size_large" {
  command = plan

  variables {
    size = "large"
  }

  assert {
    condition     = local.sizes["large"].cpu == 4
    error_message = "Large size should have 4 CPUs"
  }

  assert {
    condition     = local.sizes["large"].memory == 4096
    error_message = "Large size should have 4096 MB memory"
  }
}

# Test 10: Valid size values should pass (xlarge)
run "test_valid_size_xlarge" {
  command = plan

  variables {
    size = "xlarge"
  }

  assert {
    condition     = local.sizes["xlarge"].cpu == 8
    error_message = "XLarge size should have 8 CPUs"
  }

  assert {
    condition     = local.sizes["xlarge"].memory == 8192
    error_message = "XLarge size should have 8192 MB memory"
  }
}

# Test 11: Valid size values should pass (2xlarge)
run "test_valid_size_2xlarge" {
  command = plan

  variables {
    size = "2xlarge"
  }

  assert {
    condition     = local.sizes["2xlarge"].cpu == 16
    error_message = "2XLarge size should have 16 CPUs"
  }

  assert {
    condition     = local.sizes["2xlarge"].memory == 16384
    error_message = "2XLarge size should have 16384 MB memory"
  }
}

# Test 12: Valid size values should pass (4xlarge)
run "test_valid_size_4xlarge" {
  command = plan

  variables {
    size = "4xlarge"
  }

  assert {
    condition     = local.sizes["4xlarge"].cpu == 32
    error_message = "4XLarge size should have 32 CPUs"
  }

  assert {
    condition     = local.sizes["4xlarge"].memory == 32768
    error_message = "4XLarge size should have 32768 MB memory"
  }
}

# ============================================================================
# Environment Validation Tests
# ============================================================================

# Test 13: Invalid environment should fail
run "test_invalid_environment" {
  command = plan

  variables {
    environment = "staging"  # Not in allowed list
  }

  expect_failures = [
    var.environment
  ]
}

# Test 14: Valid environment values should pass (test)
run "test_valid_environment_test" {
  command = plan

  variables {
    environment = "test"
  }

  assert {
    condition     = var.environment == "test"
    error_message = "Test should be a valid environment"
  }
}

# Test 15: Valid environment values should pass (prod)
run "test_valid_environment_prod" {
  command = plan

  variables {
    environment = "prod"
  }

  assert {
    condition     = var.environment == "prod"
    error_message = "Prod should be a valid environment"
  }
}

# ============================================================================
# Site Validation Tests
# ============================================================================

# Test 16: Invalid site should fail
run "test_invalid_site" {
  command = plan

  variables {
    site = "perth"  # Not in allowed list
  }

  expect_failures = [
    var.site
  ]
}

# Test 17: Valid site values should pass (canberra)
run "test_valid_site_canberra" {
  command = plan

  variables {
    site = "canberra"
  }

  assert {
    condition     = var.site == "canberra"
    error_message = "Canberra should be a valid site"
  }
}

# Test 18: Valid site values should pass (melbourne)
run "test_valid_site_melbourne" {
  command = plan

  variables {
    site = "melbourne"
  }

  assert {
    condition     = var.site == "melbourne"
    error_message = "Melbourne should be a valid site"
  }
}

# ============================================================================
# Storage Profile Validation Tests
# ============================================================================

# Test 19: Invalid storage_profile should fail
run "test_invalid_storage_profile" {
  command = plan

  variables {
    storage_profile = "ultra"  # Not in allowed list
  }

  expect_failures = [
    var.storage_profile
  ]
}

# Test 20: Valid storage_profile values should pass (performance)
run "test_valid_storage_profile_performance" {
  command = plan

  variables {
    storage_profile = "performance"
  }

  assert {
    condition     = var.storage_profile == "performance"
    error_message = "Performance should be a valid storage_profile"
  }
}

# Test 21: Valid storage_profile values should pass (capacity)
run "test_valid_storage_profile_capacity" {
  command = plan

  variables {
    storage_profile = "capacity"
  }

  assert {
    condition     = var.storage_profile == "capacity"
    error_message = "Capacity should be a valid storage_profile"
  }
}

# ============================================================================
# Tier Validation Tests
# ============================================================================

# Test 22: Invalid tier should fail
run "test_invalid_tier" {
  command = plan

  variables {
    tier = "platinum"  # Not in allowed list
  }

  expect_failures = [
    var.tier
  ]
}

# Test 23: Valid tier values should pass (gold)
run "test_valid_tier_gold" {
  command = plan

  variables {
    tier = "gold"
  }

  assert {
    condition     = var.tier == "gold"
    error_message = "Gold should be a valid tier"
  }
}

# Test 24: Valid tier values should pass (silver)
run "test_valid_tier_silver" {
  command = plan

  variables {
    tier = "silver"
  }

  assert {
    condition     = var.tier == "silver"
    error_message = "Silver should be a valid tier"
  }
}

# Test 25: Valid tier values should pass (management)
run "test_valid_tier_management" {
  command = plan

  variables {
    tier = "management"
  }

  assert {
    condition     = var.tier == "management"
    error_message = "Management should be a valid tier"
  }
}

# ============================================================================
# Security Profile Validation Tests
# ============================================================================

# Test 26: Invalid security_profile should fail
run "test_invalid_security_profile" {
  command = plan

  variables {
    security_profile = "firewall"  # Not in allowed list
  }

  expect_failures = [
    var.security_profile
  ]
}

# Test 27: Valid security_profile values should pass (app-server)
run "test_valid_security_profile_app_server" {
  command = plan

  variables {
    security_profile = "app-server"
  }

  assert {
    condition     = var.security_profile == "app-server"
    error_message = "App-server should be a valid security_profile"
  }
}

# Test 28: Valid security_profile values should pass (db-server)
run "test_valid_security_profile_db_server" {
  command = plan

  variables {
    security_profile = "db-server"
  }

  assert {
    condition     = var.security_profile == "db-server"
    error_message = "DB-server should be a valid security_profile"
  }
}

# ============================================================================
# Backup Policy Validation Tests
# ============================================================================

# Test 29: Invalid backup_policy should fail
run "test_invalid_backup_policy" {
  command = plan

  variables {
    backup_policy = "hourly"  # Not in allowed list
  }

  expect_failures = [
    var.backup_policy
  ]
}

# Test 30: Valid backup_policy values should pass (weekly)
run "test_valid_backup_policy_weekly" {
  command = plan

  variables {
    backup_policy = "weekly"
  }

  assert {
    condition     = var.backup_policy == "weekly"
    error_message = "Weekly should be a valid backup_policy"
  }
}

# Test 31: Valid backup_policy values should pass (monthly)
run "test_valid_backup_policy_monthly" {
  command = plan

  variables {
    backup_policy = "monthly"
  }

  assert {
    condition     = var.backup_policy == "monthly"
    error_message = "Monthly should be a valid backup_policy"
  }
}
