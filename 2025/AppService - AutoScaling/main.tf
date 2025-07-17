# ─── 0) Gemeinsame FinOps-Tags ─────────────────────────────────────────────
locals {
    finops_tags = {
        CostCenter  = "CC-4711"
        Project     = "WebShopX"
        Environment = "prod"
        Owner       = "matthias.braun@contoso.com"
        Service     = "AzureAppService"
        ManagedBy   = "Terraform"
    }
}

# ─── 1) Resource Group (RG) ────────────────────────────────────────────────
resource "azurerm_resource_group" "rg" {
    name     = "rg-autoscaling-test-weu"
    location = "West Europe"
    tags     = local.finops_tags
}

# ─── 2) App Service Plan (ASP) ─────────────────────────────────────────────
resource "azurerm_app_service_plan" "asp" {
    name                = "asp-webshopx-weu-s1"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    sku {
        tier = "Standard"
        size = "S1"
    }

    tags = merge(local.finops_tags, { Component = "AppServicePlan" })
}

# ─── 3) Web App (APP) ──────────────────────────────────────────────────────
resource "random_id" "rand" {
    byte_length = 4
}

resource "azurerm_linux_web_app" "app" {
    name                = "app-webshopx-${random_id.rand.hex}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    service_plan_id = azurerm_app_service_plan.asp.id

    site_config {
        linux_fx_version      = "DOCKER|mcr.microsoft.com/dotnet/aspnet:8.0"
        http2_enabled         = true
        minimum_tls_version   = "1.2"
    }

    identity { type = "SystemAssigned" }

    tags = merge(local.finops_tags, { Component = "WebApp" })
}

# ─── 4) Autoscale-Setting (AUTOSCALE) ──────────────────────────────────────
resource "azurerm_monitor_autoscale_setting" "autoscale" {
    name                = "autoscale-asp-weekend"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    target_resource_id  = azurerm_app_service_plan.asp.id

    # --- Weekday: normaler Betrieb -----------------------------------------
    profile {
        name = "WeekdayDefault"

        capacity { 
            default = 3
            minimum = 2
            maximum = 10
        }

        rule {
            metric_trigger {
            metric_name        = "CpuPercentage"
            metric_resource_id = azurerm_app_service_plan.asp.id
            time_grain         = "PT1M"
            statistic          = "Average"
            time_window        = "PT5M"
            time_aggregation   = "Average"
            operator           = "GreaterThan"
            threshold          = 75
        }
        scale_action {
            direction = "Increase"
            type      = "ChangeCount"
            value     = "1"
            cooldown  = "PT2M"
        }
    }

    rule {
        metric_trigger {
            metric_name        = "CpuPercentage"
            metric_resource_id = azurerm_app_service_plan.asp.id
            time_grain         = "PT1M"
            statistic          = "Average"
            time_window        = "PT5M"
            time_aggregation   = "Average"
            operator           = "LessThan"
            threshold          = 25
        }
        scale_action {
            direction = "Decrease"
            type      = "ChangeCount"
            value     = "1"
            cooldown  = "PT2M"
        }
    }
}

    # --- Weekend: Sparflamme -----------------------------------------------
    profile {
        name = "WeekendReduced"

        capacity { 
            default = 1
            minimum = 1
            maximum = 3
        }

        recurrence {
            timezone = "W. Europe Standard Time"
            days     = ["Saturday", "Sunday"]
            hours    = [0]
            minutes  = [0]
        }
    }

    notification {
        email {
            send_to_subscription_administrator    = true
            send_to_subscription_co_administrator = true
            custom_emails                         = ["cloudops@contoso.com"]
        }
    }

    tags = merge(local.finops_tags, { Component = "AutoscaleSetting" })
}