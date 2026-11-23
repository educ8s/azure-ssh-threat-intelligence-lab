variable "admin_source_ips" {
  description = "IPs allowed to reach real SSH on port 2222"
  type        = list(string)
  }

  variable "vm_size" {
    description = "Size of the VM"
    type        = string
    default     = "Standard_D2als_v6"
  }

  variable "admin_username" {
    description = "Admin username for the VM"
    type        = string
    default     = "nickadmin"
  }