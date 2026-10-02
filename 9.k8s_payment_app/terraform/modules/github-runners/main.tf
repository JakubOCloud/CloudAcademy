provider "helm" {
  kubernetes = {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--region",
        var.aws_region,
        "--cluster-name",
        "finpay-prod"
      ]
    }
  }
}

resource "helm_release" "arc_controller" {
  name             = "gha-runner-scale-set-controller"
  namespace        = var.namespace
  create_namespace = true

  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set-controller"

  wait    = true
  timeout = 600
}

resource "helm_release" "runner_scale_set" {
  name      = var.runner_scale_set_name
  namespace = var.namespace

  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set"

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      githubConfigUrl = var.github_config_url
      githubConfigSecret = {
        github_token = var.github_token
      }

      minRunners = var.min_runners
      maxRunners = var.max_runners

      containerMode = {
        type = "dind"
      }

      template = {
        spec = {
          containers = [
            {
              name  = "runner"
              image = "ghcr.io/actions/actions-runner:latest"

              resources = {
                requests = {
                  cpu    = "500m"
                  memory = "1Gi"
                }

                limits = {
                  cpu    = "1"
                  memory = "2Gi"
                }
              }
            }
          ]
        }
      }
    })
  ]

  depends_on = [
    helm_release.arc_controller
  ]
}
