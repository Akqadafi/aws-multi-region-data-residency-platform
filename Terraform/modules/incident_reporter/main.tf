data "aws_caller_identity" "arcanum_self01" {}
data "aws_region" "arcanum_region01" {}

locals {
  arcanum_ssm_param_path_trimmed = trim(var.ssm_param_path, "/")
  arcanum_waf_log_group_name     = var.waf_log_group_name != null ? trimspace(var.waf_log_group_name) : ""
  arcanum_secret_is_arn          = can(regex("^arn:aws:secretsmanager:", var.secret_id))
  arcanum_secret_arn             = local.arcanum_secret_is_arn ? var.secret_id : "arn:aws:secretsmanager:${data.aws_region.arcanum_region01.name}:${data.aws_caller_identity.arcanum_self01.account_id}:secret:${var.secret_id}*"
  arcanum_report_ready_topic_arn = trimspace(var.report_ready_topic_arn) != "" ? trimspace(var.report_ready_topic_arn) : (
    var.enable_separate_report_ready_topic ? aws_sns_topic.arcanum_ir_report_ready_topic01[0].arn : var.sns_topic_arn
  )
}

resource "aws_sns_topic" "arcanum_ir_report_ready_topic01" {
  count = var.enable_separate_report_ready_topic && trimspace(var.report_ready_topic_arn) == "" ? 1 : 0
  name  = "${var.project_name}-ir-report-ready"
}

resource "aws_s3_bucket" "arcanum_ir_reports_bucket01" {
  bucket        = "${var.project_name}-ir-reports-${data.aws_caller_identity.arcanum_self01.account_id}"
  force_destroy = var.report_bucket_force_destroy

  tags = merge(var.tags, {
    Name = "${var.project_name}-ir-reports-bucket01"
  })
}

resource "aws_s3_bucket_public_access_block" "arcanum_ir_reports_pab01" {
  bucket                  = aws_s3_bucket.arcanum_ir_reports_bucket01.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "arcanum_ir_reports_sse01" {
  bucket = aws_s3_bucket.arcanum_ir_reports_bucket01.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_role" "arcanum_ir_lambda_role01" {
  name = "${var.project_name}-ir-lambda-role01"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "arcanum_ir_lambda_policy01" {
  name = "${var.project_name}-ir-lambda-policy01"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:StartQuery",
          "logs:GetQueryResults",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:${data.aws_region.arcanum_region01.name}:${data.aws_caller_identity.arcanum_self01.account_id}:parameter/${local.arcanum_ssm_param_path_trimmed}*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = local.arcanum_secret_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.arcanum_ir_reports_bucket01.arn,
          "${aws_s3_bucket.arcanum_ir_reports_bucket01.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = local.arcanum_report_ready_topic_arn
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "aws-marketplace:ViewSubscriptions",
          "aws-marketplace:Subscribe",
          "aws-marketplace:Unsubscribe"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "arcanum_ir_lambda_attach01" {
  role       = aws_iam_role.arcanum_ir_lambda_role01.name
  policy_arn = aws_iam_policy.arcanum_ir_lambda_policy01.arn
}

resource "aws_iam_role_policy_attachment" "arcanum_ir_lambda_basiclogs01" {
  role       = aws_iam_role.arcanum_ir_lambda_role01.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "arcanum_ir_lambda_zip01" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_src"
  output_path = "${path.module}/build/arcanum_ir_reporter.zip"
}

resource "aws_lambda_function" "arcanum_ir_lambda01" {
  function_name = "${var.project_name}-ir-reporter01"
  role          = aws_iam_role.arcanum_ir_lambda_role01.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.11"
  timeout       = 120
  memory_size   = 256

  filename         = data.archive_file.arcanum_ir_lambda_zip01.output_path
  source_code_hash = data.archive_file.arcanum_ir_lambda_zip01.output_base64sha256

  environment {
    variables = {
      REPORT_BUCKET              = aws_s3_bucket.arcanum_ir_reports_bucket01.bucket
      REPORT_PREFIX              = var.report_prefix
      APP_LOG_GROUP              = var.app_log_group_name
      WAF_LOG_GROUP              = local.arcanum_waf_log_group_name
      SECRET_ID                  = var.secret_id
      SSM_PARAM_PATH             = var.ssm_param_path
      BEDROCK_MODEL_ID           = var.bedrock_model_id
      SNS_TOPIC_ARN              = var.sns_topic_arn
      REPORT_READY_SNS_TOPIC_ARN = local.arcanum_report_ready_topic_arn
      AUTO_IR_MODE               = lower(var.auto_ir_mode)
      FAST_WINDOW_MINUTES        = tostring(var.fast_report_window_minutes)
    }
  }
}

resource "aws_sns_topic_subscription" "arcanum_ir_lambda_sub01" {
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.arcanum_ir_lambda01.arn
}

resource "aws_sns_topic_subscription" "arcanum_ir_report_ready_email_sub01" {
  count = trimspace(var.report_ready_email_endpoint) != "" ? 1 : 0

  topic_arn = local.arcanum_report_ready_topic_arn
  protocol  = "email"
  endpoint  = trimspace(var.report_ready_email_endpoint)
}

resource "aws_lambda_permission" "arcanum_allow_sns_invoke01" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.arcanum_ir_lambda01.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}
