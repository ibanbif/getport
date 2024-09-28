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

variable "domain" {
  type    = string
  default = null
}

variable "path_pattern" {
  type    = string
  default = "/"
}

variable "priority" {
  type    = number
  default = 1
}