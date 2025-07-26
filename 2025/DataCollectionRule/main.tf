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

resource "azurerm_monitor_data_collection_rule" "example" {
    name                = "example-dcr"
    location            = "East US"
    resource_group_name = "example-resource-group"


    data_flow {
        streams     = ["Microsoft-PerformanceCounters"]
        destinations = ["example-log-analytics"]
    }

    destinations {
        log_analytics {
            name = "example-log-analytics"
            workspace_resource_id = "/subscriptions/your_subscription_id/resourceGroups/example-resource-group/providers/Microsoft.OperationalInsights/workspaces/example-workspace"
        }
    }

    data_sources {
        log_file {
            name          = "example-datasource-logfile"
            format        = "text"
            streams       = ["Custom-MyTableRawData"]
            file_patterns = ["C:\\JavaLogs\\*.log"]
            settings {
                text {
                    record_start_timestamp_format = "ISO 8601"
                }
            } 
        }   
    }

    description = "data collection rule example"
        tags = {
        foo = "bar"
        }
}