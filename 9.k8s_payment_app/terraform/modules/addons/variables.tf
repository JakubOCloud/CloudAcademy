variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_controller_role_arn" {
  type = string
}

variable "fluent_bit_role_arn" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_certificate_authority_data" {
  type = string
}
