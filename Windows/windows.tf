# WinRM Research - this is closest to my lab https://github.com/jmassardo/Azure-WinRM-Terraform
# WinRM in a domain -> http://www.anniehedgie.com/terraform-and-winrm
# Sample tested on W2012R2 https://github.com/Azure/azure-quickstart-templates/tree/master/201-vm-winrm-windows
# Later version with W2019 https://www.starwindsoftware.com/blog/azure-execute-commands-in-a-vm-through-terraform
# https://stevenmurawski.com/2015/06/need-to-test-if-winrm-is-listening/

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-TFResourceGroup"
  location = var.location
  tags = var.tags
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-TFVnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-TFsubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "${var.prefix}-TFPublicIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-TFNSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "98.155.197.8"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Tableau-mgmt"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8850"
    source_address_prefix      = "98.155.197.8"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "WinRM"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "98.155.197.8"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "web"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
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

# Create a Windows virtual machine
resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                  = "${var.prefix}-TFVM"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_DS1_v2"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  computer_name  = "${var.prefix}-TFVM"
  
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

  winrm_listener {
    protocol = "Http"
  }
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

data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = azurerm_windows_virtual_machine.windows_vm.resource_group_name
  depends_on          = [azurerm_windows_virtual_machine.windows_vm]
}

output "public_ip_address" {
  value = data.azurerm_public_ip.ip.ip_address
}

