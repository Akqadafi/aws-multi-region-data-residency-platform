############################################
# Bonus B - ALB Logging + Route53 Apex Alias
############################################

data "aws_caller_identity" "arcanum_current" {}

############################################
# ALB Access Logs -> S3
############################################

# Create/manage log bucket only when access logs are enabled and no external bucket is supplied.
resource "aws_s3_bucket" "arcanum_alb_logs_bucket01" {
  count = var.enable_alb_access_logs && var.alb_access_logs_bucket == null ? 1 : 0

  # Optional explicit name; otherwise use a globally-unique prefix.
  bucket        = var.alb_logs_bucket_name
  bucket_prefix = var.alb_logs_bucket_name == null ? "${var.project_name}-alb-logs-" : null

  tags = merge(var.tags, {
    Name = "${var.project_name}-alb-logs-bucket01"
  })
}

resource "aws_s3_bucket_public_access_block" "arcanum_alb_logs_pab01" {
  count = var.enable_alb_access_logs && var.alb_access_logs_bucket == null ? 1 : 0

  bucket                  = aws_s3_bucket.arcanum_alb_logs_bucket01[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "arcanum_alb_logs_policy01" {
  count = var.enable_alb_access_logs && var.alb_access_logs_bucket == null ? 1 : 0

  statement {
    sid     = "AllowALBLogDeliveryWrite"
    effect  = "Allow"
    actions = ["s3:PutObject"]

    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }

    resources = [
      "${aws_s3_bucket.arcanum_alb_logs_bucket01[0].arn}/${var.alb_access_logs_prefix}/AWSLogs/${data.aws_caller_identity.arcanum_current.account_id}/*"
    ]
  }

  statement {
    sid     = "AllowALBLogDeliveryAclCheck"
    effect  = "Allow"
    actions = ["s3:GetBucketAcl"]

    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }

    resources = [aws_s3_bucket.arcanum_alb_logs_bucket01[0].arn]
  }
}

resource "aws_s3_bucket_policy" "arcanum_alb_logs_policy01" {
  count = var.enable_alb_access_logs && var.alb_access_logs_bucket == null ? 1 : 0

  bucket = aws_s3_bucket.arcanum_alb_logs_bucket01[0].id
  policy = data.aws_iam_policy_document.arcanum_alb_logs_policy01[0].json
}

