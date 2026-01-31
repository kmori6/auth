variable "region" {
  description = "The AWS region where the S3 bucket will be created."
  type        = string
}

variable "prefix" {
  description = "The prefix for the deployment environment."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "vpc_public_subnets" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
}

variable "vpc_availability_zones" {
  description = "List of availability zones."
  type        = list(string)
}

variable "app_port" {
  description = "Application container port."
  type        = number
}

variable "domain_name" {
  description = "Domain name for SSL certificate."
  type        = string
}

variable "api_domain_name" {
  description = "API subdomain name for backend ALB."
  type        = string
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository."
  type        = string
}

variable "flyway_ecr_repository_url" {
  description = "The URL of the Flyway ECR repository."
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

variable "db_username" {
  description = "Master username for the database."
  type        = string
}

variable "db_password" {
  description = "Master password for the database."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name for application connection."
  type        = string
}

variable "db_instance_class" {
  description = "The instance class for the RDS instance."
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage size in GB."
  type        = number
}

variable "db_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "bastion_key_name" {
  description = "SSH key pair name for bastion host."
  type        = string
}

variable "bastion_ami_id" {
  description = "AMI ID for bastion instance."
  type        = string
}

variable "bastion_instance_type" {
  description = "EC2 instance type for bastion host."
  type        = string
}

variable "bastion_allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH to bastion."
  type        = list(string)
}
