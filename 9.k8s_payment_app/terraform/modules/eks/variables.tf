variable "cluster_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "db_secret_arn" {
  type = string
}
