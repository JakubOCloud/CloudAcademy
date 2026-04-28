variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "tags" {
  type = map(string)

  default = {
    project = "static-website"
  }
}
