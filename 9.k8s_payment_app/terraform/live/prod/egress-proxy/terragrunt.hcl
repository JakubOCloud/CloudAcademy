
include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/egress-proxy"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  project_name = local.env.locals.project_name
  environment  = local.env.locals.environment

  vpc_id          = dependency.vpc.outputs.vpc_id
  public_subnet_id = dependency.vpc.outputs.public_subnet_ids[0]

  # Podsieci aplikacyjne EKS, a nie podsieci bazy danych.
  allowed_client_cidrs = local.env.locals.private_app_subnets
}
