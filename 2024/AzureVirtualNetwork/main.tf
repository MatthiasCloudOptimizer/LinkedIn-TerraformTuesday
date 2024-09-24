terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">=3.89.0"
        }
    }
}
provider "azurerm" {
    features {}
    subscription_id = "your_subscription_id"
}

# Azure resource group
resource "azurerm_resource_group" "rg" {
    name     = "rg-JumpServer-westeu"
    location = "West Europe"
    tags = {
        "Environment"               = "Dev" 
        "Workload"                  = "Jump-Server" 
        "Workload_Department"       = "Business Services" 
    }
}

# Azure virtual network (VNet)
resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-JumpServer-westeu"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space       = ["10.0.0.0/16"]
    dns_servers         = ["10.0.0.4", "10.0.0.5"]

    # inline subnet
    subnet {
        name             = "snet-JumpServer-westeu"
        address_prefixes = ["10.0.1.0/24"]
    }

    tags = {
        "Environment"               = "Dev" 
        "Workload"                  = "Jump-Server" 
        "Workload_Department"       = "Business Services" 
    }
}