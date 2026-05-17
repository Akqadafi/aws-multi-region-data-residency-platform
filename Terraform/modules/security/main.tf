locals {
  ports_http     = 80
  ports_ssh      = 22
  db_port        = 3306
  tcp_protocol   = "tcp"
  all_ip_address = "0.0.0.0/0"
  all_protocol   = "-1"
}

resource "aws_security_group" "arcanum_ec2_sg01" {
  name        = "${var.project_name}-ec2-sg01"
  description = "EC2 app security group"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2-sg01"
  })
}

resource "aws_vpc_security_group_ingress_rule" "arcanum_ec2_sg_ingress_http" {
  ip_protocol       = local.tcp_protocol
  security_group_id = aws_security_group.arcanum_ec2_sg01.id
  from_port         = local.ports_http
  to_port           = local.ports_http
  cidr_ipv4         = local.all_ip_address
}


# resource "aws_vpc_security_group_ingress_rule" "arcanum_ec2_sg_ingress_ssh" {
#   ip_protocol       = local.tcp_protocol
#   security_group_id = aws_security_group.arcanum_ec2_sg01.id
#   from_port         = local.ports_ssh
#   to_port           = local.ports_ssh
#   cidr_ipv4         = var.my_ip_cidr
# }

resource "aws_vpc_security_group_egress_rule" "arcanum_ec2_sg_egress_all" {
  ip_protocol       = local.all_protocol
  security_group_id = aws_security_group.arcanum_ec2_sg01.id
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = local.all_ip_address
}

resource "aws_security_group" "arcanum_rds_sg01" {
  name        = "${var.project_name}-rds-sg01"
  description = "RDS security group"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-rds-sg01"
  })
}

resource "aws_vpc_security_group_ingress_rule" "arcanum_rds_sg_ingress_mysql" {
  ip_protocol                  = local.tcp_protocol
  security_group_id            = aws_security_group.arcanum_rds_sg01.id
  from_port                    = local.db_port
  to_port                      = local.db_port
  referenced_security_group_id = aws_security_group.arcanum_ec2_sg01.id
}

resource "aws_vpc_security_group_egress_rule" "arcanum_rds_sg_egress_all" {
  ip_protocol       = local.all_protocol
  security_group_id = aws_security_group.arcanum_rds_sg01.id
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = local.all_ip_address
}

# ############################################
# Security Group for VPC Interface Endpoints
# ############################################

resource "aws_security_group" "arc_bonus_a_vpce_sg01" {
  name_prefix = "${var.project_name}-vpce-sg01"
  description = "SG for VPC Interface Endpoints"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "arcanum_vpce_sg_ingress_https_from_ec2" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.arc_bonus_a_vpce_sg01.id
  source_security_group_id = aws_security_group.arcanum_ec2_sg01.id
}

resource "aws_security_group_rule" "arcanum_vpce_sg_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.arc_bonus_a_vpce_sg01.id
  description       = "Allow all outbound - endpoints receive only"
}

############################################
# Security Group: ALB
############################################

# Explanation: arcanum only opens the hangar door — allow ALB -> EC2 on app port (80).
resource "aws_security_group_rule" "arcanum_ec2_ingress_from_alb01" {
  type                     = "ingress"
  security_group_id        = aws_security_group.arcanum_ec2_sg01.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = var.alb_sg_id
}

############################################
# WAF (ALB-scoped) — Lab1. Lab2 moves WAF to CloudFront.
############################################

resource "aws_wafv2_web_acl" "arcanum_waf01" {
  count = var.enable_waf && !var.enable_origin_cloaking ? 1 : 0

  name  = "${var.project_name}-waf01"
  scope = "REGIONAL"

  default_action {
    allow {
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-waf01"
    sampled_requests_enabled   = true
  }

  # Starter managed rule set
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {
      }
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_web_acl_association" "arcanum_waf_assoc01" {
  count        = var.enable_waf && !var.enable_origin_cloaking ? 1 : 0
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.arcanum_waf01[0].arn
}


