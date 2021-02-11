# copied from https://github.com/claranet/terraform-azurerm-windows-vm

resource "azurerm_key_vault" "tabwinkv" {
  name                        = "tabwinkv-jt365tb01"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

# https://github.com/terraform-providers/terraform-provider-azurerm/issues/4569
resource "azurerm_key_vault_access_policy" "vm" {
  key_vault_id = azurerm_key_vault.tabwinkv.id

  object_id = azurerm_windows_virtual_machine.windows_vm.identity.0.principal_id
  tenant_id = var.tenant_id #data.azurerm_client_config.current.tenant_id
  certificate_permissions = [ 
    "create",
    "delete",
    "deleteissuers",
    "get",
    "getissuers",
    "import",
    "list",
    "listissuers",
    "managecontacts",
    "manageissuers",
    "setissuers",
    "update",
    "purge"
  ]
  secret_permissions = ["get", "list", "purge"]
}

resource "azurerm_key_vault_certificate" "winrm_certificate" {
  name         = "winrm-${var.prefix}-cert"
  key_vault_id = azurerm_key_vault.tabwinkv.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject            = "CN=${var.prefix}-TFVM"
      validity_in_months = var.certificate_validity_in_months
    }
  }
}

# # Understand this or comment it out ;)   !!!
# resource "azurerm_virtual_machine_extension" "keyvault_certificates" {
#   https://www.terraform.io/docs/language/meta-arguments/count.html
#   # count = var.key_vault_certificates_names != [] ? 1 : 0

#   name = "${azurerm_windows_virtual_machine.windows_vm.name}-keyvaultextension"

#   publisher                  = "Microsoft.Azure.KeyVault"
#   type                       = "KeyVaultForWindows"
#   type_handler_version       = "1.0"
#   auto_upgrade_minor_version = true

#   virtual_machine_id = azurerm_windows_virtual_machine.windows_vm.id

#   settings = jsonencode({
#     secretsManagementSettings : {
#       pollingIntervalInS       = tostring(var.key_vault_certificates_polling_rate)
#       certificateStoreName     = "MY"
#       certificateStoreLocation = "LocalMachine",
#       requiredInitialSync      = true
#       # https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/key-vault-windows
#       # Your observed certificates URLs should be of the form https://myVaultName.vault.azure.net/secrets/myCertName.
#       # This is because the /secrets path returns the full certificate, including the private key, while the /certificates path does not.
#       # https://www.terraform.io/docs/language/functions/formatlist.html
#       # https://www.terraform.io/docs/language/functions/format.html
#       observedCertificates     = formatlist("https://%s.vault.azure.net/secrets/%s", local.key_vault_name, var.key_vault_certificates_names)
#     }
#   })

#   depends_on = [azurerm_key_vault_access_policy.vm]
# }
