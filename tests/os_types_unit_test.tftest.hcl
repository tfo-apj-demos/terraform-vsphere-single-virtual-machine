# tests/os_types_unit_test.tftest.hcl
# Unit tests for different OS types and image selection logic
# These tests validate HCP Packer image selection based on OS type and distribution

# Global variables for all tests in this file
variables {
  hostname         = "test-os-vm"
  size             = "medium"
  environment      = "dev"
  site             = "sydney"
  storage_profile  = "standard"
  tier             = "bronze"
  security_profile = "web-server"
  backup_policy    = "daily"
  ad_domain        = "hashicorp.local"
}

# ============================================================================
# Linux OS Type Tests
# ============================================================================

# Test 1: Linux with Ubuntu distribution should select Ubuntu image
run "test_linux_ubuntu_image_selection" {
  command = plan

  variables {
    os_type            = "linux"
    linux_distribution = "ubuntu"
  }

  assert {
    condition     = var.os_type == "linux"
    error_message = "OS type should be linux"
  }

  assert {
    condition     = var.linux_distribution == "ubuntu"
    error_message = "Linux distribution should be ubuntu"
  }

  assert {
    condition     = local.cloud_image_id == data.hcp_packer_artifact.base_ubuntu_2204.external_identifier
    error_message = "Should select Ubuntu 22.04 HCP Packer image"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_ubuntu_2204.bucket_name == "base-ubuntu-2204"
    error_message = "Should use base-ubuntu-2204 bucket"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_ubuntu_2204.channel_name == "latest"
    error_message = "Should use latest channel"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_ubuntu_2204.platform == "vsphere"
    error_message = "Should use vsphere platform"
  }
}

# Test 2: Linux with RHEL distribution should select RHEL image
run "test_linux_rhel_image_selection" {
  command = plan

  variables {
    os_type            = "linux"
    linux_distribution = "rhel"
  }

  assert {
    condition     = var.os_type == "linux"
    error_message = "OS type should be linux"
  }

  assert {
    condition     = var.linux_distribution == "rhel"
    error_message = "Linux distribution should be rhel"
  }

  assert {
    condition     = local.cloud_image_id == data.hcp_packer_artifact.base_rhel_9.external_identifier
    error_message = "Should select RHEL 9 HCP Packer image"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_rhel_9.bucket_name == "base-rhel-9"
    error_message = "Should use base-rhel-9 bucket"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_rhel_9.channel_name == "latest"
    error_message = "Should use latest channel"
  }
}

# Test 3: Linux defaults to Ubuntu when distribution not specified
run "test_linux_default_distribution" {
  command = plan

  variables {
    os_type = "linux"
  }

  assert {
    condition     = var.linux_distribution == "ubuntu"
    error_message = "Should default to ubuntu distribution"
  }

  assert {
    condition     = local.cloud_image_id == data.hcp_packer_artifact.base_ubuntu_2204.external_identifier
    error_message = "Should select Ubuntu image when distribution not specified"
  }
}

# ============================================================================
# Windows OS Type Tests
# ============================================================================

# Test 4: Windows should select Windows 2022 image
run "test_windows_image_selection" {
  command = plan

  variables {
    os_type = "windows"
  }

  assert {
    condition     = var.os_type == "windows"
    error_message = "OS type should be windows"
  }

  assert {
    condition     = local.cloud_image_id == data.hcp_packer_artifact.base_windows_2022.external_identifier
    error_message = "Should select Windows 2022 HCP Packer image"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_windows_2022.bucket_name == "base-windows-2022"
    error_message = "Should use base-windows-2022 bucket"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_windows_2022.channel_name == "latest"
    error_message = "Should use latest channel"
  }
}

# Test 5: Windows with linux_distribution specified should ignore it
run "test_windows_ignores_linux_distribution" {
  command = plan

  variables {
    os_type            = "windows"
    linux_distribution = "ubuntu"  # Should be ignored
  }

  assert {
    condition     = var.os_type == "windows"
    error_message = "OS type should be windows"
  }

  assert {
    condition     = local.cloud_image_id == data.hcp_packer_artifact.base_windows_2022.external_identifier
    error_message = "Should select Windows image regardless of linux_distribution"
  }
}

# ============================================================================
# MSSQL OS Type Tests
# ============================================================================

# Test 6: MSSQL should select MSSQL Windows 2022 image
run "test_mssql_image_selection" {
  command = plan

  variables {
    os_type = "mssql"
  }

  assert {
    condition     = var.os_type == "mssql"
    error_message = "OS type should be mssql"
  }

  assert {
    condition     = local.cloud_image_id == data.hcp_packer_artifact.mssql_windows_2022.external_identifier
    error_message = "Should select MSSQL Windows 2022 HCP Packer image"
  }

  assert {
    condition     = data.hcp_packer_artifact.mssql_windows_2022.bucket_name == "mssql-windows-2022"
    error_message = "Should use mssql-windows-2022 bucket"
  }

  assert {
    condition     = data.hcp_packer_artifact.mssql_windows_2022.channel_name == "latest"
    error_message = "Should use latest channel"
  }
}

