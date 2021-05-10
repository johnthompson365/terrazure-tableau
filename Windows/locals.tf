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

# https://discuss.hashicorp.com/t/how-to-use-templatefile-to-pass-a-powershell-script-into-commandtoexecute/17916/2
# https://www.terraform.io/docs/language/functions/templatefile.html
locals {
  powershell_script = templatefile("${path.module}/files/CommandToExecute.ps1", {
    URL =   var.URL_download
    Folder = var.Folder_download
  })
}

# https://www.terraform.io/docs/language/functions/replace.html
# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/n
# https://forum.freecodecamp.org/t/spinal-tap-case-operator/56148
# https://stackoverflow.com/questions/4025482/cant-escape-the-backslash-with-regex
locals {
  powershell_command = <<-EOT
    powershell.exe -executionpolicy bypass -command "${
        replace(local.powershell_script, "/([\"\\\\])/", "\\\\$1")
    }"
  EOT
}

locals {
  powershell_command_for_cmd = replace(local.powershell_command, "/([&\\\\<>^|])/", "^$1")
}