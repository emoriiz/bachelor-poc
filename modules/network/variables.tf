variable "resource_group_name" {}
variable "datacenter_location" {}
variable "location_code" {}
variable "address_space" {}

variable "subnets" {
  type = map(list(string))
}

# variable "server_subnet_address_prefixes" {}
# variable "services_subnet_address_prefixes" {}
variable "tags" {}