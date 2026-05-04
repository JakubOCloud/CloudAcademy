variable "vpc_id" {
  description = "VPC ID"
}

variable "public_subnet_id" {
  description = "Public subneys ids"
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
