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
    subscription_id = "7fae56f8-ef32-4c6a-a8c1-53be8241e468"
}

# Azure resource group
resource "azurerm_resource_group" "rg" {
    name     = "rg-DeveloperTest-westeu"
    location = "West Europe"
    tags = var.tags
}
