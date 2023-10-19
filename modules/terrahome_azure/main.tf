terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.76.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.resource_group_location
}
# Create a storage account
resource "azurerm_storage_account" "storage_account" {
  name = var.storage_account_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
  account_tier = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind = var.account_kind

  static_website {
    index_document = "index.html"
    error_404_document = "error.html"
  }

  tags = {
    UserUuid = var.user_uuid
  }
}

# Add a index.html file
resource "azurerm_storage_blob" "blob" {
  name = "index.html"
  storage_account_name = azurerm_storage_account.storage_account.name
  storage_container_name = "$web"
  type = "Block"
  content_type = "text/html"
  source_content = "<h1>Hello, this is a website deployed using Azure storage account and Terraform.</h1>"
}

# Add a error.html file
resource "azurerm_storage_blob" "blob2" {
  name = "error.html"
  storage_account_name = azurerm_storage_account.storage_account.name
  storage_container_name = "$web"
  type = "Block"
  content_type = "text/html"
  source_content = "<h1>Hello, this is a Error page deployed using Azure storage account and Terraform.</h1>"
}