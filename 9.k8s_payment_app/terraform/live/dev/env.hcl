locals {
  environment = "dev"

  project_name = "finpay"
  cluster_name = "finpay-dev"

  vpc_cidr = "10.10.0.0/16"

  availability_zones = [
    "eu-central-1a",
    "eu-central-1b",
    "eu-central-1c"
  ]

  public_subnets = [
    "10.10.1.0/24",
    "10.10.2.0/24",
    "10.10.3.0/24"
  ]

  private_app_subnets = [
    "10.10.11.0/24",
    "10.10.12.0/24",
    "10.10.13.0/24"
  ]

  private_db_subnets = [
    "10.10.21.0/24",
    "10.10.22.0/24",
    "10.10.23.0/24"
  ]

  postgres_db_name     = "payments"
  postgres_db_username = "payments"

  postgres_instance_type = "t3.micro"

  eks_node_instance_type = "t3.small"
  eks_desired_size       = 1
  eks_min_size           = 1
  eks_max_size           = 2
}