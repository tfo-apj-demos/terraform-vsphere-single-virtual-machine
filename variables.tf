variable "os_type" {
  description = "The type of operating system to be provisioned"
  type        = string
  validation {
    condition     = var.os_type == "windows" || var.os_type == "linux"
    error_message = "The os_type must be either 'windows' or 'linux'."
  }
}

variable "hostname" {
  description = "The hostname of the VM being provisioned. If left blank a hostname will be generated."
  type        = string
  default     = ""
}

variable "size" {
  description = "T-shirt size for the VM (e.g., small, medium, large)"
  type        = string
  validation {
    condition     = contains(["small", "medium", "large"], var.size)
    error_message = "Size must be one of 'small', 'medium', or 'large'."
  }
}

variable "disk_0_size" {
  default = 60
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
  description = "The resource tier for the VM (e.g., gold, silver, bronze, management)"
  type        = string
  validation {
    condition     = contains(["gold", "silver", "bronze", "management"], var.tier)
    error_message = "Tier must be 'gold', 'silver', 'gold' or 'management'."
  }
}

variable "security_profile" {
  description = "The security profile for the VM (e.g., web-server, db-server)"
  type        = string
  validation {
    condition     = contains(["web-server", "db-server", "app-server"], var.security_profile)
    error_message = "Security profile must be one of 'web-server', 'app-server' or 'db-server'."
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
  default     = "Demo Workloads"
}

variable "custom_text" {
  description = "Custom text to be rendered in userdata."
  type        = string
  default     = "some text to be rendered"
}

variable "ad_domain" {
  type = string
}

variable "domain_admin_user" {
  type      = string
  sensitive = true
  default   = ""
}

variable "domain_admin_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "admin_password" {
  type      = string
  sensitive = true
  default   = ""
}