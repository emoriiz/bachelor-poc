# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
# https://developer.hashicorp.com/terraform/language/meta-arguments/for_each

locals {
  enabled_resource_groups = { for k, enabled in var.resource_groups : k => enabled if enabled }
}

# Legt für jeden auf true gesetzten Eintrag in var.resource_groups eine Resource Group an
resource "azurerm_resource_group" "group" {
  for_each = local.enabled_resource_groups

  name     = "rg-${var.location_code}-${each.key}"
  location = var.datacenter_location
  tags     = var.tags
}
