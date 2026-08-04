locals {
  aws_region = "eu-central-1"

  common_tags = {
    project    = "payment-app"
    managed_by = "terragrunt"
  }
}

remote_state {
  backend = "s3"

  config = {
    bucket         = "cloud-academy-tf-state-payment-app"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = {
      project    = "payment-app"
      managed_by = "terragrunt"
    }
  }
}
EOF
}