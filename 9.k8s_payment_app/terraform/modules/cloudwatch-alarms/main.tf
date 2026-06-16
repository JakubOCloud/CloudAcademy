resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "finpay-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "CPUUtilization"
  namespace   = "AWS/RDS"

  period    = 300
  statistic = "Average"

  threshold = 80

  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }

  alarm_description = "RDS CPU above 80%"
}

resource "aws_cloudwatch_metric_alarm" "eks_cpu_high" {
  alarm_name          = "finpay-eks-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  threshold = 80

  metric_name = "node_cpu_utilization"
  namespace   = "ContainerInsights"

  statistic = "Average"
  period    = 300

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_description = "EKS CPU above 80%"
}

resource "aws_cloudwatch_metric_alarm" "eks_memory_high" {
  alarm_name          = "finpay-eks-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "node_memory_utilization"
  namespace   = "ContainerInsights"

  statistic = "Average"
  period    = 300

  threshold = 80

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_description = "EKS memory utilization above 80%"
}
