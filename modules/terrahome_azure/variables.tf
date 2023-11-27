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

  validation {
    condition     = can(regex("^\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}$", var.user_uuid))
    error_message = "Invalid UUID format. Please provide a valid UUID."
  }
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

  validation {
    condition     = fileexists("${var.public_path}/index.html")
    error_message = "File index.html does not exist."
  }
}

variable "cdn_sku" {
  type        = string
  description = "CDN SKU names."
  default     = "Standard_Microsoft"
  validation {
    condition     = contains(["Standard_Akamai", "Standard_Microsoft", "Standard_Verizon", "Premium_Verizon"], var.cdn_sku)
    error_message = "The cdn_sku must be one of the following: Standard_Akamai, Standard_Microsoft, Standard_Verizon, Premium_Verizon."
  }
}

variable "my_ip_address" {
  type        = string
  description = "my external ip address"  
}

variable "content_version" {
  type        = number
  description = "Content version number"
  default     = 1
  validation {
    condition     = var.content_version > 0 && can(var.content_version)
    error_message = "Content version must be a positive integer"
  }
}