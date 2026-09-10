# https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/virtual_network
# https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/subnet

# Virtuelles Netzwerk der Umgebung, optional mit eigenem DNS-Server (dns_servers)
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.location_code}-main"
  location            = var.datacenter_location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

# Subnetze aus der subnets-Variable; das Gateway-Subnetz braucht den von Azure vorgeschriebenen Namen
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key == "gateway" ? "GatewaySubnet" : "snet-${var.location_code}-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value
}
