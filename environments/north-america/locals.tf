locals {
  common_tags = {
    Environment = var.environment
    Location    = var.location_code
    ManagedBy   = var.managed_by
    Owner       = var.owner
    Project     = var.project
  }

  # Feste IP von dc-01: Die VM ist zugleich DNS-Server im VNet (Forwarder auf
  # das Azure-DNS, damit Private DNS Zones auch für VPN-Clients auflösen).
  dc_private_ip = "10.204.9.4"
}
