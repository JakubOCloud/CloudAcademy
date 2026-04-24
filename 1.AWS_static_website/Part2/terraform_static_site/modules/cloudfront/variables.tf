variable "bucket_domain_name" {
  description = "S3 bucket domain name"
}

variable "tags" {
  default = {
    project = "static-website"
  }
}

variable "bucket_arn" {}

variable "web_acl_arn" {
  description = "arn from rule which limits 100request per minute per ip "
}
