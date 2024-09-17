# outputs
output "service_id" {
  value = aws_ecs_service.this.id
}

output "service_name" {
  value = aws_ecs_service.this.name
}

output "service_cluster" {
  value = aws_ecs_service.this.cluster
}

output "service_task_definition" {
  value = aws_ecs_service.this.task_definition
}
