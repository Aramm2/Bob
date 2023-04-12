variable "env" {
  type = string
}

variable "map_tag" {
  type = map(string)
  default = {
    map-migrated = "d-server-03chi6j8h6vs1j"
  }
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

variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "vpc_default_security_group_id" {
  type= string
}

variable "private_subnets" {
}

variable "opensearch_domain" {
  type = string
}