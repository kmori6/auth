variable "region" {
  description = "The AWS region where the S3 bucket will be created."
  type        = string
}

variable "prefix" {
  description = "The prefix for the ECR repository name."
  type        = string
}
