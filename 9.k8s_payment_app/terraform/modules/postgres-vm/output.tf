output "private_ip" {
  value = aws_instance.postgres.private_ip
}

output "instance_id" {
  value = aws_instance.postgres.id
}

output "db_name" {
  value = "payments"
}

output "db_port" {
  value = 5432
}

output "db_username" {
  value = "payments"
}

output "db_password" {
  value     = random_password.postgres.result
  sensitive = true
}
