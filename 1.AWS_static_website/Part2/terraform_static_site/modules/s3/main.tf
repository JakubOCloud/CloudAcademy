resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.this.id
  key          = "index.html"
  source       = "${path.module}/../../website/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error-4xx" {
  bucket       = aws_s3_bucket.this.id
  key          = "error-4xx.html"
  source       = "${path.module}/../../website/error-4xx.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error-5xx" {
  bucket       = aws_s3_bucket.this.id
  key          = "error-5xx.html"
  source       = "${path.module}/../../website/error-5xx.html"
  content_type = "text/html"
}
