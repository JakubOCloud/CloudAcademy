variable "bucket_domain_name" {
  description = "S3 bucket domain name"
}

variable "tags" {
  default = {
    project = "static-website"
  }
}

variable "bucket_arn" {}
