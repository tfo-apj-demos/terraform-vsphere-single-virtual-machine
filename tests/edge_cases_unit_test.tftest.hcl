# tests/edge_cases_unit_test.tftest.hcl
# Unit tests for edge cases and specific scenarios

# Global variables for all tests in this file
variables {
  os_type          = "linux"
  linux_distribution = "ubuntu"
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
# Hostname Tests
# ============================================================================

# Test 1: Null hostname should be accepted (will be generated)
run "test_null_hostname" {
  command = plan

  variables {
    hostname = null
  }

  assert {
    condition     = var.hostname == null
    error_message = "Null hostname should be accepted"
  }
}

# Test 2: Empty string hostname (note: this may fail validation)
run "test_empty_hostname" {
  command = plan

  variables {
    hostname = ""
  }

  assert {
    condition     = var.hostname == ""
    error_message = "Empty hostname should be handled"
  }
}

# Test 3: Long hostname (test practical limits)
run "test_long_hostname" {
  command = plan

  variables {
    hostname = "very-long-hostname-for-testing-limits-in-vsphere-environment-001"
  }

  assert {
    condition     = var.hostname == "very-long-hostname-for-testing-limits-in-vsphere-environment-001"
    error_message = "Long hostname should be accepted"
  }
}

# Test 4: Hostname with special characters (hyphens, numbers)
run "test_hostname_with_special_chars" {
  command = plan

  variables {
    hostname = "test-vm-123-prod"
  }

  assert {
    condition     = var.hostname == "test-vm-123-prod"
    error_message = "Hostname with hyphens and numbers should be accepted"
  }
}

# ============================================================================
# Sensitive Variables Tests
# ============================================================================

# Test 5: Admin password should be marked sensitive
run "test_admin_password_sensitive" {
  command = plan

  variables {
    hostname       = "test-password-vm"
    admin_password = "SecurePassword123!"
  }

  assert {
    condition     = var.admin_password != ""
    error_message = "Admin password should be set"
  }

  # Note: We can't directly test if it's marked sensitive in plan output,
  # but the variable definition has sensitive = true
}

# Test 6: Domain admin credentials should be marked sensitive
run "test_domain_credentials_sensitive" {
  command = plan

  variables {
    hostname              = "test-domain-vm"
    domain_admin_user     = "admin@hashicorp.local"
    domain_admin_password = "DomainPassword123!"
  }

  assert {
    condition     = var.domain_admin_user != ""
    error_message = "Domain admin user should be set"
  }

  assert {
    condition     = var.domain_admin_password != ""
    error_message = "Domain admin password should be set"
  }
}

# Test 7: Empty sensitive variables should use defaults
run "test_empty_sensitive_variables" {
  command = plan

  variables {
    hostname = "test-default-creds-vm"
  }

  assert {
    condition     = var.admin_password == ""
    error_message = "Admin password should default to empty string"
  }

  assert {
    condition     = var.domain_admin_user == ""
    error_message = "Domain admin user should default to empty string"
  }

  assert {
    condition     = var.domain_admin_password == ""
    error_message = "Domain admin password should default to empty string"
  }
}

# ============================================================================
# Disk Size Edge Cases
# ============================================================================

# Test 8: Very large disk size
run "test_large_disk_size" {
  command = plan

  variables {
    hostname    = "test-large-disk-vm"
    disk_0_size = 2000  # 2 TB
  }

  assert {
    condition     = var.disk_0_size == 2000
    error_message = "Large disk size should be accepted"
  }
}

# Test 9: Minimum disk size
run "test_minimum_disk_size" {
  command = plan

  variables {
    hostname    = "test-min-disk-vm"
    disk_0_size = 32  # Minimum allowed size (must match or exceed template)
  }

  assert {
    condition     = var.disk_0_size == 32
    error_message = "Minimum disk size (32GB) should be accepted"
  }
}

# ============================================================================
# Folder Path Edge Cases
# ============================================================================

# Test 10: Deep folder path
run "test_deep_folder_path" {
  command = plan

  variables {
    hostname    = "test-folder-vm"
    folder_path = "Datacenter/vm/Production/Applications/Web/Frontend"
  }

  assert {
    condition     = var.folder_path == "Datacenter/vm/Production/Applications/Web/Frontend"
    error_message = "Deep folder path should be accepted"
  }
}

# Test 11: Folder path with spaces
run "test_folder_path_with_spaces" {
  command = plan

  variables {
    hostname    = "test-spaces-vm"
    folder_path = "Demo Workloads/Test VMs"
  }

  assert {
    condition     = var.folder_path == "Demo Workloads/Test VMs"
    error_message = "Folder path with spaces should be accepted"
  }
}

# ============================================================================
# Custom Text Edge Cases
# ============================================================================

# Test 12: Empty custom text
run "test_empty_custom_text" {
  command = plan

  variables {
    hostname    = "test-empty-text-vm"
    custom_text = ""
  }

  assert {
    condition     = var.custom_text == ""
    error_message = "Empty custom text should be accepted"
  }
}

# Test 13: Long custom text
run "test_long_custom_text" {
  command = plan

  variables {
    hostname    = "test-long-text-vm"
    custom_text = "This is a very long custom text that might be used in userdata. It contains multiple sentences and should be properly handled by the template rendering mechanism. Special characters like: @#$% should also work."
  }

  assert {
    condition     = length(var.custom_text) > 100
    error_message = "Long custom text should be accepted"
  }
}

# Test 14: Custom text with newlines and special chars
run "test_custom_text_multiline" {
  command = plan

  variables {
    hostname    = "test-multiline-vm"
    custom_text = "Line 1\nLine 2\nLine 3"
  }

  assert {
    condition     = can(regex("\\n", var.custom_text))
    error_message = "Custom text with newlines should be accepted"
  }
}

# ============================================================================
# Combination Tests (Multiple Configurations)
# ============================================================================

# Test 15: Maximum resource configuration
run "test_maximum_configuration" {
  command = plan

  variables {
    hostname         = "test-max-vm"
    os_type          = "windows"
    size             = "4xlarge"  # Largest size
    environment      = "prod"
    site             = "melbourne"
    storage_profile  = "performance"
    tier             = "gold"
    security_profile = "db-server"
    backup_policy    = "daily"
    disk_0_size      = 500
    folder_path      = "Production/Critical/Databases"
  }

  assert {
    condition     = var.size == "4xlarge"
    error_message = "Should accept maximum configuration"
  }

  assert {
    condition     = local.sizes["4xlarge"].cpu == 32
    error_message = "4xlarge should have 32 CPUs"
  }

  assert {
    condition     = local.sizes["4xlarge"].memory == 32768
    error_message = "4xlarge should have 32 GB memory"
  }

  assert {
    condition     = var.tier == "gold"
    error_message = "Should use gold tier"
  }

  assert {
    condition     = var.storage_profile == "performance"
    error_message = "Should use performance storage"
  }

  # Verify Windows creates AD object
  assert {
    condition     = length(ad_computer.windows_computer) == 1
    error_message = "Maximum config Windows VM should create AD object"
  }
}

# Test 16: Minimum resource configuration
run "test_minimum_configuration" {
  command = plan

  variables {
    hostname         = "test-min-vm"
    os_type          = "linux"
    linux_distribution = "ubuntu"
    size             = "small"  # Smallest size
    environment      = "dev"
    site             = "sydney"
    storage_profile  = "standard"
    tier             = "bronze"
    security_profile = "web-server"
    backup_policy    = "monthly"
  }

  assert {
    condition     = var.size == "small"
    error_message = "Should accept minimum configuration"
  }

  assert {
    condition     = local.sizes["small"].cpu == 1
    error_message = "Small should have 1 CPU"
  }

  assert {
    condition     = local.sizes["small"].memory == 1024
    error_message = "Small should have 1 GB memory"
  }

  # Verify Linux doesn't create AD object
  assert {
    condition     = length(ad_computer.windows_computer) == 0
    error_message = "Minimum config Linux VM should not create AD object"
  }
}

# ============================================================================
# Data Source Consistency Tests
# ============================================================================

# Test 17: All HCP Packer data sources exist
run "test_all_packer_artifacts_defined" {
  command = plan

  variables {
    hostname = "test-artifacts-vm"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_ubuntu_2204 != null
    error_message = "Ubuntu 22.04 HCP Packer artifact should be defined"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_windows_2022 != null
    error_message = "Windows 2022 HCP Packer artifact should be defined"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_rhel_9 != null
    error_message = "RHEL 9 HCP Packer artifact should be defined"
  }

  assert {
    condition     = data.hcp_packer_artifact.mssql_windows_2022 != null
    error_message = "MSSQL Windows 2022 HCP Packer artifact should be defined"
  }
}

# ============================================================================
# Module Reference Tests
# ============================================================================

# Test 18: Child module configuration
run "test_child_module_attributes" {
  command = plan

  variables {
    hostname    = "test-module-vm"
    size        = "large"
    environment = "test"
  }

  # Verify VM module outputs are available
  assert {
    condition     = module.vm.virtual_machine_name == "test-module-vm"
    error_message = "VM module should be configured with correct hostname"
  }

  # Verify DNS module is configured (only a_record_ids is exposed)
  assert {
    condition     = module.domain-name-system-management.a_record_ids != null
    error_message = "DNS module should be configured"
  }
}
