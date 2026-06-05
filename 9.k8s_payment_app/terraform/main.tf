module "vpc" {
  source = "./modules/vpc"

  project_name = "finpay"

  vpc_cidr = "10.0.0.0/16"

  availability_zones = [
    "eu-central-1a",
    "eu-central-1b",
    "eu-central-1c"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  private_app_subnets = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]

  private_db_subnets = [
    "10.0.21.0/24",
    "10.0.22.0/24",
    "10.0.23.0/24"
  ]
}

module "eks" {
  source = "./modules/eks"

  cluster_name = "finpay"

  private_subnet_ids = module.vpc.private_app_subnet_ids
}
