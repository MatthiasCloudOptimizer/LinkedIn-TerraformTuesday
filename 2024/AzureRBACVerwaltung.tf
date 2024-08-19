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

data "azuread_group" "developer_group" {
  display_name = "AZ-RG.DeveloperTeam" # The Entra ID group must exist
}

# Azure resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg-DeveloperTest-westeu"
  location = "West Europe"
}

# Resource group role assigment
resource "azurerm_role_assignment" "assignments" {
    scope                = azurerm_resource_group.rg.id
    role_definition_name = "Contributor"
    principal_id         = data.azuread_group.developer_group.object_id
}
