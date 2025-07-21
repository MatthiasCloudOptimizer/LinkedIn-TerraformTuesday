output "public_ip_address" {
    description = "Public IP address of the virtual machine"
    value       = azurerm_public_ip.pip.ip_address
}

output "ssh_command" {
    description = "Command to connect to the VM using Azure CLI"
    value       = "az ssh vm -n ${var.vm_name} -g ${azurerm_resource_group.rg.name}"
}