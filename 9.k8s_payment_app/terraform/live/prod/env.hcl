locals {
  environment = "prod"

  project_name = "finpay"
  cluster_name = "finpay-prod"

  vpc_cidr = "10.20.0.0/16"

  availability_zones = [
    "eu-central-1a",
    "eu-central-1b",
    "eu-central-1c"
  ]

  public_subnets = [
    "10.20.1.0/24",
    "10.20.2.0/24",
    "10.20.3.0/24"
  ]

  private_app_subnets = [
    "10.20.11.0/24",
    "10.20.12.0/24",
    "10.20.13.0/24"
  ]

  private_db_subnets = [
    "10.20.21.0/24",
    "10.20.22.0/24",
    "10.20.23.0/24"
  ]

  postgres_db_name     = "payments"
  postgres_db_username = "payments"

  postgres_instance_type = "t3.small"

  eks_node_instance_type = "t3.medium"
  eks_desired_size       = 2
  eks_min_size           = 2
  eks_max_size           = 5
}