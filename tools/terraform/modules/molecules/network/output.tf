output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = [for subnet in module.public_subnet : subnet.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = [for subnet in module.private_subnet : subnet.id]
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = module.internet_gateway.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway."
  value       = module.nat_gateway.id
}
