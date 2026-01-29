variable "prefix" {
  description = "The prefix for resource naming."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks."
  type        = list(string)
}

variable "app_port" {
  description = "Application container port."
  type        = number
}

variable "alb_security_group_id" {
  description = "The ID of the ALB security group."
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the ALB target group."
  type        = string
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository."
  type        = string
}

variable "container_image_tag" {
  description = "The tag of the container image."
  type        = string
}

variable "ecs_task_cpu" {
  description = "The CPU units for the ECS task."
  type        = number
}

variable "ecs_task_memory" {
  description = "The memory (MB) for the ECS task."
  type        = number
}

variable "postgres_endpoint_url" {
  description = "PostgreSQL database endpoint URL."
  type        = string
}

variable "db_username" {
  description = "PostgreSQL database username."
  type        = string
}

variable "db_password" {
  description = "PostgreSQL database password."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "PostgreSQL database name for connection string."
  type        = string
}
