output "storage_account_id" {
  value = azurerm_storage_account.files.id
}

output "storage_account_name" {
  value = azurerm_storage_account.files.name
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.files.id
}