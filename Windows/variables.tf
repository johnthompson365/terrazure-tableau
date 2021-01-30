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
  default = "ADFS"
}

variable "tags" {
  type = map

  default = {
    Environment = "Tableau-Windows"
  }
}

# variable "resource_group" {
#   type = string
#   default = "rg-tableau"
#   }

variable "location" {
  type = string
  default = "westus2"
  }

variable "tenant_id" {
  type        = string
  description = "Input your Azure Teannt ID here"
}

variable "public_ip_sku" {
  description = "Sku for the public IP attached to the VM. Can be `null` if no public IP needed."
  type        = string
  default     = "Standard"
}

variable "key_vault_id" {
  description = "Id of the Azure Key Vault to use for VM certificate"
  type        = string
  default     = "/subscriptions/95aa9dd0-4394-45e6-bcb3-7131f1989dbb/resourceGroups/rg-tableau/providers/Microsoft.KeyVault/vaults/tabwinkv"
}

variable "key_vault_certificates_names" {
  description = "List of Azure Key Vault certificates names to install in the VM"
  type        = list(string)
  default     = []
}

variable "certificate_validity_in_months" {
  description = "Amount of months for certificate validity"
  type        = number
  default     = 48
}

variable "key_vault_certificates_polling_rate" {
  description = "Polling rate (in seconds) for Key Vault certificates retrieval"
  type        = number
  default     = 300
}

variable "key_vault_certificates_store_name" {
  description = "Name of the cetrificate store on which install the Key Vault certificates"
  type        = string
  default     = "MY"
}