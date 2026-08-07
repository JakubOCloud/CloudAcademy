terraform {
  backend "s3" {
    bucket         = "cloud-academy-tf-state-payment-app"
    key            = "payment-app/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
