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

variable "tags" {
  default = {
    project = "static-website"
  }
}
