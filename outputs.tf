output "storage_primary_web_endpoint" {
  description = "Storage accounts static website primary endpoint"
  value = module.terrahome_azure.primary_web_endpoint
}
