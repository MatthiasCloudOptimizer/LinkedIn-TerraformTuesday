terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "4.3.0"
        }
    }
}
provider "azurerm" {
    features {}
    subscription_id = "your_subscription_id"
}

locals{
    vmName = "WinSrv001"
}

# Azure resource group
resource "azurerm_resource_group" "rg" {
    name     = "rg-AdmJumpServer-dev-westeu"
    location = "West Europe"
    tags = {
        "Environment"               = "Dev" 
        "Workload"                  = "Jump-Server" 
        "Workload_Department"       = "Business Services" 
    }
}

# Azure virtual network (VNet)
resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-AdmJumpServer-dev-westeu"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space       = ["10.0.0.0/23"]
    dns_servers         = ["10.0.0.4", "10.0.0.5"]

    tags = {
        "Environment"               = "Dev" 
        "Workload"                  = "Jump-Server" 
        "Workload_Department"       = "Business Services" 
    }
}

# Azure subnet (SNet)
resource "azurerm_subnet" "snet" {
    name                 = "snet-AdmJumpServer-dev-westeu"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

# Azure Network Interface (NIC)
resource "azurerm_network_interface" "nic" {
    name                = "nic-AdmJumpServer-dev-westeu"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "ipconf-vm${local.vmName}"
        subnet_id                     = azurerm_subnet.snet.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_windows_virtual_machine" "vm_win2" {
    name                = "vm-${local.vmName}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = "Standard_B2s"
    admin_username      = "adminuser"
    admin_password      = "P@$$w0rd1234!"
    network_interface_ids = [
        azurerm_network_interface.nic.id,
    ]

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
        disk_size_gb         = "127"
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
    }
}

