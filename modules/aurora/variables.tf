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

variable "master_username" {
  type = string
}

variable "master_password" {
  type = string
}

variable "database_name" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "public_subnet_list" {
  type = list
}

variable "account_id" {
  type = string
}

variable "cl_parameter_group_family" {
  type = string
}

variable "lower_case_table_names_values" {
  type = string
}

variable "cluster_instance_class" {
  type = string
}
