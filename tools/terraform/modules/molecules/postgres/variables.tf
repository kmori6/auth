variable "prefix" {
  description = "The prefix for resource naming."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for DB subnet group."
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "The ID of the ECS security group."
  type        = string
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
  description = "Initial database name to create."
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

variable "availability_zone" {
  description = "Availability zone for the RDS instance."
  type        = string
}
