locals {
  # # Explanation: arcanum needs a home planet—Route53 hosted zone is your DNS territory.
  arcanum_zone_name = var.domain_name

  # # # Explanation: Use either Terraform-managed zone or a pre-existing zone ID (students choose their destiny).
  arcanum_zone_id = var.manage_route53_in_terraform ? var.route53_zone_id : data.aws_route53_zone.arcanum_existing[0].zone_id
  # # Explanation: This is the app address that will growl at the galaxy (app.arcanum-growl.com).
  # arcanum_app_fqdn = "${var.app_subdomain}.${var.domain_name}"
  # # Prefer a caller-supplied logs bucket; otherwise use the managed bucket when enabled.
  arcanum_alb_logs_bucket_name = var.alb_access_logs_bucket != null ? var.alb_access_logs_bucket : (var.enable_alb_access_logs ? aws_s3_bucket.arcanum_alb_logs_bucket01[0].bucket : null)
}

resource "aws_vpc" "arcanum_vpc01" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-vpc01"
  })
}

resource "aws_internet_gateway" "arcanum_igw01" {
  vpc_id = aws_vpc.arcanum_vpc01.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-igw01"
  })
}

resource "aws_subnet" "arcanum_public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.arcanum_vpc01.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-public-subnet0${count.index + 1}"
  })
}

resource "aws_subnet" "arcanum_private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.arcanum_vpc01.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name = "${var.project_name}-private-subnet0${count.index + 1}"
  })
}

resource "aws_eip" "arcanum_nat_eip01" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-nat-eip01"
  })
}

resource "aws_nat_gateway" "arcanum_nat01" {
  allocation_id = aws_eip.arcanum_nat_eip01.id
  subnet_id     = aws_subnet.arcanum_public_subnets[0].id

  tags = merge(var.tags, {
    Name = "${var.project_name}-nat01"
  })

  depends_on = [aws_internet_gateway.arcanum_igw01]
}

resource "aws_route_table" "arcanum_public_rt01" {
  vpc_id = aws_vpc.arcanum_vpc01.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-public-rt01"
  })
}

resource "aws_route" "arcanum_public_default_route" {
  route_table_id         = aws_route_table.arcanum_public_rt01.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.arcanum_igw01.id
}

resource "aws_route_table_association" "arcanum_public_rta" {
  count          = length(aws_subnet.arcanum_public_subnets)
  subnet_id      = aws_subnet.arcanum_public_subnets[count.index].id
  route_table_id = aws_route_table.arcanum_public_rt01.id
}

resource "aws_route_table" "arcanum_private_rt01" {
  vpc_id = aws_vpc.arcanum_vpc01.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-private-rt01"
  })
}

resource "aws_route" "arcanum_private_default_route" {
  route_table_id         = aws_route_table.arcanum_private_rt01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.arcanum_nat01.id
}

resource "aws_route_table_association" "arcanum_private_rta" {
  count          = length(aws_subnet.arcanum_private_subnets)
  subnet_id      = aws_subnet.arcanum_private_subnets[count.index].id
  route_table_id = aws_route_table.arcanum_private_rt01.id
}

############################################
# Application Load Balancer
############################################

