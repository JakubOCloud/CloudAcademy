resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.this.id
  key          = "index.html"
  source       = "../../website/index.html"
  content_type = "text/html"
}

output "bucket_domain_name" {
  value = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}
