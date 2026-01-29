variable "prefix" {
  description = "The prefix for resource naming."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the bastion instance."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "public_subnet_id" {
  description = "The ID of the public subnet for bastion."
  type        = string
}

variable "rds_security_group_id" {
  description = "The ID of the RDS security group."
  type        = string
}

variable "key_name" {
  description = "The name of the SSH key pair."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type for bastion."
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to bastion."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
