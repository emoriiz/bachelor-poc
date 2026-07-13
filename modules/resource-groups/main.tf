# Netzwerk Reccourcengruppe
# enthält: VNET, NSG, Route Tables, Private DNS
resource "azurerm_resource_group" "network" {
  name     = "rg-${var.location_code}-network"
  location = var.datacenter_location

  tags = var.tags
}

# Infrastruktur Reccourcengruppe
# enthält: VMs, Azure Services, Azure Files, Domain Services
resource "azurerm_resource_group" "infra" {
  name     = "rg-${var.location_code}-infra"
  location = var.datacenter_location

  tags = var.tags
}