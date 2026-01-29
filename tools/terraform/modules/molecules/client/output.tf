output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = module.cloudfront_distribution.id
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.cloudfront_distribution.domain_name
}

output "website_url" {
  description = "The URL of the client website"
  value       = "https://${var.domain_name}"
}
