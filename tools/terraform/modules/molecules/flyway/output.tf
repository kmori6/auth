output "flyway_task_definition_arn" {
  description = "ARN of the Flyway task definition"
  value       = aws_ecs_task_definition.flyway.arn
}

output "flyway_task_family" {
  description = "Family name of the Flyway task definition"
  value       = aws_ecs_task_definition.flyway.family
}
