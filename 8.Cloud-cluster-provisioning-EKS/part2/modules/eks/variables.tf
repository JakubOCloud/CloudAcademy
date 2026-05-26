variable "tags" {
  default = {
    project = "static-website"
  }
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "bastion_security_group_id" {
  type = string
}
