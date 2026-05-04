output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "ID of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "ID of private subnets"
  value       = aws_subnet.private[*].id
}
