terraform {
  required_version = ">=1.5.0"

  backend "s3" {
    bucket         = "cloud-academy-tf-state-static-website"
    key            = "static-site/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
  }
}
