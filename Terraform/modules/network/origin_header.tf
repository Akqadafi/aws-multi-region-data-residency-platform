############################################
# # Lab 2 - Origin Cloaking (CloudFront -> ALB only)
# # - Lock ALB SG inbound to CloudFront origin-facing prefix list
# # - Require secret header at ALB listener (only CloudFront knows it)
# ############################################

# CloudFront origin-facing managed prefix list (global)
data "aws_ec2_managed_prefix_list" "arcanum_cf_origin_facing01" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

locals {
  # MUST match what CloudFront sends in lab2_cloudfront_alb.tf
  origin_header_name = "X-arcanum-base"

  # IMPORTANT: do NOT recreate random_password here.
  # This references the one you already declared in bonus_b.tf:
  origin_header_value = random_password.arcanum_origin_header_value01.result
}



############################################
# ALB Listener behavior: default DENY, allow ONLY secret header
############################################

# NOTE:
# Best approach is to make HTTPS listener default_action a fixed 403.
# Then add ONE allow rule that forwards if header matches.
#
# That means: update aws_lb_listener.arcanum_https_listener01 in bonus_b.tf to:
#   default_action = fixed-response 403
#
# Then keep only this allow rule below.

resource "aws_lb_listener_rule" "arcanum_cf_origin_allow01" {
  count        = var.enable_origin_cloaking ? 1 : 0
  listener_arn = aws_lb_listener.arcanum_https_listener01.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.arcanum_tg01.arn
  }

  condition {
    http_header {
      http_header_name = local.origin_header_name
      values           = [local.origin_header_value]
    }
  }
}

resource "random_password" "arcanum_origin_header_value01" {
  length  = 32
  special = false
}
