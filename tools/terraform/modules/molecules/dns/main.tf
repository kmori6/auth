terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }
}

# Route 53 Hosted Zone (existing)
data "aws_route53_zone" "main" {
  name         = var.hosted_zone_name != "" ? var.hosted_zone_name : var.domain_name
  private_zone = false
}

# A Record (Alias) pointing to ALB
resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
