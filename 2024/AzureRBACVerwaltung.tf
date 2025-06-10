terraform {
    required_providers {
        azurerm = { source  = "hashicorp/azurerm", version = "4.3.0" }
        azuread = { source  = "hashicorp/azuread", version = "3.1.0" } 
    }
}
provider "azurerm" {
    features {}
    subscription_id = "your_subscription_id"
}

data "azuread_group" "developer_group" {
    display_name = "AZ-RG.DeveloperTeam" # Name of the Azure AD group
}

resource "azurerm_resource_group" "rg" {
    name     = "rg-DeveloperTest-westeu" 
    location = "West Europe"
}

resource "azurerm_role_assignment" "assignments" {
    scope                = azurerm_resource_group.rg.id
    role_definition_name = "Contributor"
    principal_id         = data.azuread_group.developer_group.object_id # Assigning the role to the Azure AD group
}
