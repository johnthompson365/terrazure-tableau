data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = azurerm_linux_virtual_machine.linux_vm.resource_group_name
  depends_on          = [azurerm_linux_virtual_machine.linux_vm]
}