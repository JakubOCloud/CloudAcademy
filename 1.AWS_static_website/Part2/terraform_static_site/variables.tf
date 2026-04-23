variable "bucket_name" {
  description = "S3 bucket name"
}

variable "tags" {
  default = {
    project = "static-website"
  }
}
