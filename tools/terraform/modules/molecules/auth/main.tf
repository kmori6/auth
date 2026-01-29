terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }
}

# SSM Parameter for JWT Private Key
resource "aws_ssm_parameter" "jwt_private_key" {
  name  = "/${var.prefix}/jwt_private_key"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [value]
  }

  tags = {
    Name = "${var.prefix}-jwt-private-key"
  }
}

# SSM Parameter for Postgres Endpoint URL
resource "aws_ssm_parameter" "postgres_endpoint_url" {
  name  = "/${var.prefix}/postgres_endpoint_url"
  type  = "SecureString"
  value = "postgresql://${var.db_username}:${var.db_password}@${var.postgres_endpoint_url}:5432/${var.db_name}?sslmode=require"

  tags = {
    Name = "${var.prefix}-postgres-endpoint-url"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.prefix}"
  retention_in_days = 7

  tags = {
    Name = "${var.prefix}-ecs-logs"
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.prefix}-ecs-task-execution-role"
  }
}

# Attach AWS managed policy for ECS Task Execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Policy for SSM Parameter Access
resource "aws_iam_role_policy" "ecs_ssm_policy" {
  name = "${var.prefix}-ecs-ssm-policy"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ]
        Resource = [
          aws_ssm_parameter.jwt_private_key.arn,
          aws_ssm_parameter.postgres_endpoint_url.arn
        ]
      }
    ]
  })
}

# NOTE: ECS Task Role is not currently needed.
# If the application requires access to AWS services at runtime (e.g., S3, SES, DynamoDB),
# create an IAM role with appropriate permissions and assign it to the task definition.

# ECS Security Group
resource "aws_security_group" "ecs" {
  name        = "${var.prefix}-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  # Allow traffic from ALB
  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
    description     = "Allow traffic from ALB"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.prefix}-ecs-sg"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"

  tags = {
    Name = "${var.prefix}-cluster"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "${var.prefix}-container"
      image = "${var.ecr_repository_url}:${var.container_image_tag}"

      portMappings = [
        {
          containerPort = var.app_port
          protocol      = "tcp"
        }
      ]

      secrets = [
        {
          name      = "JWT_PRIVATE_KEY"
          valueFrom = aws_ssm_parameter.jwt_private_key.arn
        },
        {
          name      = "POSTGRES_ENDPOINT_URL"
          valueFrom = aws_ssm_parameter.postgres_endpoint_url.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.prefix}-task-definition"
  }
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.prefix}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.prefix}-container"
    container_port   = var.app_port
  }

  tags = {
    Name = "${var.prefix}-service"
  }
}
