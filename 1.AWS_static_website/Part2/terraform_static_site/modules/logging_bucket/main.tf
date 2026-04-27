data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket" "this" {
  bucket = "cloud-academy-tf-static-website-logs"
  tags   = var.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id = "rule-1"

    filter {}

    expiration {
      days = 30
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "this" {
  depends_on = [
    aws_s3_bucket_ownership_controls.this
  ]

  bucket = aws_s3_bucket.this.id

  access_control_policy {

    grant {
      permission = "FULL_CONTROL"

      grantee {
        type = "CanonicalUser"
        id   = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
      }
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
