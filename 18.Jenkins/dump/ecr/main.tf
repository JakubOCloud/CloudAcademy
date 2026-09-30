resource "aws_ecr_repository" "this" {
  name                 = "task-management-api-${var.environment}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "task-management-api-${var.environment}"
    Environment = var.environment
  }
}
