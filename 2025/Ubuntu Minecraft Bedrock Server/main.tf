# Definiere gemeinsame Tags als lokale Variable
locals {
        common_tags = {
                Owner       = "Matthias"
                Environment = "Prod"
                Usage       = "Minecraft Server"
        }
}

# Resource group
resource "azurerm_resource_group" "rg" {
        name     = "rg-${var.prefix}"
        location = var.location
        tags     = local.common_tags
}

# Virtual network
resource "azurerm_virtual_network" "vnet" {
        name                = "${var.prefix}-vnet"
        address_space       = ["10.0.0.0/27"]
        location           = azurerm_resource_group.rg.location
        resource_group_name = azurerm_resource_group.rg.name
        tags               = local.common_tags
}

# Subnet
resource "azurerm_subnet" "subnet" {
        name                 = "${var.prefix}-subnet"
        resource_group_name  = azurerm_resource_group.rg.name
        virtual_network_name = azurerm_virtual_network.vnet.name
        address_prefixes     = ["10.0.0.0/28"]
}

# Public IP
resource "azurerm_public_ip" "pip" {
        name                = "${var.prefix}-pip"
        location            = azurerm_resource_group.rg.location
        resource_group_name = azurerm_resource_group.rg.name
        allocation_method   = "Static"
        tags               = local.common_tags
}

# NSG
resource "azurerm_network_security_group" "nsg" {
        name                = "${var.prefix}-nsg"
        location            = azurerm_resource_group.rg.location
        resource_group_name = azurerm_resource_group.rg.name
        tags               = local.common_tags

        # ... existing security rules ...
}

# NIC
resource "azurerm_network_interface" "nic" {
        name                = "nic-${var.prefix}"
        location            = azurerm_resource_group.rg.location
        resource_group_name = azurerm_resource_group.rg.name
        tags               = local.common_tags

        ip_configuration {
                name                          = "internal"
                subnet_id                     = azurerm_subnet.subnet.id
                private_ip_address_allocation = "Dynamic"
                public_ip_address_id          = azurerm_public_ip.pip.id
        }
}

# VM
resource "azurerm_linux_virtual_machine" "vm" {
        name                = var.vm_name
        resource_group_name = azurerm_resource_group.rg.name
        location            = azurerm_resource_group.rg.location
        size                = "Standard_F4s_v2"
        admin_username      = "azureuser"
        network_interface_ids = [azurerm_network_interface.nic.id]

        os_disk {
                caching              = "ReadWrite"
                storage_account_type = "Standard_LRS"
        }

        source_image_reference {
                publisher = "Canonical"
                offer     = "UbuntuServer"
                sku       = "22_04-lts-gen2"
                version   = "latest"
        }

        tags               = local.common_tags
}

# Managed disk
resource "azurerm_managed_disk" "data_disk" {
        name                 = "${var.prefix}-data-disk"
        location            = azurerm_resource_group.rg.location
        resource_group_name = azurerm_resource_group.rg.name
        storage_account_type = "Premium_LRS"
        create_option       = "Empty"
        disk_size_gb       = 30
        tags               = local.common_tags
}
