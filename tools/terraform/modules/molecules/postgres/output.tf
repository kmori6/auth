output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance."
  value       = aws_db_instance.postgres.endpoint
}

output "db_instance_address" {
  description = "The address of the RDS instance."
  value       = aws_db_instance.postgres.address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance."
  value       = aws_db_instance.postgres.arn
}

output "db_security_group_id" {
  description = "The ID of the RDS security group."
  value       = aws_security_group.rds.id
}
