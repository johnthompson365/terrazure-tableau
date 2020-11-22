variable "location" {}

variable "admin_username" {
  type        = string
  description = "Administrator for the VM"
}

variable "admin_password" {
  type        = string
  description = "Administrator password must meet complexity requirements"
}

variable "prefix" {
  type    = string
  default = "TABLIN"
}

variable "tags" {
  type = map

  default = {
    Environment = "Tableau-Linux"
  }
}

variable "sku" {
  default = {
    westus2 = "18.04-LTS"
  }
}


