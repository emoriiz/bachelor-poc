# Namen der angelegten Resource Groups als Map (Key = network/storage/dns/infra/...)
output "resource_group_names" {
  value = { for k, rg in azurerm_resource_group.group : k => rg.name }
}
