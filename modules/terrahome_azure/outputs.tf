# output "primary_web_endpoint" {
#   description = "Storage accounts static website primary endpoint"
#   value = data.azurerm_storage_account.storage_data_source.primary_web_endpoint
# }

output "primary_web_endpoint" {
  description = "Storage accounts static website primary endpoint"
  value = azurerm_storage_account.storage_account.primary_web_endpoint
}

# output "primary_web_hostname" {
#   description = "Storage accounts static website primary hostname"
#   value = data.azurerm_storage_account.storage_data_source.primary_web_host
# }

output "primary_web_hostname" {
  description = "Storage accounts static website primary hostname"
  value = azurerm_storage_account.storage_account.primary_web_host
}

# output "cdn_endpoint_hostname" {
#   value = data.azurerm_cdn_frontdoor_endpoint.cdn_data_source.host_name
# }

output "cdn_profile_name" {
  value = azurerm_cdn_profile.profile.name
}

output "cdn_endpoint_endpoint_name" {
  value = azurerm_cdn_endpoint.endpoint.name
}

output "cdn_endpoint_fqdn" {
  value = azurerm_cdn_endpoint.endpoint.fqdn
}