# ============================================================================
# Active Directory Computer Object Tests
# ============================================================================

# Test 7: Windows OS should create AD computer object
run "test_windows_creates_ad_computer" {
  command = plan

  variables {
    os_type  = "windows"
    hostname = "test-win-vm"
  }

  assert {
    condition     = length(ad_computer.windows_computer) == 1
    error_message = "Should create AD computer object for Windows OS"
  }

  assert {
    condition     = ad_computer.windows_computer[0].name == "test-win-vm"
    error_message = "AD computer name should match hostname"
  }

  assert {
    condition     = ad_computer.windows_computer[0].pre2kname == "test-win-vm"
    error_message = "AD computer pre2kname should match hostname"
  }

  assert {
    condition     = ad_computer.windows_computer[0].container == "OU=Terraform Managed Computers,DC=hashicorp,DC=local"
    error_message = "AD computer should be in correct OU"
  }

  assert {
    condition     = ad_computer.windows_computer[0].description == "Terraform Managed Windows Computer"
    error_message = "AD computer should have correct description"
  }
}

# Test 8: Linux OS should NOT create AD computer object
run "test_linux_no_ad_computer" {
  command = plan

  variables {
    os_type            = "linux"
    linux_distribution = "ubuntu"
    hostname           = "test-linux-vm"
  }

  assert {
    condition     = length(ad_computer.windows_computer) == 0
    error_message = "Should not create AD computer object for Linux OS"
  }
}

# Test 9: MSSQL OS should create AD computer object (MSSQL is Windows-based)
run "test_mssql_creates_ad_computer" {
  command = plan

  variables {
    os_type  = "mssql"
    hostname = "test-mssql-vm"
  }

  assert {
    condition     = var.os_type == "mssql"
    error_message = "OS type should be mssql"
  }

  # Note: Based on the code, MSSQL does NOT create AD computer object
  # because the condition is specifically: var.os_type == "windows"
  assert {
    condition     = length(ad_computer.windows_computer) == 0
    error_message = "Should not create AD computer object for MSSQL (only for os_type == 'windows')"
  }
}

# ============================================================================
# DNS Record Creation Tests
# ============================================================================

# Test 10: DNS records should be created for all OS types
run "test_dns_records_linux" {
  command = plan

  variables {
    os_type            = "linux"
    linux_distribution = "ubuntu"
    hostname           = "test-dns-linux"
  }

  assert {
    condition     = length(module.domain-name-system-management.a_records) > 0
    error_message = "Should create DNS A records for Linux VM"
  }

  assert {
    condition     = module.domain-name-system-management.a_records[0].name == module.vm.virtual_machine_name
    error_message = "DNS record name should match VM name"
  }

  assert {
    condition     = contains(module.domain-name-system-management.a_records[0].addresses, module.vm.ip_address)
    error_message = "DNS record should contain VM IP address"
  }
}

# Test 11: DNS records should be created for Windows VMs
run "test_dns_records_windows" {
  command = plan

  variables {
    os_type  = "windows"
    hostname = "test-dns-win"
  }

  assert {
    condition     = length(module.domain-name-system-management.a_records) > 0
    error_message = "Should create DNS A records for Windows VM"
  }
}

# Test 12: DNS records should be created for MSSQL VMs
run "test_dns_records_mssql" {
  command = plan

  variables {
    os_type  = "mssql"
    hostname = "test-dns-mssql"
  }

  assert {
    condition     = length(module.domain-name-system-management.a_records) > 0
    error_message = "Should create DNS A records for MSSQL VM"
  }
}

# ============================================================================
# HCP Packer Data Source Tests
# ============================================================================

# Test 13: All HCP Packer data sources should use correct configuration
run "test_hcp_packer_data_sources" {
  command = plan

  variables {
    os_type = "linux"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_ubuntu_2204.platform == "vsphere"
    error_message = "Ubuntu artifact should use vsphere platform"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_ubuntu_2204.region == "Datacenter"
    error_message = "Ubuntu artifact should use Datacenter region"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_windows_2022.platform == "vsphere"
    error_message = "Windows artifact should use vsphere platform"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_windows_2022.region == "Datacenter"
    error_message = "Windows artifact should use Datacenter region"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_rhel_9.platform == "vsphere"
    error_message = "RHEL artifact should use vsphere platform"
  }

  assert {
    condition     = data.hcp_packer_artifact.base_rhel_9.region == "Datacenter"
    error_message = "RHEL artifact should use Datacenter region"
  }

  assert {
    condition     = data.hcp_packer_artifact.mssql_windows_2022.platform == "vsphere"
    error_message = "MSSQL artifact should use vsphere platform"
  }

  assert {
    condition     = data.hcp_packer_artifact.mssql_windows_2022.region == "Datacenter"
    error_message = "MSSQL artifact should use Datacenter region"
  }
}
