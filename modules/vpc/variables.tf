variable "env" {
  type = string
}
variable "cidr_block" {
  type        = string
  description = "CIDR range of VPC"
}

variable "eks_subnet_tags" {
  type = map(string)
  default = {
    "kubernetes.io/cluster/smartfind-eks-dev" = "shared"
    "kubernetes.io/role/internal-elb"   = 1
  }
}

variable "eks_alb_subnet_tags" {
  type = map(string)
  default = {
    "kubernetes.io/role/elb"         = 1
    "kubernetes.io/role/alb-ingress" = 1
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["a", "b", "c"]
}

variable "region" {
  type = string
}

variable "subnet_count" {
  type    = number
  default = 2
}

variable "project_name" {
  type = string
}