variable "env" {
  type = string
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["a", "b", "c"]
}

variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "private_subnets" {
  type = list
}

variable "public_subnets" {
  type = list
}

variable "jumpbox_sg" {}

variable "opensearch_security_group" {}