resource "aws_secretsmanager_secret" "postgres" {
  name                    = "${var.project_name}-postgres"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id = aws_secretsmanager_secret.postgres.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password

    endpoint = var.db_endpoint
    port     = var.db_port
    database = var.db_name
  })
}
