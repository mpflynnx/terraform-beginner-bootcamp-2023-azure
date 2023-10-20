output "storage_primary_web_endpoint" {
  description = "Storage accounts static website primary endpoint"
  value = module.terrahome_azure.primary_web_endpoint
}

# output "cdn_cdn_endpoint_hostname" {
#   description = ""
#   value = module.terrahome_azure.cdn_endpoint_hostname
# }

output "cdn_cdn_profile_name" {
  value = module.terrahome_azure.cdn_profile_name
  # value = azurerm_cdn_profile.profile.name
}

output "cdn_cdn_endpoint_endpoint_name" {
  value = module.terrahome_azure.cdn_endpoint_endpoint_name
}

output "cdn_cdn_endpoint_fqdn" {
  value = module.terrahome_azure.cdn_endpoint_fqdn
}