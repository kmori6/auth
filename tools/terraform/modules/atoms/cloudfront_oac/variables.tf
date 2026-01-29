variable "name" {
  description = "The name of the CloudFront Origin Access Control"
  type        = string
}

variable "description" {
  description = "The description of the CloudFront Origin Access Control"
  type        = string
  default     = "Origin Access Control for S3"
}
