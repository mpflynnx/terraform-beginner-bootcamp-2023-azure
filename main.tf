terraform {
  required_providers {
    terratowns = {
      source = "local.providers/local/terratowns"
      version = "1.0.0"
    }
  }
}

# mocking to test server using fake values
# from bin/terratowns/create
provider "terratowns" {
  endpoint = "http://localhost:4567"
  user_uuid="e328f4ab-b99f-421c-84c9-4ccea042c7d1" 
  token="9b49b3fb-b8e9-483c-b703-97ba88eef8e0"
}

# module "terrahome_azure" {
#   source = "./modules/terrahome_azure"
#   user_uuid = var.user_uuid
#   application_name = var.application_name
#   environment_name = var.environment_name
#   primary_region = var.primary_region
#   account_tier = var.account_tier
#   account_replication_type = var.account_replication_type
#   account_kind = var.account_kind
#   public_path = var.public_path
#   cdn_sku = var.cdn_sku
#   my_ip_address = var.my_ip_address
#   content_version = var.content_version
# }