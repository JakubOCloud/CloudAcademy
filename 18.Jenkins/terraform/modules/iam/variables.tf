variable "environment" {
  description = "Environment name"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository used by ECS"
  type        = string
}

variable "secret_arn" {
  description = "ARN of the application secret"
  type        = string
}
