resource "random_password" "task_api_secret" {
  length  = 32
  special = true
}

resource "aws_secretsmanager_secret" "app" {
  name = "task-management-api-${var.environment}"

  tags = {
    Name        = "task-management-api-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id

  secret_string = jsonencode({
    TASK_API_SECRET = random_password.task_api_secret.result
  })
}
