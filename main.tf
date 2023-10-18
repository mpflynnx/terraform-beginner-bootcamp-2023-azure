terraform {
  cloud {
    organization = "mpflynnx"

    workspaces {
      name = "terra-home-1"
    }
  }
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
  name     = "terraform-beginner-bootcamp-2023-azure"
  location = "UK South"
}
# Create a storage account
resource "azurerm_storage_account" "storage_account" {
  name = "terraformaccount202310"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
  account_tier = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"

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