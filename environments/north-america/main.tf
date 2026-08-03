
module "resource_groups" {
  source              = "../../modules/resource-groups"
  location_code       = var.location_code
  datacenter_location = var.datacenter_location
  tags                = local.common_tags

  resource_groups = {
    network = true
    storage = true
  }
}

module "network" {
  source              = "../../modules/network"
  location_code       = var.location_code
  datacenter_location = var.datacenter_location
  resource_group_name = module.resource_groups.resource_group_names["network"]
  address_space       = ["10.204.8.0/21"]
  subnets = {
    gateway  = ["10.204.8.0/24"]
    services = ["10.204.9.0/24"]
  }
  tags = local.common_tags
}

module "vpn-gateway" {
  source              = "../../modules/vpn-gateway"
  location_code       = var.location_code
  datacenter_location = var.datacenter_location
  resource_group_name = module.resource_groups.resource_group_names["network"]
  gateway_subnet_id   = module.network.gateway_subnet_id
  vpn_client_address_pool = ["172.16.201.0/24"]
  vpn_root_cert_data      = file("./certs/rootCA.pem")
  tags = local.common_tags
}


module "storage" {
  source              = "../../modules/storage"
  location_code       = var.location_code
  datacenter_location = var.datacenter_location
  resource_group_name = module.resource_groups.resource_group_names["storage"]
  tags                = local.common_tags
}
