# tests/integration_test.tftest.hcl
# Integration tests that create real infrastructure
#
# ⚠️  WARNING: These tests create REAL resources in vSphere/HCP/Active Directory
# ⚠️  Running these tests will incur costs and create actual VMs
# ⚠️  Only run these tests in a dedicated test environment
#
# To run only unit tests (no resource creation):
#   terraform test -filter="*_unit_test"
#
# To run integration tests:
#   terraform test tests/integration_test.tftest.hcl
#
# Requirements:
#   - Valid HCP Terraform/Packer credentials
#   - vSphere provider configured and authenticated
#   - Active Directory provider configured (for Windows tests)
#   - DNS provider configured
#   - Network connectivity to vSphere and HCP

# Global variables for integration tests
variables {
  hostname         = "tf-test-integration-vm"
  size             = "small"  # Use smallest size for cost savings
  environment      = "dev"
  site             = "sydney"
  storage_profile  = "standard"
  tier             = "bronze"
  security_profile = "web-server"
  backup_policy    = "daily"
  folder_path      = "Demo Workloads"
  disk_0_size      = 60  # Minimum disk size
  custom_text      = "Integration test VM"
  ad_domain        = "hashicorp.local"
}

# ============================================================================
# Integration Test: Linux Ubuntu VM
# ============================================================================
# DISABLED: Integration tests require real infrastructure (vSphere, DNS, etc.)

# run "integration_test_linux_ubuntu_vm" {
#   # command defaults to apply - creates real infrastructure!
#
#   variables {
#     os_type            = "linux"
#     linux_distribution = "ubuntu"
#     hostname           = "tf-test-ubuntu-vm"
#   }
#
#   # Validate VM creation
#   assert {
#     condition     = module.vm.virtual_machine_id != ""
#     error_message = "VM should be created with a valid ID"
#   }
#
#   assert {
#     condition     = module.vm.virtual_machine_name != ""
#     error_message = "VM should have a valid name"
#   }
#
#   assert {
#     condition     = module.vm.ip_address != ""
#     error_message = "VM should have an IP address assigned"
#   }
#
#   assert {
#     condition     = module.vm.vsphere_compute_cluster_id != ""
#     error_message = "VM should be assigned to a compute cluster"
#   }
#
#   # Validate no AD computer object was created (Linux VM)
#   assert {
#     condition     = length(ad_computer.windows_computer) == 0
#     error_message = "Linux VM should not create AD computer object"
#   }
#
#   # Validate DNS record was created
#   assert {
#     condition     = length(module.domain-name-system-management.a_records) > 0
#     error_message = "DNS A record should be created"
#   }
#
#   # Validate outputs
#   assert {
#     condition     = output.virtual_machine_id == module.vm.virtual_machine_id
#     error_message = "Output virtual_machine_id should match module output"
#   }
#
#   assert {
#     condition     = output.virtual_machine_name == module.vm.virtual_machine_name
#     error_message = "Output virtual_machine_name should match module output"
#   }
#
#   assert {
#     condition     = output.ip_address == module.vm.ip_address
#     error_message = "Output ip_address should match module output"
#   }
#
#   assert {
#     condition     = output.vsphere_compute_cluster_id == module.vm.vsphere_compute_cluster_id
#     error_message = "Output vsphere_compute_cluster_id should match module output"
#   }
# }

# Automatic cleanup happens here - VM will be destroyed in reverse order

# ============================================================================
# Integration Test: Windows VM (requires AD provider)
# ============================================================================
# Note: This test is commented out by default because it requires:
#   - Active Directory provider configuration
#   - Domain admin credentials
#   - More time to provision
#
# Uncomment and configure when testing Windows VM provisioning

# run "integration_test_windows_vm" {
#   # command defaults to apply - creates real infrastructure!
#
#   variables {
#     os_type              = "windows"
#     hostname             = "tf-test-win-vm"
#     admin_password       = "SecurePassword123!"  # Replace with actual password
#     domain_admin_user    = "administrator"       # Replace with actual user
#     domain_admin_password = "DomainPassword123!" # Replace with actual password
#   }
#
#   # Validate VM creation
#   assert {
#     condition     = module.vm.virtual_machine_id != ""
#     error_message = "Windows VM should be created with a valid ID"
#   }
#
#   # Validate AD computer object was created
#   assert {
#     condition     = length(ad_computer.windows_computer) == 1
#     error_message = "Windows VM should create AD computer object"
#   }
#
#   assert {
#     condition     = ad_computer.windows_computer[0].name == "tf-test-win-vm"
#     error_message = "AD computer object name should match hostname"
#   }
#
#   # Validate DNS record was created
#   assert {
#     condition     = length(module.domain-name-system-management.a_records) > 0
#     error_message = "DNS A record should be created for Windows VM"
#   }
# }

