# https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/public_ip
# https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/virtual_network_gateway

resource "azurerm_public_ip" "vpn" {
  name                = "pip-${var.location_code}-vpn"
  location            = var.datacenter_location
  resource_group_name = var.resource_group_name
  # allocation_method   = "Static"
  allocation_method   = "Static"
  sku                 = "Standard"
  zones = ["1", "2", "3"]
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "vpn" {
  name                = "gw-${var.location_code}-vpn"
  location            = var.datacenter_location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1AZ"

  ip_configuration {
    name                          = "vpn-gateway-config"
    public_ip_address_id          = azurerm_public_ip.vpn.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  # Point-to-Site Konfiguration
  vpn_client_configuration {
    address_space        = var.vpn_client_address_pool
    vpn_client_protocols = ["OpenVPN"]

    root_certificate {
      name             = "PoCRootCA"
      public_cert_data = var.vpn_root_cert_data
    }
  }
}
