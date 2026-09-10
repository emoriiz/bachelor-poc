variable "location_code" {}
variable "datacenter_location" {}
variable "tags" {}
variable "resource_group_name" {}
variable "address_space" {}
variable "subnets" {
  type = map(list(string))
}
variable "dns_servers" {
  type    = list(string)
  default = [] # leer = Azure-DNS (168.63.129.16)
}
