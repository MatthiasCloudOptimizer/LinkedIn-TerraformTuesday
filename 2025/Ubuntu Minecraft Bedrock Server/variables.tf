variable "prefix" {
    description = "Prefix for all resource names"
    type        = string
    default     = "MinecraftBedrockServer"
}

variable "location" {
    description = "Azure region for resources"
    type        = string
    default     = "germanywestcentral"
}

variable "vm_name" {
    description = "Name of the virtual machine"
    type        = string
    default     = "minecraftBedrock-server"
}

variable "ssh_public_key_path" {
    description = "Path to SSH public key file"
    type        = string
}

variable "azure_subscription_id" {
    description = "Azure subscription ID for resource deployment"
    type        = string
}