# https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/virtual_network
# https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/subnet

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.location_code}-main"
  location            = var.datacenter_location
  resource_group_name = var.resource_group_name

  address_space = var.address_space #  ["10.203.8.0/21"]

  tags = var.tags
}
# /22 -> 255.255.252.0 -> 1024 Adressen -> 4 Subnetze
# /21 -> 255.255.256.0 -> 2048 Adressen -> 8 Subnetze


resource "azurerm_subnet" "subnets" {

  for_each = var.subnets

  name = "snet-${var.location_code}-${each.key}"

  resource_group_name  = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = each.value

}


#resource "azurerm_subnet" "server" {
#  name                 = "vnet-${var.location_code}-server"
#  resource_group_name  = azurerm_resource_group.network.name
#  virtual_network_name = azurerm_virtual_network.main.name
#
#  # address_prefixes = ["10.203.8.0/24"] # 255.255.255.0 -> 256 Adressen
#  address_prefixes = var.server_subnet_address_prefixes
#}
#
#resource "azurerm_subnet" "services" {
#  name                 = "vnet-${var.location_code}-services"
#  resource_group_name  = azurerm_resource_group.network.name
#  virtual_network_name = azurerm_virtual_network.main.name
#
#  # address_prefixes = ["10.203.9.0/24"] # 255.255.255.0 -> 256 Adressen
#  address_prefixes = var.services_subnet_address_prefixes
#}
