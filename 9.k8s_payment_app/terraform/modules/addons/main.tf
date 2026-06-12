resource "kubernetes_namespace" "payment_system" {
  metadata {
    name = "payment-system"
  }
}

resource "helm_release" "metrics_server" {
  name      = "metrics-server"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"

  set {
    name  = "image.repository"
    value = "366183011726.dkr.ecr.eu-central-1.amazonaws.com/k8s/metrics-server/metrics-server"
  }
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true

  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"

  set {
    name  = "image.repository"
    value = "366183011726.dkr.ecr.eu-central-1.amazonaws.com/external-secrets"
  }

  set {
    name  = "image.tag"
    value = "v2.6.0"
  }

  set {
    name  = "webhook.image.repository"
    value = "366183011726.dkr.ecr.eu-central-1.amazonaws.com/external-secrets"
  }

  set {
    name  = "webhook.image.tag"
    value = "v2.6.0"
  }

  set {
    name  = "certController.image.repository"
    value = "366183011726.dkr.ecr.eu-central-1.amazonaws.com/external-secrets"
  }

  set {
    name  = "certController.image.tag"
    value = "v2.6.0"
  }
}


