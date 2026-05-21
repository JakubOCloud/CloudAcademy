terraform {
  backend "s3" {
    bucket         = "eks-tf-state-366183011726-eu-central-1-an"
    key            = "eks/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
