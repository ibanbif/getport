resource "aws_iam_role" "main" {
  name = "${var.project}-${var.env}-${var.service}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "${var.project}-${var.env}-${var.service}"
  }
}

resource "aws_iam_role_policy" "main" {
  name = "${var.project}-${var.env}-${var.service}"
  role = aws_iam_role.main.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*",
        "ec2:*",
        "iam:*",
        "ssmmessages:*",
        "logs:*",
        "kms:Decrypt",
        "ecs:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "${var.project}-${var.env}-${var.service}"
  retention_in_days = 7

  tags = {
    Name = "${var.project}-${var.env}-${var.service}"
  }
}

resource "aws_security_group" "main" {
  name   = "${var.project}-${var.env}-${var.service}"
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
    Name = "${var.project}-${var.env}-${var.service}"
  }
}

resource "aws_lb_target_group" "main" {
  name  = "${var.project}-${var.env}-${var.service}"
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
    port              = "80"
    protocol          = "HTTP"
    unhealthy_threshold = 2
    timeout             = 3
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = data.aws_lb_listener.main.arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = ["${var.path_pattern}*"]
    }
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project}-${var.env}-${var.service}"
  task_role_arn            = aws_iam_role.main.arn
  execution_role_arn       = aws_iam_role.main.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      essential  = true
      image      = "nginx:alpine"
      name       = "main"
      privileged = false

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.main.name
          awslogs-region        = data.aws_region.main.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project}-${var.env}-${var.service}"
  }
}

resource "aws_ecs_service" "main" {
  name                   = "${var.project}-${var.env}-${var.service}"
  cluster                = "${var.project}-${var.env}"
  task_definition        = aws_ecs_task_definition.main.arn
  platform_version       = "LATEST"
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  load_balancer {
    container_name   = "main"
    container_port   = "80"
    target_group_arn = aws_lb_target_group.main.arn
  }

  network_configuration {
    subnets         = data.aws_subnets.main.ids
    security_groups = [aws_security_group.main.id]
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.service}"
  }
}