
# Create a storage account
resource "azurerm_storage_account" "storage_account" {
  name = var.storage_account_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
  account_tier = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind = var.account_kind

  static_website {
    index_document = "index.html"
    error_404_document = "error.html"
  }

  tags = {
    UserUuid = var.user_uuid
  }
}

# Add a index.html file
resource "azurerm_storage_blob" "index_html" {
  name = "index.html"
  storage_account_name = azurerm_storage_account.storage_account.name
  storage_container_name = "$web"
  type = "Block"
  content_type = "text/html"
  source = "${var.public_path}/index.html"
  content_md5 = filemd5("${var.public_path}/index.html")
}

# Add a error.html file
resource "azurerm_storage_blob" "error_html" {
  name = "error.html"
  storage_account_name = azurerm_storage_account.storage_account.name
  storage_container_name = "$web"
  type = "Block"
  content_type = "text/html"
  source = "${var.public_path}/error.html"

  content_md5 = filemd5("${var.public_path}/error.html")
}

data "azurerm_storage_account" "storage_data_source" {
  name = azurerm_storage_account.storage_account.name
  resource_group_name = azurerm_resource_group.resource_group.name
}