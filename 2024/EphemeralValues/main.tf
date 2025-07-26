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

# Azure resource group
resource "azurerm_resource_group" "rg" {
    name     = "rg-DeveloperTest-westeu"
    location = "West Europe"
    tags = var.tags
}