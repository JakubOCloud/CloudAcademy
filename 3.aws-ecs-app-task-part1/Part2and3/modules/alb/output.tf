output "alb_id" {
  description = "ALB ID"
  value       = aws_lb.this.id
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "Target group arn"
  value       = aws_lb_target_group.this.arn
}

output "security_group_id" {
  description = "ALB sg id"
  value       = aws_security_group.alb.id
}
