variable "cluster_name" {
  description = "ECS cluster name"
  default     = "hello-world-cluster"
}

variable "task_family" {
  description = "Task definition family name"
  default     = "hello-world-task"
}

variable "ecs_task_cpu" {
  description = "CPU units for ECS task"
  default     = 256
}

variable "ecs_task_memory" {
  description = "Memory for ECS task"
  default     = 512
}

variable "app_image" {
  description = "Docker Image URL"
}

variable "app_port" {
  description = "Port where app listen"
  default     = 8080
}

variable "log_group_name" {
  description = "CloudWatch log group name"
}

variable "desired_task_count" {
  description = "Desired number of tasks"
  default     = 1
}

variable "max_task_count" {
  description = "Max number of tasks"
  default     = 2
}

variable "target_group_arn" {
  description = "ALB tg ARN"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "private_subnets_ids" {
  description = "Private subnets ids"
}

variable "alb_security_group_id" {
  description = "ALB sg ID"
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks"
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks"
  default     = 3
}

variable "cpu_high_threshold" {
  description = "CPU utilization percentage to scale up"
  default     = 50
}

variable "cpu_low_threshold" {
  description = "CPU utilization percentage to scale down"
  default     = 25
}

variable "scale_in_cooldown" {
  description = "Cooldown period for scalein"
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Cooldown period for scale out"
  default     = 60
}

variable "tags" {
  default = {
    project = "static-website"
  }
}

