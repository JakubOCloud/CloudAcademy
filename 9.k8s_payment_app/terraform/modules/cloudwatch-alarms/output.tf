output "postgres_vm_alarm_name" {
  value = aws_cloudwatch_metric_alarm.postgres_vm_cpu_high.alarm_name
}

output "eks_cpu_alarm_name" {
  value = aws_cloudwatch_metric_alarm.eks_cpu_high.alarm_name
}

output "eks_memory_alarm_name" {
  value = aws_cloudwatch_metric_alarm.eks_memory_high.alarm_name
}
