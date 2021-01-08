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


