output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  value = replace(
    aws_iam_openid_connect_provider.eks.url,
    "https://",
    ""
  )
}

output "external_secrets_role_arn" {
  value = aws_iam_role.external_secrets.arn
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller.arn
}

output "fluent_bit_role_arn" {
  value = aws_iam_role.fluent_bit.arn
}
