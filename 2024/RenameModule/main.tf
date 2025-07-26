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
    subscription_id = "7fae56f8-ef32-4c6a-a8c1-53be8241e468"
    #your_subscription_id
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

# Module call
module "azure-example" {
    source  = "2024/AzureVirtualNetwork/"

    resource_group_name    = azurerm_resource_group.rg.name
    location               = azurerm_resource_group.rg.location
    name                   = "vnet-AdmJumpServer-dev-westeu"
    primary_address_prefix = ["10.0.1.0/24"]

}

# Module call
module "azure-vNet" {
    source  = "2024/AzureVirtualNetwork/"

    resource_group_name    = azurerm_resource_group.rg.name
    location               = azurerm_resource_group.rg.location
    name                   = "vnet-AdmJumpServer-dev-westeu"
    primary_address_prefix = ["10.0.1.0/24"]

}