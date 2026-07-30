locals {
  common_tags = {
    Environment = var.environment
    Location    = var.location_code
    ManagedBy   = var.managed_by
    Owner       = var.owner
    Project     = var.project
  }
}
