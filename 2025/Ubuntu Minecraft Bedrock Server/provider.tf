terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "~> 3.0"
        }
    }
    required_version = ">= 1.0"
}

provider "azurerm" {
    features {}
    # Subscription ID per Umgebungsvariablen setzen (z.B. in deiner PowerShell): $env:ARM_SUBSCRIPTION_ID = "deine-subscription-id"
    # keine Subscription ID in der Provider-Konfiguration angeben, da sie aus der Umgebungsvariablen gelesen wird ;)
}