include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/postgres-vm"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  project_name = local.env.locals.project_name
  environment  = local.env.locals.environment

  vpc_id           = dependency.vpc.outputs.vpc_id
  vpc_cidr          = local.env.locals.vpc_cidr
  private_subnet_id = dependency.vpc.outputs.private_db_subnet_ids[0]

  instance_type = local.env.locals.postgres_instance_type
}