# ============================================================================
# Integration Test: Different VM Size
# ============================================================================
# DISABLED: Integration tests require real infrastructure

# run "integration_test_medium_vm_size" {
#   # command defaults to apply
#
#   variables {
#     os_type            = "linux"
#     linux_distribution = "ubuntu"
#     hostname           = "tf-test-medium-vm"
#     size               = "medium"  # 2 CPU, 2048 MB
#   }
#
#   assert {
#     condition     = module.vm.virtual_machine_id != ""
#     error_message = "Medium VM should be created successfully"
#   }
#
#   # Note: We can't directly assert on CPU/memory from the child module
#   # as those details may not be exposed in outputs
#   # This would require additional data sources to validate
# }

# ============================================================================
# Integration Test: Custom Disk Size
# ============================================================================
# DISABLED: Integration tests require real infrastructure

# run "integration_test_custom_disk_size" {
#   # command defaults to apply
#
#   variables {
#     os_type            = "linux"
#     linux_distribution = "ubuntu"
#     hostname           = "tf-test-disk-vm"
#     disk_0_size        = 100  # Custom 100 GB disk
#   }
#
#   assert {
#     condition     = module.vm.virtual_machine_id != ""
#     error_message = "VM with custom disk size should be created successfully"
#   }
# }

# ============================================================================
# Integration Test: Different Environment and Tier
# ============================================================================
# DISABLED: Integration tests require real infrastructure

# run "integration_test_prod_environment" {
#   # command defaults to apply
#
#   variables {
#     os_type            = "linux"
#     linux_distribution = "ubuntu"
#     hostname           = "tf-test-prod-vm"
#     environment        = "prod"
#     tier               = "gold"
#     backup_policy      = "weekly"
#   }
#
#   assert {
#     condition     = module.vm.virtual_machine_id != ""
#     error_message = "Production VM should be created successfully"
#   }
#
#   assert {
#     condition     = module.vm.tags["environment"] == "prod"
#     error_message = "VM should have prod environment tag"
#   }
#
#   assert {
#     condition     = module.vm.tags["tier"] == "gold"
#     error_message = "VM should have gold tier tag"
#   }
#
#   assert {
#     condition     = module.vm.tags["backup_policy"] == "weekly"
#     error_message = "VM should have weekly backup policy tag"
#   }
# }

# ============================================================================
# Integration Test: RHEL Distribution
# ============================================================================
# SKIPPED: RHEL VM template not available in test environment

# run "integration_test_rhel_vm" {
#   # command defaults to apply
#
#   variables {
#     os_type            = "linux"
#     linux_distribution = "rhel"
#     hostname           = "tf-test-rhel-vm"
#   }
#
#   assert {
#     condition     = module.vm.virtual_machine_id != ""
#     error_message = "RHEL VM should be created successfully"
#   }
#
#   assert {
#     condition     = module.vm.ip_address != ""
#     error_message = "RHEL VM should receive an IP address"
#   }
#
#   # Validate DNS record
#   assert {
#     condition     = length(module.domain-name-system-management.a_records) > 0
#     error_message = "DNS A record should be created for RHEL VM"
#   }
# }

# ============================================================================
# Cleanup Notes
# ============================================================================
# Resources are destroyed in REVERSE run block order:
# 1. RHEL VM (last created, first destroyed)
# 2. Production VM
# 3. Custom disk VM
# 4. Medium VM
# 5. Linux Ubuntu VM (first created, last destroyed)
#
# To prevent cleanup (for debugging):
#   terraform test -no-cleanup tests/integration_test.tftest.hcl
#
# To manually clean up after -no-cleanup:
#   cd tests/.terraform/test-runs/<test-id>
#   terraform destroy
