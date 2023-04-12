variable "env" {
  type        = string
  default     = "dev"
}

variable "region" {
  type        = string
  description = "The deployment region"
  default     = "eu-central-1"
}

variable "project_name" {
  type        = string
  default     = "smartfind"
}

variable "cidr_block" {
  type        = string
  description = "CIDR range of VPC"
  default     = "10.0.0.0/16"
}

variable "account_id" {
  type        = string
  default     = "030795981198"
}