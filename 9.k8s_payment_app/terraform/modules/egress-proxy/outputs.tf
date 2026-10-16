output "private_ip" {
  description = "Private IP used by EKS to reach the proxy"
  value       = aws_instance.proxy.private_ip
}

output "proxy_url" {
  description = "HTTP proxy URL for HTTPS CONNECT traffic"
  value       = "http://${aws_instance.proxy.private_ip}:3128"
}
