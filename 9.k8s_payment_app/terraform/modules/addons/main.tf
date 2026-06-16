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

  set {
    name  = "image.tag"
    value = "v0.8.0"
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

  depends_on = [
    helm_release.aws_load_balancer_controller
  ]
}

resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = var.alb_controller_role_arn
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name      = "aws-load-balancer-controller"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "region"
    value = "eu-central-1"
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "image.repository"
    value = "366183011726.dkr.ecr.eu-central-1.amazonaws.com/aws-load-balancer-controller"
  }

  set {
    name  = "image.tag"
    value = "v3.4.0"
  }

  depends_on = [
    kubernetes_service_account.alb_controller
  ]
}

resource "helm_release" "fluent_bit" {
  name      = "aws-for-fluent-bit"
  namespace = "amazon-cloudwatch"

  create_namespace = true

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"

  set {
    name  = "cloudWatch.region"
    value = "eu-central-1"
  }

  set {
    name  = "cloudWatch.logGroupName"
    value = "/eks/finpay/application"
  }

  set {
    name  = "cloudWatch.logStreamPrefix"
    value = "pod-"
  }

  set {
    name  = "image.repository"
    value = "366183011726.dkr.ecr.eu-central-1.amazonaws.com/aws-for-fluent-bit"
  }

  set {
    name  = "image.tag"
    value = "stable"
  }
}

