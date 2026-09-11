variable "environment" {
  description = "Environment name"
  type        = string
}

variable "retention_in_days" {
  description = "CloudWatch log retention"
  type        = number
  default     = 14
}
