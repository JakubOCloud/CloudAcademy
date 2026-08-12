include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "../../../modules/addons"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  aws_region = "eu-central-1"
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  cluster_name = dependency.eks.outputs.cluster_name

  vpc_id = dependency.vpc.outputs.vpc_id

  alb_controller_role_arn = dependency.eks.outputs.alb_controller_role_arn

  fluent_bit_role_arn = dependency.eks.outputs.fluent_bit_role_arn
}