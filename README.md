# Terraform vSphere Virtual Machine Module

## Demonstrate Pattern 1 for Private Cloud Environment

<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=12sLHNUPnGfoheHK0XI9u-rK28bGCb4G0" alt="Image 1 Description" width="45%" />
  &nbsp; &nbsp; &nbsp;  <!-- Spacing between images -->
</p>

This module provisions virtual machines on a vSphere cluster using the [terraform-vsphere-virtual-machine](https://github.com/tfo-apj-demos/terraform-vsphere-virtual-machine) module while abstracting the complexity with predefined "t-shirt sizes" for CPU and memory, and mappings for cluster and datastore selection based on environment and storage profile.

## Requirements

- Terraform 0.12 and newer.
- vSphere provider.

## Providers

| Name     | Version |
|----------|---------|
| vsphere  |  2.5.1  |

## Resources

This module creates the following resources:

- vSphere Virtual Machine

## Usage

Example usage for provisioning a 'small' size VM in a 'dev' environment located at the 'sydney' site with a 'performance' storage profile:

\```hcl
module "vm" {
  source = "github.com/tfo-apj-demos/terraform-vsphere-virtual-machine"

  vsphere_template_name = "base-ubuntu-2204-20231103114728"
  hostname              = "example-vm"
  size                  = "small"
  environment           = "dev"
  site                  = "sydney"
  storage_profile       = "performance"
  tier                  = "gold"
  folder_path           = "Datacenter/vm/demo workloads"
  custom_text           = "This is an example."
  vsphere_user          = "your-vsphere-username"
  vsphere_password      = "your-vsphere-password"
  vsphere_server        = "your-vsphere-server-address"
}
\```

## Variables

| Name                    | Description                                           | Type     | Default                           | Required |
|-------------------------|-------------------------------------------------------|----------|-----------------------------------|:--------:|
| `vsphere_user`          | vSphere username.                                     | `string` |                                   | Yes      |
| `vsphere_password`      | vSphere password.                                     | `string` |                                   | Yes      |
| `vsphere_server`        | vSphere server address.                               | `string` |                                   | Yes      |
| `hostname`              | The hostname of the VM being provisioned.             | `string` |                                   | Yes      |
| `size`                  | T-shirt size for the VM (e.g., small, medium, large). | `string` |                                   | Yes      |
| `environment`           | The environment of the VM (e.g., dev, test, prod).    | `string` |                                   | Yes      |
| `site`                  | The site or datacenter location for the VM.           | `string` |                                   | Yes      |
| `storage_profile`       | The storage profile for the VM.                       | `string` |                                   | Yes      |
| `tier`                  | The resource tier for the VM.                         | `string` |                                   | Yes      |
| `security_profile`      | The security profile for the VM.                      | `string` |                                   | No       |
| `backup_policy`         | The backup policy for the VM.                         | `string` |                                   | No       |
| `folder_path`           | The path to the VM folder.                            | `string` | `"Datacenter/vm/demo workloads"`  | No       |
| `custom_text`           | Custom text to be rendered in userdata.               | `string` | `"some text to be rendered"`      | No       |
| `vsphere_template_name` | The vSphere template to use for creating the VM.      | `string` | `"base-ubuntu-2204-20231103114728"` | No    |