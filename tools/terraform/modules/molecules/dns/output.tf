output "zone_id" {
  description = "The ID of the Route 53 hosted zone."
  value       = data.aws_route53_zone.main.zone_id
}

output "record_fqdn" {
  description = "The FQDN of the A record."
  value       = aws_route53_record.alb.fqdn
}
