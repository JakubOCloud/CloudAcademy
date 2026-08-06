include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "../../../modules/cloudwatch-observability"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name
}