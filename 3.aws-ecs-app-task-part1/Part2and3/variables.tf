variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "app_image_url" {
  description = "URL to my image"
  type        = string
}

variable "app_port" {
  description = "Port where app is listening"
  type        = number
  default     = 8080
}

variable "ecs_task_cpu" {
  description = "CPU units for ECS task"
  type        = number
  default     = 256
}

variable "ecs_task_memory" {
  description = "Memory for ECS task"
  type        = number
  default     = 512
}

variable "desired_task_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "max_task_count" {
  description = "Maximum number of ECS tasks during deployment"
  type        = number
  default     = 2
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling for ECS service"
  type        = number
  default     = true
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 3
}

variable "cpu_high_threshold" {
  description = "CPU utilization percentage to scale up"
  type        = number
  default     = 50
}

variable "cpu_low_threshold" {
  description = "CPU utilization percentage to scale down"
  type        = number
  default     = 25
}

variable "scale_in_cooldown" {
  description = "Cooldown period for scalein"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Cooldown period for scale out"
  type        = number
  default     = 60
}

variable "tags" {
  type = map(string)
  default = {
    project = "static-website"
  }
}
