# WinRM Research - this is closest to my lab https://github.com/jmassardo/Azure-WinRM-Terraform
# WinRM in a domain -> http://www.anniehedgie.com/terraform-and-winrm
# Sample tested on W2012R2 https://github.com/Azure/azure-quickstart-templates/tree/master/201-vm-winrm-windows
# Later version with W2019 https://www.starwindsoftware.com/blog/azure-execute-commands-in-a-vm-through-terraform
# NEED TO TEST IF WINRM IS LISTENING? https://stevenmurawski.com/2015/06/need-to-test-if-winrm-is-listening/
# https://registry.terraform.io/modules/claranet/windows-vm/azurerm/latest


# Create a Windows virtual machine
resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                      = "${var.prefix}-TFVM"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
  network_interface_ids     = [azurerm_network_interface.nic.id]
  size                      = "Standard_D8s_v3" #"Standard_DS1_v2" #
  admin_username            = var.admin_username
  admin_password            = var.admin_password
  computer_name             = "${var.prefix}-TFVM"
  provision_vm_agent        = true
  enable_automatic_updates  = true
  
  os_disk {
    name              = "${var.prefix}-OsDisk"
    caching           = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb      = "128"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  # winrm_listener {
  #   protocol = "Http"
  # }

  # copied from https://github.com/claranet/terraform-azurerm-windows-vm

  secret {
    key_vault_id = azurerm_key_vault.tabwinkv.id
    #key_vault_id = var.key_vault_id
    certificate {
      url   = azurerm_key_vault_certificate.winrm_certificate.secret_id
      store = "My"
    }
  }

  # Auto-Login's required to configure WinRM
  additional_unattend_content {
    setting = "AutoLogon"
    content = "<AutoLogon><Password><Value>${var.admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.admin_username}</Username></AutoLogon>"
  }

  # Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
  additional_unattend_content {
    setting = "FirstLogonCommands"
    content = file("./files/FirstLogonCommands.xml") #file(format("%s/files/FirstLogonCommands.xml", path.module))
  }
  # https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview
  identity {
    type = "SystemAssigned"
  }

  # https://docs.microsoft.com/en-us/azure/virtual-machines/custom-data
  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/6138
    custom_data    = base64encode(local.custom_data_content)
}

resource "azurerm_managed_disk" "DataDisk" {
  name                 = "${var.prefix}-DataDisk"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 127
}

resource "azurerm_virtual_machine_data_disk_attachment" "DataDisk" {
    managed_disk_id = azurerm_managed_disk.DataDisk.id
    virtual_machine_id = azurerm_windows_virtual_machine.windows_vm.id
    lun = "10"
    caching = "ReadWrite"
}

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
}
