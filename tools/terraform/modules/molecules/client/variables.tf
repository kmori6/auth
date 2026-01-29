variable "prefix" {
  description = "The prefix for resource names"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the client application"
  type        = string
}

variable "s3_bucket_id" {
  description = "The ID of the S3 bucket for static website hosting"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for static website hosting"
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket"
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the ACM certificate for HTTPS"
  type        = string
}
