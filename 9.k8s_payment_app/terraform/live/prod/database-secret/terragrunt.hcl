include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/database-secret"
}

dependency "postgres" {
  config_path = "../postgres-vm"
}

inputs = {
  project_name = local.env.locals.project_name
  environment  = local.env.locals.environment

  db_endpoint = dependency.postgres.outputs.private_ip
  db_port     = dependency.postgres.outputs.db_port
  db_name     = dependency.postgres.outputs.db_name
  db_username = dependency.postgres.outputs.db_username
  db_password = dependency.postgres.outputs.db_password
}