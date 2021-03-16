# Create a Linux virtual machine
# https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                            = "${var.prefix}-TFVM"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.nic.id]
  size                            = "Standard_D8s_v3"  #"Standard_DS1_v2" #
  admin_username                  = var.admin_username
  computer_name                   = "${var.prefix}-TFVM"
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }
  
  os_disk {
    name              = "${var.prefix}-OsDisk"
    caching           = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb      = "128"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # secret {
  #   key_vault_id = azurerm_key_vault.tabwinkv.id
  #   #key_vault_id = var.key_vault_id
  #   certificate {
  #     url   = azurerm_key_vault_certificate.winrm_certificate.secret_id
  #     store = "My"
  #   }
  # }



resource "azurerm_managed_disk" "DataDisk" {
  name                 = "${var.prefix}-DataDisk"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 127
}

resource "azurerm_virtual_machine_data_disk_attachment" "DataDisk" {
    managed_disk_id = azurerm_managed_disk.DataDisk.id
    virtual_machine_id = azurerm_linux_virtual_machine.linux_vm.id
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

}
