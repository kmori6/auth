terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "flyway" {
  name              = "/ecs/${var.prefix}-flyway"
  retention_in_days = 7

  tags = {
    Name = "${var.prefix}-flyway-logs"
  }
}

# IAM Role for Task Execution
resource "aws_iam_role" "flyway_task_execution" {
  name = "${var.prefix}-flyway-task-execution-role"

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
    Name = "${var.prefix}-flyway-task-execution-role"
  }
}

# Attach AWS managed policy for ECS Task Execution
resource "aws_iam_role_policy_attachment" "flyway_task_execution_policy" {
  role       = aws_iam_role.flyway_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "flyway" {
  family                   = "${var.prefix}-flyway-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.flyway_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "${var.prefix}-flyway-container"
      image = "${var.flyway_ecr_repository_url}:latest"

      environment = []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.flyway.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "flyway"
        }
      }
    }
  ])

  tags = {
    Name = "${var.prefix}-flyway-task-definition"
  }
}
