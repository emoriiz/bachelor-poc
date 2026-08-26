module "resource_groups" {
  source              = "../../modules/resource-groups"
  location_code       = var.location_code
  datacenter_location = var.datacenter_location
  tags                = local.common_tags

  resource_groups = {
    network = true
    storage = true
    dns     = true
    infra   = true
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


# module "vpn-gateway" {
#   source              = "../../modules/vpn-gateway"
#   location_code       = var.location_code
#   datacenter_location = var.datacenter_location
#   resource_group_name = module.resource_groups.resource_group_names["network"]
#   gateway_subnet_id   = module.network.gateway_subnet_id
#   # vpn_client_address_pool = ["172.16.201.0/24"]     # optional, wenn P2S konfiguriert
#   # vpn_root_cert_data      = file("./certs/rootCA.pem") # optional für P2S
#   tags = local.common_tags
# }


module "storage" {
  source                      = "../../modules/storage"
  location_code               = var.location_code
  datacenter_location         = var.datacenter_location
  resource_group_name_storage = module.resource_groups.resource_group_names["storage"]
  resource_group_name_dns     = module.resource_groups.resource_group_names["dns"]
  vnet_id                     = module.network.vnet_id
  subnet_id                   = module.network.subnet_ids["services"]
  tags                        = local.common_tags
}


# module "virtual-machine" {
#   source = "../../modules/virtual-machine"
#   location_code       = var.location_code
#   datacenter_location = var.datacenter_location
#   resource_group_name = module.resource_groups.resource_group_names["infra"]
#   subnet_id = module.network.subnet_ids["services"]
#   vm_name = "dc-01"
#   vm_size = "Standard_DS1_v2"
#   vm_sku = "2025-datacenter-azure-edition"
#   tags = local.common_tags
#   admin_password = var.admin_password
# }