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
        var.cluster_name
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
  version    = "0.15.0"

  values = [
    yamlencode({
      image = {
        repository = "366183011726.dkr.ecr.eu-central-1.amazonaws.com/github/actions/gha-runner-scale-set-controller"
        tag        = "0.15.0"
        pullPolicy = "IfNotPresent"
      }

      env = [
        {
          name  = "HTTP_PROXY"
          value = var.proxy_url
        },
        {
          name  = "HTTPS_PROXY"
          value = var.proxy_url
        },
        {
          name  = "http_proxy"
          value = var.proxy_url
        },
        {
          name  = "https_proxy"
          value = var.proxy_url
        },
        {
          name  = "NO_PROXY"
          value = "localhost,127.0.0.1,.svc,.cluster.local,10.20.0.0/16,172.20.0.0/16"
        },
        {
          name  = "no_proxy"
          value = "localhost,127.0.0.1,.svc,.cluster.local,10.20.0.0/16,172.20.0.0/16"
        }
      ]
    })
  ]

  wait    = true
  timeout = 600
}

resource "helm_release" "runner_scale_set" {
  name      = var.runner_scale_set_name
  namespace = var.namespace

  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set"
  version    = "0.15.0"

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      githubConfigUrl    = var.github_config_url
      githubConfigSecret = "github-runner-auth"

      proxy = {
        http = {
          url = var.proxy_url
        }
        https = {
          url = var.proxy_url
        }
        noProxy = [
          "localhost",
          "127.0.0.1",
          ".svc",
          ".cluster.local",
          "10.20.0.0/16",
          "172.20.0.0/16"
        ]
      }

      minRunners = var.min_runners
      maxRunners = var.max_runners

      template = {
        spec = {
          initContainers = [
            {
              name  = "init-dind-externals"
              image = "366183011726.dkr.ecr.eu-central-1.amazonaws.com/github/actions/actions-runner:latest"

              command = [
                "/bin/bash",
                "-c",
                "cp -r /home/runner/externals/. /home/runner/tmpDir/"
              ]

              volumeMounts = [
                {
                  name      = "dind-externals"
                  mountPath = "/home/runner/tmpDir"
                }
              ]
            }
          ]

          containers = [
            {
              name    = "runner"
              image   = "366183011726.dkr.ecr.eu-central-1.amazonaws.com/github/actions/actions-runner:latest"
              command = ["/home/runner/run.sh"]

              env = [
                {
                  name  = "DOCKER_HOST"
                  value = "unix:///var/run/docker.sock"
                }
              ]

              volumeMounts = [
                {
                  name      = "work"
                  mountPath = "/home/runner/_work"
                },
                {
                  name      = "dind-sock"
                  mountPath = "/var/run"
                }
              ]

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
            },
            {
              name  = "dind"
              image = "366183011726.dkr.ecr.eu-central-1.amazonaws.com/docker-hub/library/docker:dind"

              args = [
                "dockerd",
                "--host=unix:///var/run/docker.sock",
                "--group=$(DOCKER_GROUP_GID)"
              ]

              env = [
                {
                  name  = "DOCKER_GROUP_GID"
                  value = "123"
                },
                {
                  name  = "HTTP_PROXY"
                  value = var.proxy_url
                },
                {
                  name  = "HTTPS_PROXY"
                  value = var.proxy_url
                },
                {
                  name  = "http_proxy"
                  value = var.proxy_url
                },
                {
                  name  = "https_proxy"
                  value = var.proxy_url
                },
                {
                  name  = "NO_PROXY"
                  value = "localhost,127.0.0.1,.svc,.cluster.local,10.20.0.0/16,172.20.0.0/16"
                },
                {
                  name  = "no_proxy"
                  value = "localhost,127.0.0.1,.svc,.cluster.local,10.20.0.0/16,172.20.0.0/16"
                }
              ]

              securityContext = {
                privileged = true
              }

              volumeMounts = [
                {
                  name      = "work"
                  mountPath = "/home/runner/_work"
                },
                {
                  name      = "dind-sock"
                  mountPath = "/var/run"
                },
                {
                  name      = "dind-externals"
                  mountPath = "/home/runner/externals"
                }
              ]
            }
          ]

          volumes = [
            {
              name     = "work"
              emptyDir = {}
            },
            {
              name     = "dind-sock"
              emptyDir = {}
            },
            {
              name     = "dind-externals"
              emptyDir = {}
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
