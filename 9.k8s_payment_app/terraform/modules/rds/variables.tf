variable "project_name" {
  type = string
}

variable "private_db_subnet_ids" {
  type = list(string)
}

variable "private_app_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}
