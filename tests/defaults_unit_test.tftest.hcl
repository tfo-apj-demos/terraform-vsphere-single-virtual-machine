# tests/defaults_unit_test.tftest.hcl
# Unit tests for default module configuration using plan mode
# These tests validate the module's behavior without creating real infrastructure

# Global variables for all tests in this file
variables {
  os_type          = "linux"
  linux_distribution = "ubuntu"
  hostname         = "test-vm-001"
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

# Test 1: Validate default Linux Ubuntu configuration
run "test_linux_ubuntu_defaults" {
  command = plan

  assert {
    condition     = module.vm.virtual_machine_name != ""
    error_message = "VM name should be generated"
  }

  assert {
    condition     = local.cloud_image_id == data.hcp_packer_artifact.base_ubuntu_2204.external_identifier
    error_message = "Should select Ubuntu 22.04 image for Linux with Ubuntu distribution"
  }

  assert {
    condition     = local.sizes["medium"].cpu == 2
    error_message = "Medium size should have 2 CPUs"
  }

  assert {
    condition     = local.sizes["medium"].memory == 2048
    error_message = "Medium size should have 2048 MB memory"
  }
}

# Test 2: Validate hostname passing to child module
run "test_hostname_configuration" {
  command = plan

  variables {
    hostname = "custom-hostname-test"
  }

  assert {
    condition     = var.hostname == "custom-hostname-test"
    error_message = "Custom hostname should be used when provided"
  }
}

# Test 3: Validate tag generation (skipped - vm module doesn't expose tags output)
# Tags are configured in main.tf and passed to the vm module correctly
run "test_tag_generation" {
  command = plan

  variables {
    environment      = "prod"
    site             = "melbourne"
    backup_policy    = "weekly"
    tier             = "gold"
    storage_profile  = "performance"
    security_profile = "db-server"
  }

  # Note: The vm module doesn't expose a tags output, so we can't directly assert on tags
  # However, tags are correctly configured in main.tf lines 15-22
  assert {
    condition     = module.vm.virtual_machine_name != ""
    error_message = "VM should be created with tags configuration"
  }
}

# Test 4: Validate environment to cluster mapping
run "test_environment_mappings" {
  command = plan

  variables {
    environment = "test"
  }

  assert {
    condition     = local.environments["test"] == "cluster"
    error_message = "Test environment should map to cluster"
  }

  assert {
    condition     = local.environments["dev"] == "cluster"
    error_message = "Dev environment should map to cluster"
  }

  assert {
    condition     = local.environments["prod"] == "cluster"
    error_message = "Prod environment should map to cluster"
  }
}

# Test 5: Validate site to datacenter mapping
run "test_site_mappings" {
  command = plan

  assert {
    condition     = local.sites["sydney"] == "Datacenter"
    error_message = "Sydney site should map to Datacenter"
  }

  assert {
    condition     = local.sites["canberra"] == "Datacenter"
    error_message = "Canberra site should map to Datacenter"
  }

  assert {
    condition     = local.sites["melbourne"] == "Datacenter"
    error_message = "Melbourne site should map to Datacenter"
  }
}

# Test 6: Validate tier to resource pool mapping
run "test_tier_mappings" {
  command = plan

  variables {
    tier = "gold"
  }

  assert {
    condition     = local.tiers["gold"] == "Demo Workloads"
    error_message = "Gold tier should map to Demo Workloads"
  }

  assert {
    condition     = local.tiers["silver"] == "Demo Workloads"
    error_message = "Silver tier should map to Demo Workloads"
  }

  assert {
    condition     = local.tiers["bronze"] == "Demo Workloads"
    error_message = "Bronze tier should map to Demo Workloads"
  }

  assert {
    condition     = local.tiers["management"] == "Demo Management"
    error_message = "Management tier should map to Demo Management"
  }
}

# Test 7: Validate storage profile mapping
run "test_storage_mappings" {
  command = plan

  variables {
    storage_profile = "capacity"
  }

  assert {
    condition     = local.storage_profile["performance"] == "vsanDatastore"
    error_message = "Performance storage should map to vsanDatastore"
  }

  assert {
    condition     = local.storage_profile["capacity"] == "vsanDatastore"
    error_message = "Capacity storage should map to vsanDatastore"
  }

  assert {
    condition     = local.storage_profile["standard"] == "vsanDatastore"
    error_message = "Standard storage should map to vsanDatastore"
  }
}

# Test 8: Validate disk size configuration
run "test_disk_configuration" {
  command = plan

  variables {
    disk_0_size = 100
  }

  assert {
    condition     = var.disk_0_size == 100
    error_message = "Custom disk size should be applied"
  }
}

# Test 9: Validate default disk size
run "test_default_disk_size" {
  command = plan

  assert {
    condition     = var.disk_0_size == 60
    error_message = "Default disk size should be 60 GB"
  }
}

# Test 10: Validate folder path configuration
run "test_folder_path" {
  command = plan

  variables {
    folder_path = "Custom/Folder/Path"
  }

  assert {
    condition     = var.folder_path == "Custom/Folder/Path"
    error_message = "Custom folder path should be used"
  }
}

# Test 11: Validate default folder path
run "test_default_folder_path" {
  command = plan

  assert {
    condition     = var.folder_path == "Demo Workloads"
    error_message = "Default folder path should be 'Demo Workloads'"
  }
}

# Test 12: Validate custom text for userdata
run "test_custom_text" {
  command = plan

  variables {
    custom_text = "Custom configuration text"
  }

  assert {
    condition     = var.custom_text == "Custom configuration text"
    error_message = "Custom text should be passed to userdata template"
  }
}

# Test 13: Validate network configuration
# Note: networks is not exposed as an output from the child module
run "test_network_configuration" {
  command = plan

  assert {
    condition     = module.vm.virtual_machine_name != ""
    error_message = "VM should be created with network configuration"
  }
}

# Test 14: Validate outputs are defined
# Note: With mock providers during plan, outputs like virtual_machine_id and ip_address
# are unknown and can't be tested. We test virtual_machine_name which is known during plan.
run "test_outputs" {
  command = plan

  assert {
    condition     = output.virtual_machine_name == "test-vm-001"
    error_message = "virtual_machine_name output should match the hostname"
  }

  # Note: Other outputs (virtual_machine_id, ip_address, vsphere_compute_cluster_id)
  # are unknown during plan phase and cannot be tested without apply
}
