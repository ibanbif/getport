resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${var.env}"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name = "${var.project}-${var.env}"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_acm_certificate" "main" {
  domain_name       = "port.${var.domain}"
  validation_method = "DNS"

  tags = {
    Name = "${var.project}-${var.env}"
  }
}

resource "aws_route53_record" "main" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.main.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.main.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.main.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.main.zone_id
  ttl             = 60
}

resource "aws_security_group" "main" {
  name   = "${var.project}-${var.env}"
  vpc_id = data.aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}"
  }
}

resource "aws_lb" "main" {
  name                       = "${var.project}-${var.env}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.main.id]
  subnets                    = data.aws_subnets.main.ids
  enable_deletion_protection = false

  tags = {
    Name = "${var.project}-${var.env}"
  }
}

resource "aws_lb_target_group" "main" {
  name  = "${var.project}-${var.env}"
  target_type = "ip"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main.id

  health_check {
    enabled           = true
    healthy_threshold = 2
    interval          = 5
    matcher           = "200-299"
    path              = "/"
    port              = "8200"
    protocol          = "HTTP"
    unhealthy_threshold = 2
    timeout             = 3
  }

  tags = {
    Name = "${var.project}-${var.env}"
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.main.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "port.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = false
  }
}