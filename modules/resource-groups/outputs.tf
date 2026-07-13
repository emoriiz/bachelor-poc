output "network_rg_name" {
  value = azurerm_resource_group.network.name
}

output "infra_rg_name" {
  value = azurerm_resource_group.infra.name
}