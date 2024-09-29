variable "project" {
  type = string
}

variable "env" {
  type    = string
  default = "prd"
}

variable "service" {
  type = string
}

variable "cidr_block_vpc" {
  type = string
}

variable "cidr_block_pri" {
  type = list(string)
}

variable "cidr_block_pub" {
  type = list(string)
}

variable "enable_dns_support" {
  type = bool  
}

variable "enable_dns_hostnames" {
  type = bool  
}