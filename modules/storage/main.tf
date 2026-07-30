# https://learn.microsoft.com/de-de/azure/storage/common/storage-account-overview

# Storage Account als Basis für Azure Files
resource "azurerm_storage_account" "files" {
  name                     = "sta${var.location_code}files01"
  resource_group_name      = var.resource_group_name
  location                 = var.datacenter_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = false

  tags = var.tags
}

resource "azurerm_storage_share" "department" {
  name               = "department"
  storage_account_id = azurerm_storage_account.files.id
  quota              = 100
}


resource "azurerm_storage_share" "home" {
  name               = "home"
  storage_account_id = azurerm_storage_account.files.id
  quota              = 100
}

resource "azurerm_storage_share" "common" {
  name               = "common"
  storage_account_id = azurerm_storage_account.files.id
  quota              = 100
}

resource "azurerm_storage_share" "applications" {
  name               = "applications"
  storage_account_id = azurerm_storage_account.files.id
  quota              = 100
}
