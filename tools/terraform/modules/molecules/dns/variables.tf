
variable "domain_name" {
  description = "The domain name for Route 53 record."
  type        = string
}

variable "hosted_zone_name" {
  description = "The hosted zone name for Route 53. If not provided, domain_name will be used."
  type        = string
  default     = ""
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB."
  type        = string
}

variable "alb_zone_id" {
  description = "The zone ID of the ALB."
  type        = string
}
