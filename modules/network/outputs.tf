output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "vnet_name" {
  value = azurerm_virtual_network.main.name
}

output "gateway_subnet_id" {
  value = azurerm_subnet.subnets["gateway"].id
}

output "services_subnet_id" {
  value = azurerm_subnet.subnets["services"].id
}
