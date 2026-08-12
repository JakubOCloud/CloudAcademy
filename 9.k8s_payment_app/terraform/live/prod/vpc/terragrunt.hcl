include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  project_name = local.env.locals.project_name
  environment = local.env.locals.environment
  
  vpc_cidr = local.env.locals.vpc_cidr

  availability_zones = local.env.locals.availability_zones
  public_subnets     = local.env.locals.public_subnets

  private_app_subnets = local.env.locals.private_app_subnets
  private_db_subnets  = local.env.locals.private_db_subnets
}