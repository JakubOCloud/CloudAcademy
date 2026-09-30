variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.30.0.0/16"
}

variable "availability_zones" {
  type = list(string)

  default = [
    "eu-central-1a",
    "eu-central-1b"
  ]
}

variable "admin_cidr" {
  description = "Public IP allowed to access Jenkins"
  type        = string
}
