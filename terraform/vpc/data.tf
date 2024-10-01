# data "aws_availability_zones" "main" {
#   state = "available"
# }

locals {
  aws_availability_zones = ["us-west-2a","us-west-2b","us-west-2c","us-west-2d","us-west-2e"]
}