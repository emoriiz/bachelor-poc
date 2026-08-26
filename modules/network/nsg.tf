# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group.html
# https://learn.microsoft.com/de-de/azure/virtual-network/network-security-groups-overview

# Azure hat bereits Standardregeln definiert wie: VNET intern erlaubt, Azure Load Balancer erlaubt, Internet inbound blockiert

# Network Security Groups erstellen
resource "azurerm_network_security_group" "subnets" {
  for_each = {
    for k, v in var.subnets : k => v
    if k != "gateway"
  }

  name                = "nsg-${var.location_code}-${each.key}"
  location            = var.datacenter_location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}


# Network Security Groups den Subnetzen zuweisen (GatewaySubnet ignoriert)
resource "azurerm_subnet_network_security_group_association" "subnets" {
  # for_each                  = var.subnets
  for_each = {
    for k, v in var.subnets :
    k => v if k != "gateway"
  }
  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.subnets[each.key].id
}
