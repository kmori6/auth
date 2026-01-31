variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "flyway_ecr_repository_url" {
  description = "ECR repository URL for Flyway image"
  type        = string
}
