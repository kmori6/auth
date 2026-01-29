output "tfstate_bucket_id" {
  description = "The ID of the tfstate S3 bucket."
  value       = module.s3_tfstate.id
}

output "frontend_bucket_id" {
  description = "The ID of the frontend S3 bucket."
  value       = module.s3_frontend.id
}

output "frontend_bucket_arn" {
  description = "The ARN of the frontend S3 bucket."
  value       = module.s3_frontend.arn
}

output "frontend_bucket_domain_name" {
  description = "The regional domain name of the frontend S3 bucket."
  value       = module.s3_frontend.bucket_regional_domain_name
}
