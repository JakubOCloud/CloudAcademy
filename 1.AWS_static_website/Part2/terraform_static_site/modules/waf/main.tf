resource "aws_wafv2_web_acl" "this" {

  name        = "rate-limit"
  description = "Limits requests from each source ip to 100 requests/min"
  scope       = "CLOUDFRONT"
  tags        = var.tags

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "web-acl"
    sampled_requests_enabled   = true
  }
}


resource "aws_wafv2_web_acl_rule" "this" {
  name        = "rate-limit-rule"
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
    cloudwatch_metrics_enabled = true
    metric_name                = "rate-limit-rule"
    sampled_requests_enabled   = true
  }
}
