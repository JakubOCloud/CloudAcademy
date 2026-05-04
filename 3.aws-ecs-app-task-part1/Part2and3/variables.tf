variable "aws_region" {
  description = "AWS region to deploy resources"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
}

variable "availability_zones" {
  description = "List of availability zones"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
}

variable "app_image_url" {
  description = "URL to my image"
}

variable "app_port" {
  description = "Port where app is listening"
  default     = 8080
}

variable "ecs_task_cpu" {
  description = "CPU units for ECS task"
  default     = 256
}

variable "ecs_task_memory" {
  description = "Memory for ECS task"
  default     = 512
}

variable "desired_task_count" {
  description = "Desired number of ECS tasks"
  default     = 1
}

variable "max_task_count" {
  description = "Maximum number of ECS tasks during deployment"
  default     = 2
}

variable "tags" {
  default = {
    project = "static-website"
  }
}
