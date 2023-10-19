output "primary_web_endpoint" {
  description = "Storage accounts static website primary endpoint"
  value = data.azurerm_storage_account.storage_data_source.primary_web_endpoint
}
