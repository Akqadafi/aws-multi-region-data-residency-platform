# Explanation: The shield generator moves to the edge — CloudFront WAF blocks nonsense before it hits your VPC.
resource "aws_wafv2_web_acl" "arcanum_cf_waf01" {
  count    = var.enable_waf && var.enable_origin_cloaking ? 1 : 0
  provider = aws.use1
  name     = "${var.project_name}-cf-waf01"
  scope    = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-cf-waf01"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-cf-waf-common"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_cloudwatch_log_group" "arcanum_cf_waf_log_group01" {
  provider = aws.use1
  count    = var.enable_waf && var.enable_origin_cloaking && var.waf_log_destination == "cloudwatch" ? 1 : 0

  name              = "aws-waf-logs-arcanum-cf-webacl01"
  retention_in_days = var.waf_log_retention_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-cf-waf-log-group01"
  })
}

resource "aws_wafv2_web_acl_logging_configuration" "arcanum_cf_waf_logging01" {
  provider = aws.use1
  count    = var.enable_waf && var.enable_origin_cloaking && var.waf_log_destination == "cloudwatch" ? 1 : 0

  resource_arn = aws_wafv2_web_acl.arcanum_cf_waf01[0].arn

  log_destination_configs = [
    aws_cloudwatch_log_group.arcanum_cf_waf_log_group01[0].arn
  ]
}