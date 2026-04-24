resource "aws_wafv2_web_acl" "this" {
  provider = aws.us_east_1

  name        = "request-limit"
  description = "Limits requests from each source ip to 100 requests/min"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  tags = {
    tags = var.tags
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}


resource "aws_wafv2_web_acl_rule" "this" {
  name        = "request-limit-rule"
  priority    = 1
  web_acl_arn = aws_wafv2_web_acl.this.arn

  action {
    block {}
  }

  statement {
    rate_based_statement {
      limit                 = 100
      aggregate_key_type    = "IP"
      evaluation_window_sec = 60
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}
