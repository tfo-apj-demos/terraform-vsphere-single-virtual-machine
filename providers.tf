terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.5.1"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.77.0"
    }
    # ad = {
    #   source  = "hashicorp/ad"
    #   version = "0.4.4"
    # }
  }
}