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


variable "tags" {
  default = {
    project = "static-website"
  }
}
