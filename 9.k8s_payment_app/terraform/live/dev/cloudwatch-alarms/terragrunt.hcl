include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "../../../modules/cloudwatch-alarms"
}

dependency "eks" {
  config_path = "../eks"
}

dependency "postgres" {
  config_path = "../postgres-vm"
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name

  postgres_instance_id = dependency.postgres.outputs.instance_id
}