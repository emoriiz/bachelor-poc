variable "location_code" {}
variable "datacenter_location" {}
variable "resource_group_name" {}
variable "subnet_id" {}
variable "tags" {}
variable "vm_name" {}
variable "vm_size" {}
variable "vm_sku" {
  default = "2025-datacenter-azure-edition"
}
variable "admin_password" {
  sensitive = true
}