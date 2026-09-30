resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/task-management-api-${var.environment}"
  retention_in_days = var.retention_in_days

  tags = {
    Name        = "task-management-api-${var.environment}"
    Environment = var.environment
  }
}
