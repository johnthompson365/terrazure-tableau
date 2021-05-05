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

variable "environment" {
  type = string
  default = "dev"
  }

variable "stack" {
  type = string
  default = "Analytics"
  }

variable "DataClassification" {
  type = string
  default = "Public"
  }

variable "vm_image" {
  description = "Virtual Machine source image information. See https://www.terraform.io/docs/providers/azurerm/r/windows_virtual_machine.html#source_image_reference"
  type        = map(string)

  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
