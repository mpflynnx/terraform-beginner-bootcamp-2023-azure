variable "application_name" {
  description = "Name of a project, application, or service that the resource is a part of"
  type = string
}
variable "environment_name" {
  description = "The stage of the development lifecycle for the workload that the resource supports"
  type = string
}

variable "primary_region" {
  description = "The region or cloud provider where the resource is deployed"
  type = string
}

variable "user_uuid" {
  description = "The UUID for the user" 
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

variable "my_ip_address" {
  type        = string
  description = "my external ip address"  
}

variable "content_version" {
  description = "Content version number"
  type        = number
}