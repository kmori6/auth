variable "prefix" {
  description = "The prefix for resource naming."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB."
  type        = list(string)
}

variable "app_port" {
  description = "Application container port."
  type        = number
}

variable "certificate_arn" {
  description = "The ARN of the SSL certificate."
  type        = string
}
