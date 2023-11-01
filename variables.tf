variable "user_uuid" {
  description = "The UUID for the user" 
  type = string
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
  description = "The file path for public folder"
  type        = string
}

variable "cdn_sku" {
  type        = string
  description = "CDN SKU names."
}