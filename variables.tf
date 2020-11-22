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
  default = "jtyoyoyo"
}

variable "tags" {
  type = map

  default = {
    Environment = "Terraform JT"
    Dept        = "JT Engineering"
  }
}

variable "sku" {
  default = {
    westus2 = "16.04-LTS"
    eastus  = "18.04-LTS"
  }
}


