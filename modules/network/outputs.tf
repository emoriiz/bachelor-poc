# ID und Name des VNet, z.B. für den VNet-Link der Private DNS Zone
output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "vnet_name" {
  value = azurerm_virtual_network.main.name
}

# Subnetz-IDs als Map (Key = Subnetz-Name aus var.subnets), z.B. subnet_ids["gateway"]
output "subnet_ids" {
  value = {
    for k, subnet in azurerm_subnet.subnets : k => subnet.id
  }
}
