variable "rds_security_group" {}

variable "subnet_group_ids" {}

variable "env" {
  type = string
}

variable "project_name" {
  type = string
}

variable "rds_configure" {
  default = {
    username = "master"
    password = "adminadmin"
  }
  type = map(string)
}

variable "public_subnet_list" {
  type = list
}