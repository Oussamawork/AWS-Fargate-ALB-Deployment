# aws ecs service
resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.this.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}

# target group
resource "aws_lb_target_group" "this" {
  name        = "${var.name}-target-group"
  port        = var.container_port
  protocol    = var.protocol
  vpc_id      = var.vpc_id
  target_type = "ip"
}

# task definition
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-task-definition"
  container_definitions    = jsonencode(var.container_definitions)
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = var.network_mode
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

# listener rule
resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = var.path_pattern
    }
  }
}

# security group
resource "aws_security_group" "this" {
  name        = "${var.name}-ecs-service"
  description = "Security group for ECS service"
  vpc_id      = var.vpc_id
}

# security group rule
resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id            = aws_security_group.this.id
  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "TCP"
  referenced_security_group_id = var.referenced_security_group_id
}

# security group rule egress
resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# execution role
resource "aws_iam_role" "execution" {
  name = "${var.name}-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# task role
resource "aws_iam_role" "task" {
  name = "${var.name}-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# execution role policy
resource "aws_iam_role_policy" "execution" {
  role = aws_iam_role.execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# task role policy
resource "aws_iam_role_policy" "task" {
  role = aws_iam_role.task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# execution role policy attachment
resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# task role policy attachment
resource "aws_iam_role_policy_attachment" "task" {
  role       = aws_iam_role.task.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}