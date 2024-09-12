variable "tags" {
    type = map(string)
    description = "Tags which will be assigned to the resources."

    default = {
        "Environment"               = "Dev" 
        "Workload"                  = "ProcessAutomation: User Onboarding" 
        "Workload_Department"       = "Business Services" 
        "Data_Classification"       = "TLP:Amber" 
        "DownTime_Window"           = "Friday-3AM" 
        "AZ_CostAllocation"         = "PRJ24-156" 
    }
}