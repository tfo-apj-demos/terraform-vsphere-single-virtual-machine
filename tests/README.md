# Terraform Tests for vSphere Single Virtual Machine Module

This directory contains comprehensive tests for the vSphere single virtual machine module. The tests are organized into unit tests (fast, no resource creation) and integration tests (creates real infrastructure).

## Test Organization

### Unit Tests (Plan Mode - Fast, No Resources Created)

Unit tests use `command = plan` and validate Terraform logic without creating real infrastructure. These tests are fast, free, and safe to run frequently.

- **`defaults_unit_test.tftest.hcl`** - Tests default module configuration, tag generation, mappings, outputs
- **`validation_unit_test.tftest.hcl`** - Tests all input variable validation rules (31 tests covering invalid inputs)
- **`os_types_unit_test.tftest.hcl`** - Tests HCP Packer image selection, OS-specific behavior, AD computer object logic
- **`edge_cases_unit_test.tftest.hcl`** - Tests edge cases, special characters, min/max configurations

### Integration Tests (Apply Mode - Creates Real Resources)

Integration tests use `command = apply` (default) and create actual infrastructure. These tests are slower, may incur costs, and should only be run in dedicated test environments.

- **`integration_test.tftest.hcl`** - End-to-end tests creating real VMs in vSphere

## Running Tests

### Prerequisites

1. **Terraform 1.6.0 or later** (testing framework introduced in 1.6.0)
2. **Provider Configuration**:
   - vSphere provider credentials
   - HCP Terraform/Packer credentials
   - Active Directory provider (for Windows VM tests)
   - DNS provider credentials

### Run All Unit Tests (Recommended)

Run only unit tests for fast feedback without creating resources:

```bash
# From module root directory
terraform test -filter="*_unit_test"
```

### Run Specific Test File

```bash
terraform test tests/defaults_unit_test.tftest.hcl
terraform test tests/validation_unit_test.tftest.hcl
terraform test tests/os_types_unit_test.tftest.hcl
terraform test tests/edge_cases_unit_test.tftest.hcl
```

### Run All Tests (Including Integration)

⚠️ **WARNING**: This creates real infrastructure and may incur costs!

```bash
terraform test
```

### Run Integration Tests Only

⚠️ **WARNING**: This creates real VMs in vSphere!

```bash
terraform test tests/integration_test.tftest.hcl
```

### Run with Verbose Output

```bash
terraform test -verbose
```

### Debug Tests (Prevent Cleanup)

If tests fail and you want to inspect the created resources:

```bash
terraform test -no-cleanup tests/integration_test.tftest.hcl
```

To manually clean up after `-no-cleanup`:

```bash
cd .terraform/test-runs/<run-id>
terraform destroy
```

## Test Coverage

### What's Tested

✅ **Variable Validation** (31 validation tests)
- OS type validation (windows, linux, mssql)
- Linux distribution validation (ubuntu, rhel)
- Size validation (small → 4xlarge)
- Environment validation (dev, test, prod)
- Site validation (sydney, canberra, melbourne)
- Storage profile validation
- Tier validation (gold, silver, bronze, management)
- Security profile validation
- Backup policy validation

✅ **Image Selection Logic**
- HCP Packer artifact selection based on OS type
- Linux distribution to image mapping
- Windows/MSSQL image selection
- Data source configuration

✅ **Conditional Resource Creation**
- AD computer object creation for Windows VMs
- No AD object for Linux VMs
- DNS record creation for all VM types

✅ **Configuration Mappings**
- T-shirt size to CPU/memory mapping
- Environment to cluster mapping
- Site to datacenter mapping
- Tier to resource pool mapping
- Storage profile to datastore mapping

✅ **Tag Generation**
- All required tags are set correctly
- Tag values match input variables

✅ **Module Outputs**
- All outputs are defined and non-empty
- Outputs match child module values

✅ **Edge Cases**
- Null/empty hostnames
- Long hostnames and paths
- Sensitive variables
- Min/max resource configurations
- Special characters in inputs

### Integration Test Coverage

The integration tests validate:
- Actual VM creation in vSphere
- IP address assignment
- Cluster assignment
- DNS record creation
- Different VM sizes
- Different OS types (Ubuntu, RHEL)
- Custom configurations (disk size, environment, tier)

