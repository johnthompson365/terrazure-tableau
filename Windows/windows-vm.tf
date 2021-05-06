# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "${var.prefix}-NIC"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.prefix}-NICConfg"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
  tags = merge(local.default_tags, local.default_vm_tags)
}

# Create a Windows virtual machine
resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                      = "${var.prefix}-TFVM"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
  network_interface_ids     = [azurerm_network_interface.nic.id]
  size                      = "Standard_D8s_v3"  #"Standard_DS1_v2" #
  admin_username            = var.admin_username
  admin_password            = var.admin_password
  computer_name             = "${var.prefix}-TFVM"
  provision_vm_agent        = true
  enable_automatic_updates  = true
  tags = merge(local.default_tags, local.default_vm_tags)

  os_disk {
    name              = "${var.prefix}-OsDisk"
    caching           = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb      = "128"
  }

  source_image_reference {
    offer     = lookup(var.vm_image, "offer", null)
    publisher = lookup(var.vm_image, "publisher", null)
    sku       = lookup(var.vm_image, "sku", null)
    version   = lookup(var.vm_image, "version", null)
  }
}

# https://github.com/MicrosoftDocs/azure-docs/issues/10862
# https://docs.microsoft.com/en-us/cli/azure/vm/extension/image?view=azure-cli-latest
# Found I had to use a minor version, not a patch e.g. 1.10 not 1.10.5 - Maybe I need to use the minor version upgrade thingy?
resource "azurerm_virtual_machine_extension" "tableau" {
  name                 = "${var.prefix}-TFVM"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
# Keep on getting this error after 30 minutes but the install takes longer, around 40 minutes! Error: Future#WaitForCompletion: context has been cancelled: StatusCode=200 -- Original Error: context deadline exceeded
 timeouts {
    create = "60m"
    delete = "2h"
  }


  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -Command \"./wintab-deploy.ps1; exit 0;\""
    }
  PROTECTED_SETTINGS

  settings = <<SETTINGS
    {
        "fileUris": ["https://raw.githubusercontent.com/johnthompson365/terrazure-tableau/3220b71b4019c7b28ccf29d81fede7ff2d3d8928/Windows/files/wintab-deploy.ps1"]
    }
  SETTINGS
}