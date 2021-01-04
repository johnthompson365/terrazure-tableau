variable "OS" {
  type = string
  description = "What OS do you want? Type windows or linux"
}

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
  default = "TABLIN"
}

variable "tags" {
  type = map

  default = {
    Environment = "Tableau-Linux"
  }
}

variable "location" {
  type = string
  default = "westus2"
  }

variable "sku" {
  default = {
    westus2 = "18.04-LTS"
  }
}


