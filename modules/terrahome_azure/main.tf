terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.82.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.5.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_string" "main" {
  length  = 8
  upper   = false
  special = false
}

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location = var.primary_region
}
