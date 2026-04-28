resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "static-website-dashboard"

  dashboard_body = jsonencode({
    widgets = [

      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title   = "CloudFront Total Requests"
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"

          metrics = [
            [
              "AWS/CloudFront",
              "Requests",
              "DistributionId", var.distribution_id,
              "Region", "Global"
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "CloudFront 4xx Error Rate"
          view   = "timeSeries"
          region = "us-east-1"

          metrics = [
            [
              "AWS/CloudFront",
              "4xxErrorRate",
              "DistributionId", var.distribution_id,
              "Region", "Global"
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "CloudFront 5xx Error Rate"
          view   = "timeSeries"
          region = "us-east-1"

          metrics = [
            [
              "AWS/CloudFront",
              "5xxErrorRate",
              "DistributionId", var.distribution_id,
              "Region", "Global"
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "WAF Blocked Requests"
          view   = "timeSeries"
          region = "us-east-1"
          stat   = "Sum"

          metrics = [
            [
              "AWS/WAFV2",
              "BlockedRequests",
              "WebACL", "rate-limit",
              "Rule", "rate-limit-rule"
            ]
          ]
        }
      }

    ]
  })
}
