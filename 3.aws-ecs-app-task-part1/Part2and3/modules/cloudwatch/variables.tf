variable "tags" {
  default = {
    project = "static-website"
  }
}

variable "log_group_name" {
  description = "CloudWatch log group name"
  default     = "/ecs/hello-api"
}

