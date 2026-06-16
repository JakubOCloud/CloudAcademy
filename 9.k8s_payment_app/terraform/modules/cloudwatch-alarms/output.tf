output "rds_alarm_name" {
  value = aws_cloudwatch_metric_alarm.rds_cpu_high.alarm_name
}

output "eks_cpu_alarm_name" {
  value = aws_cloudwatch_metric_alarm.eks_cpu_high.alarm_name
}

output "eks_memory_alarm_name" {
  value = aws_cloudwatch_metric_alarm.eks_memory_high.alarm_name
}
