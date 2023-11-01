output "storage_primary_web_endpoint" {
  description = "Storage accounts static website primary endpoint"
  value = module.terrahome_azure.primary_web_endpoint
}

output "storage_primary_web_hostname" {
  description = "Storage accounts static website primary hostname"
  value = module.terrahome_azure.primary_web_hostname
}

output "cdn_frontDoorEndpointHostName" {
  description = "value"
  value = module.terrahome_azure.frontDoorEndpointHostName
}