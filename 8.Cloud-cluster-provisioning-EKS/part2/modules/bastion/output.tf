output "security_group_id" {
  value = aws_security_group.this.id
}

output "bastion_role_arn" {
  value = aws_iam_role.bastion_role.arn
}
