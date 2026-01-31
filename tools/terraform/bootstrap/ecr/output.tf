output "repository_url" {
  description = "The URL of the created ECR repository."
  value       = module.ecr_repository.repository_url
}

output "flyway_repository_url" {
  description = "The URL of the created Flyway ECR repository."
  value       = module.ecr_flyway_repository.repository_url
}
