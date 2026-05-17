############################################
# Bonus E - WAF Logging Destinations
############################################

locals {
  arcanum_waf_logging_enabled = var.enable_waf && !var.enable_origin_cloaking
  arcanum_waf_log_destination = lower(var.waf_log_destination)
}

############################################
# CloudWatch Logs destination
############################################

resource "aws_cloudwatch_log_group" "arcanum_waf_log_group01" {
  count = local.arcanum_waf_logging_enabled && local.arcanum_waf_log_destination == "cloudwatch" ? 1 : 0

  # WAF logging destination names must start with aws-waf-logs-
  name              = "aws-waf-logs-${var.project_name}-webacl01"
  retention_in_days = var.waf_log_retention_days
  tags              = var.tags
}

############################################
# S3 destination
############################################

resource "aws_s3_bucket" "arcanum_waf_logs_bucket01" {
  count = local.arcanum_waf_logging_enabled && local.arcanum_waf_log_destination == "s3" ? 1 : 0

  # WAF logging destination names must start with aws-waf-logs-
  bucket_prefix = "aws-waf-logs-${var.project_name}-"
  tags          = var.tags
}

############################################
# Firehose destination (with S3 sink)
############################################

resource "aws_s3_bucket" "arcanum_waf_firehose_bucket01" {
  count = local.arcanum_waf_logging_enabled && local.arcanum_waf_log_destination == "firehose" ? 1 : 0

  bucket_prefix = "aws-waf-logs-${var.project_name}-firehose-"
  tags          = var.tags
}

data "aws_iam_policy_document" "arcanum_waf_firehose_assume_role01" {
  count = local.arcanum_waf_logging_enabled && local.arcanum_waf_log_destination == "firehose" ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "arcanum_waf_firehose_role01" {
  count = local.arcanum_waf_logging_enabled && local.arcanum_waf_log_destination == "firehose" ? 1 : 0

  name_prefix        = "aws-waf-logs-${var.project_name}-fh-role-"
  assume_role_policy = data.aws_iam_policy_document.arcanum_waf_firehose_assume_role01[0].json
  tags               = var.tags
}

data "aws_iam_policy_document" "arcanum_waf_firehose_policy01" {
  count = local.arcanum_waf_logging_enabled && local.arcanum_waf_log_destination == "firehose" ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.arcanum_waf_firehose_bucket01[0].arn,
      "${aws_s3_bucket.arcanum_waf_firehose_bucket01[0].arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "arcanum_waf_firehose_role_policy01" {
  count = local.arcanum_waf_logging_enabled && local.arcanum_waf_log_destination == "firehose" ? 1 : 0

  name_prefix = "aws-waf-logs-${var.project_name}-fh-pol-"
  role        = aws_iam_role.arcanum_waf_firehose_role01[0].id
  policy      = data.aws_iam_policy_document.arcanum_waf_firehose_policy01[0].json
}

resource "aws_kinesis_firehose_delivery_stream" "arcanum_waf_firehose01" {
  count = local.arcanum_waf_logging_enabled && local.arcanum_waf_log_destination == "firehose" ? 1 : 0

  # WAF logging destination names must start with aws-waf-logs-
  name        = "aws-waf-logs-${var.project_name}-firehose01"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.arcanum_waf_firehose_role01[0].arn
    bucket_arn = aws_s3_bucket.arcanum_waf_firehose_bucket01[0].arn
    prefix     = "waf-logs/"
  }

  depends_on = [aws_iam_role_policy.arcanum_waf_firehose_role_policy01]
}

############################################
# WAF logging configuration (one destination)
############################################

resource "aws_wafv2_web_acl_logging_configuration" "arcanum_waf_logging01" {
  count = local.arcanum_waf_logging_enabled ? 1 : 0

  resource_arn = aws_wafv2_web_acl.arcanum_waf01[0].arn

  log_destination_configs = [
    local.arcanum_waf_log_destination == "cloudwatch" ? aws_cloudwatch_log_group.arcanum_waf_log_group01[0].arn :
    local.arcanum_waf_log_destination == "s3" ? aws_s3_bucket.arcanum_waf_logs_bucket01[0].arn :
    aws_kinesis_firehose_delivery_stream.arcanum_waf_firehose01[0].arn
  ]
}
