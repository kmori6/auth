# Network Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

# Load Balancer Outputs
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.load_balancer.alb_dns_name
}

output "alb_zone_id" {
  description = "The zone ID of the Application Load Balancer"
  value       = module.load_balancer.alb_zone_id
}

# DNS Outputs
output "domain_fqdn" {
  description = "The fully qualified domain name"
  value       = module.route53.record_fqdn
}

output "application_url" {
  description = "The URL to access the application"
  value       = "https://${var.domain_name}:3000"
}

# RDS Outputs
output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = module.postgres.db_instance_endpoint
}

output "rds_address" {
  description = "The hostname of the RDS instance"
  value       = module.postgres.db_instance_address
}

# Bastion Outputs
output "bastion_public_ip" {
  description = "The public IP address of the bastion host"
  value       = module.bastion.bastion_public_ip
}

output "bastion_ssh_command" {
  description = "SSH command to connect to bastion"
  value       = module.bastion.ssh_command
}

output "bastion_ssm_command" {
  description = "AWS SSM command to connect to bastion"
  value       = module.bastion.ssm_command
}

# PostgreSQL Connection Info
output "postgres_connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = "postgresql://${var.db_username}:****@${module.postgres.db_instance_address}:5432/${var.db_name}"
  sensitive   = false
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = "${var.prefix}-cluster"
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = "${var.prefix}-service"
}

# Client (CloudFront) Outputs
output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = module.client.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.client.cloudfront_domain_name
}

output "client_website_url" {
  description = "The URL of the client website"
  value       = module.client.website_url
}
