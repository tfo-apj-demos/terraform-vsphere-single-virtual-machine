terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.5.1"
    }

    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.10"
    }
  }
}

provider "vsphere" {
}