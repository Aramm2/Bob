variable "env" {
  type = string
}

variable "project_name" {
  type = string
}

variable "docdb_security_group" {}

variable "subnet_group_ids" {}

variable "docdb_configure" {
  default = {
    username = "master"
    password = "adminadmin"
  }
  type = map(string)
}

