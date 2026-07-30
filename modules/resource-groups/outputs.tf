output "resource_group_names" {
  value = { for k, rg in azurerm_resource_group.group : k => rg.name }
}
