output "repository_url" {
  description = "The URL of the created ECR repository."
  value       = module.ecr_repository.repository_url
}
