variable "admin_username" {
  type        = string
  description = "Administrator for the VM"
}

variable "admin_password" {
  type        = string
  description = "Input a password for Azure complexity requirements"
}

variable "prefix" {
  type    = string
  default = "TABWIN"
}

variable "tags" {
  type = map

  default = {
    Environment = "Tableau-Windows"
  }
}

variable "location" {
  type = string
  default = "westus"
  }

variable "source_ip_address" {
  type = string
  default = "Specify your current IP address"
  }

variable "tenant_id" {
  type        = string
  description = "Input your Azure Tenant ID here"
}

variable "public_ip_sku" {
  description = "Sku for the public IP attached to the VM. Can be `null` if no public IP needed."
  type        = string
  default     = "Standard"
}