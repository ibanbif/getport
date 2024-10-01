data "aws_availability_zones" "main" {
  state = "available"
}

locals {
  aws_availability_zones = slice(data.aws_availability_zones.main.names, 0, length(var.cidr_block_pri))
}