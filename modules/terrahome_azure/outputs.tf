output "primary_web_endpoint" {
  description = "Storage accounts static website primary endpoint"
  value = azurerm_storage_account.st.primary_web_endpoint
}

output "primary_web_hostname" {
  description = "Storage accounts static website primary hostname"
  value = azurerm_storage_account.st.primary_web_host
}

output "frontDoorEndpointHostName" {
  description = "value"
  value = azurerm_cdn_frontdoor_endpoint.my_endpoint.host_name
}