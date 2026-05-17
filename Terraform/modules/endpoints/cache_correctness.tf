############################################
# Lab 2B - Cache Correctness
# Static = aggressive caching
# API    = safe default (no caching)
############################################

############################################################
# /static/* cache policy
# Strong caching, ignore cookies/headers/query strings
############################################################

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_cache_policy" "arcanum_cache_static01" {
  name        = "${var.project_name}-cache-static01"
  comment     = "Aggressive caching for /static/*"
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

############################################################
# /api/* cache policy
# Safe default: effectively disable caching
############################################################
resource "aws_cloudfront_cache_policy" "arcanum_cache_api_disabled01" {
  name        = "${var.project_name}-cache-api-disabled01"
  comment     = "Disable caching for /api/* by default"
  default_ttl = 0
  max_ttl     = 0
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

############################################################
# /static/* origin request policy
# Minimal forwarding
############################################################
resource "aws_cloudfront_origin_request_policy" "arcanum_orp_static01" {
  name    = "${var.project_name}-orp-static01"
  comment = "Minimal forwarding for static assets"

  cookies_config {
    cookie_behavior = "none"
  }

  headers_config {
    header_behavior = "none"
  }

  query_strings_config {
    query_string_behavior = "none"
  }
}

############################################################
# /api/* origin request policy
# Forward what dynamic endpoints may need
############################################################
resource "aws_cloudfront_origin_request_policy" "arcanum_orp_api01" {
  name    = "${var.project_name}-orp-api01"
  comment = "Forward necessary values for API calls"

  cookies_config {
    cookie_behavior = "all"
  }

  headers_config {
    header_behavior = "allViewer"
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

############################################################
# Static response headers policy
# Explicit browser caching header for static content
############################################################
resource "aws_cloudfront_response_headers_policy" "arcanum_rsp_static01" {
  name    = "${var.project_name}-rsp-static01"
  comment = "Add explicit Cache-Control for static content"

  custom_headers_config {
    items {
      header   = "Cache-Control"
      value    = "public, max-age=86400, immutable"
      override = true
    }
  }
}