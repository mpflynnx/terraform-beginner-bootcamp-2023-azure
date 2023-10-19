terraform {
  cloud {
    organization = "mpflynnx"

    workspaces {
      name = "terra-home-1"
    }
  }
}

module "terrahome_azure" {
  source = "./modules/terrahome_azure"
  user_uuid = var.user_uuid
  resource_group_name = var.resource_group_name
  resource_group_location = var.resource_group_location
  storage_account_name = var.storage_account_name
  account_tier = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind = var.account_kind
}