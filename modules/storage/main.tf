# https://learn.microsoft.com/de-de/azure/storage/common/storage-account-overview

# Storage Account als Basis für Azure Files
resource "azurerm_storage_account" "files" {
  name                     = "sta${var.location_code}files01"
  resource_group_name      = var.resource_group_name_storage
  location                 = var.datacenter_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = false

  tags = var.tags
}

# File shares anlegen
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

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link
# https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns
# https://learn.microsoft.com/en-us/azure/storage/files/storage-files-networking-dns

# Private DNS Zone für Azure Files, damit der Storage-Name im VNet auf die private IP auflöst
resource "azurerm_private_dns_zone" "files" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name_dns
}

# Verknüpft die Zone mit dem VNet, sonst gilt sie dort nicht
resource "azurerm_private_dns_zone_virtual_network_link" "files_link" {
  name                  = "link-${var.location_code}"
  private_dns_zone_name = azurerm_private_dns_zone.files.name
  resource_group_name   = var.resource_group_name_dns
  virtual_network_id    = var.vnet_id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint

# Private Endpoint für Azure Files samt automatischem DNS-Eintrag in der Zone oben
resource "azurerm_private_endpoint" "files" {
  name                = "pe-${var.location_code}-storage"
  location            = var.datacenter_location
  resource_group_name = var.resource_group_name_storage
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.location_code}-storage"
    private_connection_resource_id = azurerm_storage_account.files.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "pzg-${var.location_code}-storage"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.files.id
    ]
  }
}
