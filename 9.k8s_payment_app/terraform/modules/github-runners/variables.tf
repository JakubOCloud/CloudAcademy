variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
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
  description = "GitHub repository or organization URL"
  type        = string
}

variable "namespace" {
  description = "Namespace for GitHub Actions runners"
  type        = string
  default     = "github-runners"
}

variable "runner_scale_set_name" {
  description = "Runner scale set name"
  type        = string
  default     = "finpay-runner"
}

variable "min_runners" {
  description = "Minimum number of runners"
  type        = number
  default     = 0
}

variable "max_runners" {
  description = "Maximum number of runners"
  type        = number
  default     = 2
}

variable "proxy_url" {
  description = "HTTPS proxy URL used by ARC and runners"
  type        = string
}
