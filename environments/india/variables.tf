variable "subscription_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "datacenter_location" {
  type = string
}

variable "location_code" {
  type = string
}

variable "managed_by" {
  type = string
}

variable "owner" {
  type = string
}

variable "project" {
  type = string
}

variable "admin_password" {
  sensitive = true
}