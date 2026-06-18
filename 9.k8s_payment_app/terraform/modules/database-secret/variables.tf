variable "project_name" {}
variable "db_username" {}
variable "db_password" {
  sensitive = true
}
variable "db_endpoint" {}
variable "db_port" {}
variable "db_name" {}
