terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }
}

# CloudFront Origin Access Control
module "cloudfront_oac" {
  source      = "../../atoms/cloudfront_oac"
  name        = "${var.prefix}-client-oac"
  description = "Origin Access Control for ${var.prefix} client bucket"
}

# S3 Bucket Policy for CloudFront OAC
resource "aws_s3_bucket_policy" "client" {
  bucket = var.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${var.s3_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = module.cloudfront_distribution.arn
          }
        }
      }
    ]
  })
}

# CloudFront Distribution
module "cloudfront_distribution" {
  source = "../../atoms/cloudfront_distribution"

  name                     = "${var.prefix}-client-distribution"
  comment                  = "CloudFront distribution for ${var.prefix} client"
  origin_domain_name       = var.s3_bucket_regional_domain_name
  origin_id                = "S3-${var.s3_bucket_id}"
  origin_access_control_id = module.cloudfront_oac.id
  aliases                  = [var.domain_name]
  acm_certificate_arn      = var.certificate_arn
  price_class              = "PriceClass_200"
}

# Route 53 Record (Alias) pointing to CloudFront
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "client" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.cloudfront_distribution.domain_name
    zone_id                = module.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
