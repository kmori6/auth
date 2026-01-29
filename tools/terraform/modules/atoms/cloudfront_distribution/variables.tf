variable "name" {
  description = "The name tag for the CloudFront distribution"
  type        = string
}

variable "enabled" {
  description = "Whether the distribution is enabled"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution"
  type        = bool
  default     = true
}

variable "comment" {
  description = "Comment for the CloudFront distribution"
  type        = string
  default     = ""
}

variable "default_root_object" {
  description = "The object that you want CloudFront to request from your origin"
  type        = string
  default     = "index.html"
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names) for this distribution"
  type        = list(string)
  default     = []
}

variable "price_class" {
  description = "The price class for this distribution"
  type        = string
  default     = "PriceClass_All"
}

variable "origin_domain_name" {
  description = "The DNS domain name of the S3 bucket"
  type        = string
}

variable "origin_id" {
  description = "A unique identifier for the origin"
  type        = string
}

variable "origin_access_control_id" {
  description = "The ID of the Origin Access Control"
  type        = string
}

variable "allowed_methods" {
  description = "HTTP methods that CloudFront processes and forwards to your origin"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cached_methods" {
  description = "HTTP methods for which CloudFront caches responses"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "viewer_protocol_policy" {
  description = "Protocol policy for viewers"
  type        = string
  default     = "redirect-to-https"
}

variable "min_ttl" {
  description = "Minimum amount of time that you want objects to stay in CloudFront caches"
  type        = number
  default     = 0
}

variable "default_ttl" {
  description = "Default amount of time that you want objects to stay in CloudFront caches"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum amount of time that you want objects to stay in CloudFront caches"
  type        = number
  default     = 86400
}

variable "compress" {
  description = "Whether you want CloudFront to automatically compress content"
  type        = bool
  default     = true
}

variable "acm_certificate_arn" {
  description = "The ARN of the AWS Certificate Manager certificate"
  type        = string
}
