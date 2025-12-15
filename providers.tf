terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.104"
    }
    ad = {
      source  = "hashicorp/ad"
      version = "~> 0.5"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "~> 3.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Provider configurations removed - they must be defined in the calling module
# This allows the module to be used with count, for_each, and depends_on
#
# The calling module should define providers like this:
#
# provider "vsphere" {
#   allow_unverified_ssl = true
# }
#
# provider "hcp" {
#   project_id = "your-project-id"
# }