include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/github-runners"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  aws_region     = "eu-central-1"
  cluster_name   = local.env.locals.cluster_name

  cluster_endpoint = dependency.eks.outputs.cluster_endpoint

  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data

  github_config_url = "https://github.com/JakubOCloud/CloudAcademy"

  namespace            = "github-runners"
  runner_scale_set_name = "finpay-runner"

  min_runners = 0
  max_runners = 2
}