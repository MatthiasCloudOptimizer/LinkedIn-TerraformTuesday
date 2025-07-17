# ─── 0) Gemeinsame FinOps-Tags ────────────────────────────────────────────
locals {
    finops_tags = {
        CostCenter  = "CC-4711"
        Project     = "WebShopX"
        Environment = "prod"
        Owner       = "matthias.braun@contoso.com"
        Service     = "Governance"
        ManagedBy   = "Terraform"
    }
}

# ─── 1) Policy Definition (POL) – unverändert ─────────────────────────────
resource "azurerm_policy_definition" "pol" {
    name         = "pol-allow-location-weu"
    policy_type  = "Custom"
    mode         = "All"
    display_name = "Allowed Location: West Europe only"
    description  = "Erlaubt Deployments ausschließlich im Azure-Bereich 'West Europe'."

    policy_rule = jsonencode({
        if = {
        field = "location"
        notIn = ["westeurope"]
        }
        then = {
            effect = "Deny"
        }
    })

    metadata   = jsonencode({ category = "General", version = "1.0.0" })
    parameters = jsonencode({})

}

# ─── 2) Datenquelle: Management-Group Landingzones ────────────────────────
data "azurerm_management_group" "landingzones" {
    # 'name' ist der Management-Group-ID (nicht Display-Name) – prüf in Azure-Portal.
    name = "landingzones"
}

# ─── 3) Policy Assignment (POL_ASSIGN) auf Management-Group ───────────────
resource "azurerm_policy_assignment" "pol_assign" {
    name                 = "pa-allow-location-weu"
    display_name         = "Enforce West Europe"
    policy_definition_id = azurerm_policy_definition.pol.id

    # Scope auf Management-Group
    scope = data.azurerm_management_group.landingzones.id

    description = "Blockiert Deployments in anderen Azure-Regionen als West Europe."
    location    = "West Europe"   # Pflichtfeld

    tags = merge(local.finops_tags, { Component = "PolicyAssignment" })
}