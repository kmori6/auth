output "certificate_arn" {
  description = "The ARN of the validated SSL certificate."
  value       = aws_acm_certificate_validation.main.certificate_arn
}
