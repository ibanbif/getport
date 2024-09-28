data "aws_caller_identity" "main" {}
data "aws_region" "main" {}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.project}-${var.env}"]
  }
}

data "aws_subnets" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  tags = {
    Tier = "private"
  }
}

data "aws_lb_listener" "main" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 443
}

data "aws_lb" "main" {
  tags = {
    Name = "${var.project}-${var.env}"
  }
}

resource "null_resource" "main" {
  provisioner "local-exec" {
    command = "Name=${var.project}-${var.env}-${var.service} ./run.sh"
  }
}