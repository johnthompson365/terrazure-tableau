# Copied from https://github.com/claranet/terraform-azurerm-windows-vm

resource "null_resource" "winrm_connection_test" {
  count = var.public_ip_sku == null ? 0 : 1

  depends_on = [
    azurerm_network_interface.nic,
    azurerm_public_ip.publicip,
    azurerm_windows_virtual_machine.windows_vm,
  ]

  # https://www.cloudmanav.com/terraform/executing-scripts-terraform-template/#  
  triggers = {
    uuid = azurerm_windows_virtual_machine.windows_vm.id
  }

  connection {
    type     = "winrm"
    host     = join("", azurerm_public_ip.publicip.*.ip_address)
    port     = 5986
    https    = true
    user     = var.admin_username
    password = var.admin_password
    timeout  = "3m"

    # NOTE: if you're using a real certificate, rather than a self-signed one, you'll want this set to `false`/to remove this.
    insecure = true
  }

  # https://www.terraform.io/docs/language/resources/provisioners/file.html
  provisioner "file" {
    source      = "files/wintab-deploy.ps1"
    destination = "C:\\jt365\\New-ScheduledTask.ps1"
  }

  provisioner "file" {
    source      = "files/wintab-deploy-original.ps1"
    destination = "C:\\jt365\\wintab-deploy-original.ps1"
  }

  provisioner "remote-exec" {
    inline = [
      "cd C:\\jt365",
      "dir",
      "PowerShell.exe -ExecutionPolicy Bypass -File c:\\jt365\\New-ScheduledTask.ps1",
    ]
  }
}