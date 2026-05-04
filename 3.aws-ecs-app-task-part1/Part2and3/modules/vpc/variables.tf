variable "vpc_cidr" {
  description = "CIDR for VPC"
}

variable "availability_zones" {
  description = "List of AZ's"
}

variable "public_subnet_cidrs" {
  description = "CIDR for public subnets"
}

variable "private_subnet_cidrs" {
  description = "CIDR for private subnets"
}

variable "tags" {
  default = {
    project = "static-website"
  }
}
