variable "project" {
  type = string
}

variable "env" {
  type    = string
  default = "dev"
}

variable "domain" {
  type    = string
  default = null
}

variable "containerInsights" {
  type    = bool
  default = false
}