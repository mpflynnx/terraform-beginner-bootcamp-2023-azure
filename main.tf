terraform {
  required_providers {
    terratowns = {
      source = "local.providers/local/terratowns"
      version = "1.0.0"
    }
  }
}

provider "terratowns" {
  endpoint = var.terratowns_endpoint
  user_uuid = var.teacherseat_user_uuid
  token = var.terratowns_access_token
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

resource "terratowns_home" "home" {
  name = "!How to play Frontier: Elite II in 2023!"
  description = <<DESCRIPTION
!Frontier: Elite II is a space trading and combat simulator 
video game written by David Braben and published by GameTek 
and Konami in October 1993 and released on the Amiga, Atari 
ST and DOS. It is the first sequel to the seminal game Elite 
from 1984. The game retains the same principal component of Elite, 
namely open-ended gameplay, and adds realistic physics and an
accurately modelled galaxy. Go get it!!
DESCRIPTION
  #domain_name = module.terrahome_azure.frontDoorEndpointHostName
  domain_name = "dsdsf3453.azurefd.net"
  # domain_name = "dsdsf3453.cloudfront.net"
  town = "missingo"
  content_version = 1
}