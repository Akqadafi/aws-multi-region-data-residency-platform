# ############################################
# # Least-Privilege IAM (BONUS A)
# ############################################


data "aws_caller_identity" "arcanum_self01" {}

data "aws_iam_policy_document" "arcanum_ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "arcanum_ec2_role01" {
  name               = "${var.project_name}-ec2-role01"
  assume_role_policy = data.aws_iam_policy_document.arcanum_ec2_assume_role.json
}

resource "aws_iam_instance_profile" "arc_bonus_ec2" {
  name = "${var.project_name}-instance-profile-private"
  role = aws_iam_role.arcanum_ec2_role01.name
}


# # Explanation: arcanum doesn’t hand out the Falcon keys—this policy scopes reads to your lab paths only.
resource "aws_iam_policy" "arcanum_leastpriv_read_params01" {
  name        = "${var.project_name}-lp-ssm-read01"
  description = "Least-privilege read for SSM Parameter Store under /lab/db/*"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadLabDbParams"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.arcanum_self01.account_id}:parameter/lab/db/*"
        ]
      }
    ]
  })
}

# # Explanation: arcanum only opens *this* vault—GetSecretValue for only your secret (not the whole planet).
resource "aws_iam_policy" "arcanum_leastpriv_read_secret01" {
  name        = "${var.project_name}-lp-secrets-read01"
  description = "Least-privilege read for the lab DB secret"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadOnlyLabSecret"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secret_arn_guess
      }
    ]
  })
}

# # Explanation: When the Falcon logs scream, this lets arcanum ship logs to CloudWatch without giving away the Death Star plans.
resource "aws_iam_policy" "arcanum_leastpriv_cwlogs01" {
  name        = "${var.project_name}-lp-cwlogs01"
  description = "Least-privilege CloudWatch Logs write for the app log group"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "WriteLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "${var.cloudwatch_log_group_arn}:*"
        ]
      }
    ]
  })
}

# # Explanation: Attach the scoped policies—arcanum loves power, but only the safe kind.
resource "aws_iam_role_policy_attachment" "arcanum_attach_lp_params01" {
  role       = aws_iam_role.arcanum_ec2_role01.name
  policy_arn = aws_iam_policy.arcanum_leastpriv_read_params01.arn
}

resource "aws_iam_role_policy_attachment" "arcanum_attach_lp_secret01" {
  role       = aws_iam_role.arcanum_ec2_role01.name
  policy_arn = aws_iam_policy.arcanum_leastpriv_read_secret01.arn
}

resource "aws_iam_role_policy_attachment" "arcanum_attach_lp_cwlogs01" {
  role       = aws_iam_role.arcanum_ec2_role01.name
  policy_arn = aws_iam_policy.arcanum_leastpriv_cwlogs01.arn
}

resource "aws_iam_role_policy_attachment" "arcanum_ec2_ssm_attach" {
  role       = aws_iam_role.arcanum_ec2_role01.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
