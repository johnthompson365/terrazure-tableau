output "public_ip_address" {
  value = data.azurerm_public_ip.ip.ip_address
}

output "vm_name" {
  description = "Name of the Virtual machine"
  value       = azurerm_windows_virtual_machine.windows_vm.name
}

output "vm_private_ip_address" {
  description = "Private IP address of the Virtual machine"
  value       = azurerm_network_interface.nic.private_ip_address
}

