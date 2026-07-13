
module "resource_groups" {
  source = "../../modules/resource-groups"
  location_code = var.location_code
  datacenter_location = var.datacenter_location
  tags = local.common_tags
}

module "network" {
   source = "../../modules/network"
   location_code = var.location_code
   datacenter_location = var.datacenter_location
   resource_group_name = module.resource_groups.network_rg_name
   address_space = ["10.204.8.0/21"]
   subnets = {
    server   = ["10.204.8.0/24"]
    services = ["10.204.9.0/24"]
    }
   tags = local.common_tags
}

 
module "storage" {
  source = "../../modules/storage"
   location_code = var.location_code
   datacenter_location = var.datacenter_location
   resource_group_name = module.resource_groups.infra_rg_name
   tags = local.common_tags
}