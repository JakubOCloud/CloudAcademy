include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/eks"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "database_secret" {
  config_path = "../database-secret"
}

inputs = {
  cluster_name = local.env.locals.cluster_name

  private_subnet_ids = dependency.vpc.outputs.private_app_subnet_ids

  db_secret_arn = dependency.database_secret.outputs.secret_arn

  node_instance_type = local.env.locals.eks_node_instance_type
  node_desired_size  = local.env.locals.eks_desired_size
  node_min_size      = local.env.locals.eks_min_size
  node_max_size      = local.env.locals.eks_max_size
}