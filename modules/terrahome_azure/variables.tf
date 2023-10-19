variable "user_uuid" {
  description = "The UUID for the user" 
  type = string

  validation {
    condition     = can(regex("^\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}$", var.user_uuid))
    error_message = "Invalid UUID format. Please provide a valid UUID."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type = string
}

variable "resource_group_location" {
  description = "The location of the resource group."
  type = string
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type = string
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account"
  type = string
}

variable "account_kind" {
  description = "Defines the Kind of account"
  type = string
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account"
  type = string
}

variable "public_path" {
  description = "The file path for index.html"
  type        = string

  validation {
    condition     = fileexists("${var.public_path}/index.html")
    # condition     = fileexists("/workspace/terraform-beginner-bootcamp-2023-azure/public/index.html")
    error_message = "File index.html does not exist."
  }
}