resource "aws_security_group" "arcanum_alb_sg01" {
  name        = "${var.project_name}-alb-sg01"
  description = "ALB security group"
  vpc_id      = aws_vpc.arcanum_vpc01.id

  # Public Ingress
  dynamic "ingress" {
    for_each = var.alb_allow_public_http_https ? [1] : []
    content {
      description = "HTTP from internet (redirect to HTTPS)"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = var.alb_allow_public_http_https ? [1] : []
    content {
      description = "HTTPS from internet"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Egress: ALB -> targets (usually port 80). You can tighten later if you want.
  egress {
    description = "ALB to targets"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-alb-sg01" }
}

resource "aws_lb" "arcanum_alb01" {
  name               = "${var.project_name}-alb01"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.arcanum_alb_sg01.id]
  subnets         = aws_subnet.arcanum_public_subnets[*].id

  # Explanation: arcanum keeps flight logs—ALB access logs go to S3 for audits and incident response.
  dynamic "access_logs" {
    for_each = var.enable_alb_access_logs ? [1] : []
    content {
      bucket  = local.arcanum_alb_logs_bucket_name
      prefix  = var.alb_access_logs_prefix
      enabled = var.enable_alb_access_logs
    }
  }

  depends_on = [
    aws_s3_bucket_policy.arcanum_alb_logs_policy01,
    aws_s3_bucket_public_access_block.arcanum_alb_logs_pab01
  ]

  tags = { Name = "${var.project_name}-alb01" }
}

############################################
# Target Group + Attachment
############################################

resource "aws_lb_target_group" "arcanum_tg01" {
  name     = "${var.project_name}-tg01"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.arcanum_vpc01.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200-399"
  }

  tags = { Name = "${var.project_name}-tg01" }
}

############################################
# ACM Certificate (TLS)
############################################

resource "aws_acm_certificate" "arcanum_acm_cert01" {
  domain_name               = var.domain_name
  subject_alternative_names = ["app.${var.domain_name}"]
  validation_method         = upper(var.certificate_validation_method)

  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = "${var.project_name}-acm-cert01" }
}

# Explanation: ACM asks for proof of domain ownership. DNS records provide that proof.
resource "aws_route53_record" "arcanum_acm_validation_records01" {
  allow_overwrite = true

  for_each = upper(var.certificate_validation_method) == "DNS" ? {
    for dvo in aws_acm_certificate.arcanum_acm_cert01.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  zone_id = local.arcanum_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# Explanation: This ties proof records back to ACM so the certificate can become ISSUED.
resource "aws_acm_certificate_validation" "arcanum_acm_validation01_dns_bonus" {
  count = upper(var.certificate_validation_method) == "DNS" ? 1 : 0

  certificate_arn = aws_acm_certificate.arcanum_acm_cert01.arn
  validation_record_fqdns = [
    for r in aws_route53_record.arcanum_acm_validation_records01 : r.fqdn
  ]
}
# # EMAIL validation path (manual) — kept for compatibility.
# resource "aws_acm_certificate_validation" "arcanum_acm_validation01" {
#   certificate_arn = aws_acm_certificate.arcanum_acm_cert01.arn
#   # If using DNS validation, your DNS validation resource should exist elsewhere (bonus_b_route53.tf).
# }

############################################
# ALB Listeners: HTTP -> HTTPS redirect, HTTPS -> (Lab1 forward OR Lab2 deny+rule)
############################################

resource "aws_lb_listener" "arcanum_http_listener01" {
  load_balancer_arn = aws_lb.arcanum_alb01.arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.enable_origin_cloaking ? [1] : []
    content {
      type = "fixed-response"
      fixed_response {
        content_type = "text/plain"
        status_code  = "403"
        message_body = "Forbidden"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.enable_origin_cloaking ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.arcanum_tg01.arn
    }
  }
}

resource "aws_lb_listener_rule" "arcanum_cf_origin_allow_http01" {
  count        = var.enable_origin_cloaking ? 1 : 0
  listener_arn = aws_lb_listener.arcanum_http_listener01.arn
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

resource "aws_lb_listener" "arcanum_https_listener01" {
  load_balancer_arn = aws_lb.arcanum_alb01.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.arcanum_acm_cert01.arn

  # When origin cloaking is OFF: normal forward
  dynamic "default_action" {
    for_each = var.enable_origin_cloaking ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.arcanum_tg01.arn
    }
  }

  # When origin cloaking is ON: default deny
  dynamic "default_action" {
    for_each = var.enable_origin_cloaking ? [1] : []
    content {
      type = "fixed-response"
      fixed_response {
        content_type = "text/plain"
        status_code  = "403"
        message_body = "Forbidden"
      }
    }
  }

  # TODO: If DNS validation is enabled, ensure validation completes before listener creation.
  depends_on = [aws_acm_certificate_validation.arcanum_acm_validation01_dns_bonus]
}

############################################
# Hosted Zone (optional creation)
############################################

# Explanation: A hosted zone is like claiming Kashyyyk in DNS—names here become law across the galaxy.

############################################
# ACM DNS Validation Records
############################################

# Explanation: ACM asks “prove you own this planet”—DNS validation is arcanum roaring in the right place.

# Explanation: This ties the “proof record” back to ACM—arcanum gets his green checkmark for TLS.

# ############################################
# # ALIAS record: app.arcanum-base.com -> ALB
# ############################################

# # # Explanation: This is the holographic sign outside the cantina—app.arcanum-base.com points to your ALB.
# resource "aws_route53_record" "arcanum_app_alias01" {
#   zone_id = local.arcanum_zone_id
#   name    = local.arcanum_app_fqdn
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.arcanum_cf01.domain_name
#     zone_id                = aws_cloudfront_distribution.arcanum_cf01.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

# # Apex -> ALB
# resource "aws_route53_record" "arcanum_apex_to_alb" {
#   zone_id = data.aws_route53_zone.arcanum_existing.zone_id
#   name    = var.domain_name
#   type    = "A"

#   alias {
#     name                   = aws_lb.arcanum_alb01.dns_name
#     zone_id                = aws_lb.arcanum_alb01.zone_id
#     evaluate_target_health = true
#   }
# }

# # app -> ALB
# resource "aws_route53_record" "arcanum_app_to_alb" {
#   zone_id = data.aws_route53_zone.arcanum_existing.zone_id
#   name    = "app.${var.domain_name}"
#   type    = "A"

#   alias {
#     name                   = aws_lb.arcanum_alb01.dns_name
#     zone_id                = aws_lb.arcanum_alb01.zone_id
#     evaluate_target_health = true
#   }
# }