## Test Results Interpretation

### Successful Test Run

```
tests/defaults_unit_test.tftest.hcl... in progress
  run "test_linux_ubuntu_defaults"... pass
  run "test_hostname_configuration"... pass
  ...
tests/defaults_unit_test.tftest.hcl... pass

Success! 14 passed, 0 failed.
```

### Failed Test Example

```
tests/validation_unit_test.tftest.hcl... in progress
  run "test_invalid_os_type"... pass
  run "test_valid_os_type_windows"... fail
    Error: Test assertion failed

    Windows should be a valid os_type

Success! 1 passed, 1 failed.
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Terraform Tests

on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.0

      - name: Terraform Init
        run: terraform init

      - name: Run Unit Tests
        run: terraform test -filter="*_unit_test" -verbose
        env:
          HCP_CLIENT_ID: ${{ secrets.HCP_CLIENT_ID }}
          HCP_CLIENT_SECRET: ${{ secrets.HCP_CLIENT_SECRET }}

  integration-tests:
    runs-on: ubuntu-latest
    # Only run integration tests on main branch
    if: github.ref == 'refs/heads/main'
    needs: unit-tests
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.0

      - name: Terraform Init
        run: terraform init

      - name: Run Integration Tests
        run: terraform test tests/integration_test.tftest.hcl -verbose
        env:
          VSPHERE_SERVER: ${{ secrets.VSPHERE_SERVER }}
          VSPHERE_USER: ${{ secrets.VSPHERE_USER }}
          VSPHERE_PASSWORD: ${{ secrets.VSPHERE_PASSWORD }}
          HCP_CLIENT_ID: ${{ secrets.HCP_CLIENT_ID }}
          HCP_CLIENT_SECRET: ${{ secrets.HCP_CLIENT_SECRET }}
```

## Best Practices

1. **Run unit tests frequently** - They're fast and catch most issues
2. **Run integration tests sparingly** - Only before releases or major changes
3. **Use dedicated test environment** - Never run integration tests in production
4. **Review test output** - Check all assertions, not just pass/fail
5. **Keep tests updated** - Update tests when module logic changes
6. **Test edge cases** - Include boundary conditions and unusual inputs
7. **Use descriptive test names** - Make it clear what each test validates
8. **Document test requirements** - List all provider credentials needed

## Troubleshooting

### Common Issues

**Issue**: `Error: Inconsistent dependency lock file`
```bash
# Solution: Re-initialize and upgrade providers
terraform init -upgrade
```

**Issue**: `Error: Failed to query available provider packages`
```bash
# Solution: Check provider authentication
export HCP_CLIENT_ID="your-client-id"
export HCP_CLIENT_SECRET="your-client-secret"
```

**Issue**: Tests fail due to missing HCP Packer images
```bash
# Solution: Verify HCP Packer buckets exist:
# - base-ubuntu-2204
# - base-windows-2022
# - base-rhel-9
# - mssql-windows-2022
```

**Issue**: Integration tests timeout
```bash
# Solution: Increase timeout or check vSphere connectivity
# VMs may take 5-10 minutes to provision
```

## Test Statistics

- **Total Test Files**: 5 (4 unit test files, 1 integration test file)
- **Total Test Runs**: 90+ individual test scenarios
- **Unit Tests**: 80+ tests (run in seconds)
- **Integration Tests**: 5+ tests (run in minutes)
- **Expected Runtime**:
  - Unit tests: < 30 seconds
  - Integration tests: 10-30 minutes (depending on VM provisioning time)

## Contributing

When adding new features to the module:

1. Add corresponding unit tests in the appropriate test file
2. Add validation tests for any new input variables
3. Update integration tests if new resources are created
4. Run all unit tests before submitting PR
5. Document any new test requirements in this README

## References

- [Terraform Testing Documentation](https://developer.hashicorp.com/terraform/language/tests)
- [Terraform Test Command](https://developer.hashicorp.com/terraform/cli/commands/test)
- [Testing Best Practices](https://developer.hashicorp.com/terraform/language/tests/best-practices)
