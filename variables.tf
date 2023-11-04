variable "vsphere_user" {
  description = "vSphere username"
  type        = string
  default     = ""
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "vsphere_server" {
  description = "vSphere server address"
  type        = string
  default     = ""
}

variable "hostname" {
  description = "The hostname of the VM being provisioned."
  type        = string
  validation {
    condition     = length(trimspace(var.hostname)) > 0
    error_message = "The hostname must not be empty and should not contain any leading or trailing whitespace."
  }
}

variable "size" {
  description = "T-shirt size for the VM (e.g., small, medium, large)"
  type        = string
  validation {
    condition     = contains(["small", "medium", "large"], var.size)
    error_message = "Size must be one of 'small', 'medium', or 'large'."
  }
}

variable "environment" {
  description = "The environment of the VM (e.g., dev, test, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of 'dev', 'test', or 'prod'."
  }
}

variable "site" {
  description = "The site or datacenter location for the VM (e.g., sydney, canberra, melbourne)"
  type        = string
  validation {
    condition     = contains(["sydney", "canberra", "melbourne"], var.site)
    error_message = "Site must be one of 'east', 'west', or 'central'."
  }
}

variable "storage_profile" {
  description = "The storage profile for the VM (e.g., performance, capacity, standard)"
  type        = string
  validation {
    condition     = contains(["performance", "capacity", "standard"], var.storage_profile)
    error_message = "Storage profile must be one of 'performance', 'capacity', or 'standard'."
  }
}

variable "tier" {
  description = "The resource tier for the VM (e.g., gold, silver, bronze)"
  type        = string
  validation {
    condition     = contains(["gold", "silver", "bronze"], var.tier)
    error_message = "Tier must be 'gold', 'silver', or 'bronze'."
  }
}



variable "security_profile" {
  description = "The security profile for the VM (e.g., web-server, db-server)"
  type        = string
  validation {
    condition     = contains(["web-server", "db-server"], var.security_profile)
    error_message = "Security profile must be one of 'web-server' or 'db-server'."
  }
}

variable "backup_policy" {
  description = "The backup policy for the VM (e.g., daily, weekly, monthly)"
  type        = string
  validation {
    condition     = contains(["daily", "weekly", "monthly"], var.backup_policy)
    error_message = "Backup policy must be one of 'daily', 'weekly', or 'monthly'."
  }
}

variable "folder_path" {
  description = "The path to the VM folder where the virtual machine will be created."
  type        = string
  default     = "Datacenter/vm/demo workloads"
}

variable "custom_text" {
  description = "Custom text to be rendered in userdata."
  type        = string
  default     = "some text to be rendered"
}

variable "vsphere_template_name" {
  description = "The name of the vSphere template to use for VM creation."
  type        = string
  default     = "base-ubuntu-2204-20231103114728"
}