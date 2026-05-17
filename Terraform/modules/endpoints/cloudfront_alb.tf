# ###########################################
# Lab 2 - CloudFront in front of ALB
# Internet -> CloudFront (+WAF) -> ALB -> Private EC2 -> RDS
# ###########################################

# IMPORTANT:
# - This file assumes aws_lb.arcanum_alb01 already exists (from Bonus B).
# - This file assumes you already have ONE random_password resource somewhere else
#   (e.g., bonus_b.tf) named: random_password.arcanum_origin_header_value01
# - This file assumes a CloudFront-scoped WAF exists:
#   aws_wafv2_web_acl.arcanum_cf_waf01 (scope = "CLOUDFRONT")

locals {
  # Explanation: arcanum needs a home planet—Route53 hosted zone is your DNS territory.
  arcanum_zone_name = var.route53_zone_name != "" ? var.route53_zone_name : var.domain_name

  # Explanation: Use either Terraform-managed zone or a pre-existing zone ID (students choose their destiny).
  arcanum_zone_id = var.manage_route53_in_terraform ? aws_route53_zone.arcanum_zone01[0].zone_id : data.aws_route53_zone.arcanum_existing[0].zone_id
  # Explanation: This is the app address that will growl at the galaxy (app.arcanum-growl.com).
  arcanum_app_fqdn = "${var.app_subdomain}.${var.domain_name}"
  #   # Prefer a caller-supplied logs bucket; otherwise use the managed bucket when enabled.
  #   arcanum_alb_logs_bucket_name = var.alb_access_logs_bucket != null ? var.alb_access_logs_bucket : (var.enable_alb_access_logs ? aws_s3_bucket.arcanum_alb_logs_bucket01[0].bucket : null)
}
# Explanation: arcanum uses AWS-managed policies—battle-tested configs so students learn the real names.
data "aws_cloudfront_cache_policy" "arcanum_use_origin_cache_headers01" {
  name = "UseOriginCacheControlHeaders"
}

# Explanation: Same idea, but includes query strings in the cache key when your API truly varies by them.
data "aws_cloudfront_cache_policy" "arcanum_use_origin_cache_headers_qs01" {
  name = "UseOriginCacheControlHeaders-QueryStrings"
}

# Explanation: Origin request policies let us forward needed stuff without polluting the cache key.
# (Origin request policies are separate from cache policies.) :contentReference[oaicite:6]{index=6}
data "aws_cloudfront_origin_request_policy" "arcanum_orp_all_viewer01" {
  name = "Managed-AllViewer"
}

data "aws_cloudfront_origin_request_policy" "arcanum_orp_all_viewer_except_host01" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_distribution" "arcanum_cf01" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.project_name}-cf01"
  web_acl_id      = var.cloudfront_waf_arn

  origin {
    origin_id   = "${var.project_name}-alb-origin01"
    domain_name = var.alb_dns_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    origin_shield {
      enabled              = true
      origin_shield_region = "ap-northeast-1"
    }

    custom_header {
      name  = var.origin_header_name
      value = var.origin_header_value
    }
  }

  ############################################################
  # Honors: /api/public-feed = origin-driven caching
  # More specific must come before /api/*
  ############################################################
  ordered_cache_behavior {
    path_pattern           = "/api/public-feed"
    target_origin_id       = "${var.project_name}-alb-origin01"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id          = data.aws_cloudfront_cache_policy.arcanum_use_origin_cache_headers01.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.arcanum_orp_all_viewer_except_host01.id

    compress = true
  }

  ############################################################
  # /api/* = safe default (no caching)
  ############################################################
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "${var.project_name}-alb-origin01"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id          = aws_cloudfront_cache_policy.arcanum_cache_api_disabled01.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.arcanum_orp_api01.id

    compress = true
  }

  ############################################################
  # /static/* = cache hard
  ############################################################
  ordered_cache_behavior {
    path_pattern           = "/static/*"
    target_origin_id       = "${var.project_name}-alb-origin01"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.arcanum_orp_static01.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.arcanum_rsp_static01.id

    compress = true
  }

  ############################################################
  # Default behavior = conservative / dynamic
  ############################################################
  default_cache_behavior {
    target_origin_id       = "${var.project_name}-alb-origin01"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id          = aws_cloudfront_cache_policy.arcanum_cache_api_disabled01.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.arcanum_orp_api01.id

    compress = true
  }

  aliases = [
    var.domain_name,
    "${var.app_subdomain}.${var.domain_name}"
  ]

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.arcanum_cf_cert01.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  depends_on = [
    aws_acm_certificate_validation.arcanum_cf_cert_validation01
  ]
}