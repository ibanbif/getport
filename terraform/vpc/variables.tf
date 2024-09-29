variable "project" {
  type = string
}

variable "env" {
  type    = string
  default = "prd"
}

variable "service" {
  type    = string
  default = "vpc"
}

variable "cidr_block_vpc" {
  type    = string
  # default = "10.0.0.0/16"
}

variable "cidr_block_pri" {
  type    = list(string)
  # default = ["10.0.0.0/18", "10.0.64.0/18"]
}

variable "cidr_block_pub" {
  type    = list(string)
  # default = ["10.0.128.0/18", "10.0.192.0/18"]
}

variable "domain" {
  type    = string
  default = null
}