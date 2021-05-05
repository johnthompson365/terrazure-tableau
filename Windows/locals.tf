# Resource naming and tagging decision guide
# https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/decision-guides/resource-tagging/
locals {
  default_tags = {
    env   = var.environment
    stack = var.stack
    DataClassification = var.DataClassification
  }

  default_vm_tags = {
    os_family       = "windows"
    os_distribution = lookup(var.vm_image, "offer", "undefined")
    os_version      = lookup(var.vm_image, "sku", "undefined")
  }
}