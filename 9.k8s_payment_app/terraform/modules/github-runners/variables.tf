variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "EKS cluster CA certificate"
  type        = string
  sensitive   = true
}

variable "github_config_url" {
  description = "GitHub repository or organization URL used by the runner scale set"
  type        = string
}

variable "github_token" {
  description = "GitHub authentication token for ARC"
  type        = string
  sensitive   = true
}

variable "namespace" {
  description = "Namespace for GitHub Actions runners"
  type        = string
  default     = "github-runners"
}

variable "runner_scale_set_name" {
  description = "Name of the GitHub Actions runner scale set"
  type        = string
  default     = "finpay-runner"
}

variable "min_runners" {
  description = "Minimum number of runner pods"
  type        = number
  default     = 0
}

variable "max_runners" {
  description = "Maximum number of runner pods"
  type        = number
  default     = 2
}
