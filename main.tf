terraform {
  # cloud {
  #   organization = "mpflynnx"

  #   workspaces {
  #     name = "terrahome"
  #   }
  # }
}

module "terrahome_azure" {
  source = "./modules/terrahome_azure"
  user_uuid = var.user_uuid
  application_name = var.application_name
  environment_name = var.environment_name
  primary_region = var.primary_region
  account_tier = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind = var.account_kind
  public_path = var.public_path
  cdn_sku = var.cdn_sku
  my_ip_address = var.my_ip_address
  content_version = var.content_version
}