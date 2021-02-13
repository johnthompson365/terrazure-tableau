data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = azurerm_windows_virtual_machine.windows_vm.resource_group_name
  depends_on          = [azurerm_windows_virtual_machine.windows_vm]
}