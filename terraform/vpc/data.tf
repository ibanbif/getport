# data "aws_availability_zones" "main" {
#   state = "available"
# }

locals {
  aws_availability_zones = slice(["us-west-2a","us-west-2b","us-west-2c","us-west-2d","us-west-2e"], 0, length(var.cidr_block_pri))
}