locals {
  # arcanum_prefix = "arc_bonus_a"
  # vpc_id         = aws_vpc.arcanum_vpc01.id
  # private_subnet = aws_subnet.arcanum_private_subnets[0].id
  # # For session manager endpoints, we'll use first private subnet
  # endpoint_subnets         = aws_subnet.arcanum_private_subnets[*].id
  # arcanum_secret_arn_guess = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.arcanum_self01.account_id}:secret:${local.arcanum_prefix}/rds/mysql*"
  tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

module "network" {
  source = "../../modules/network"

  project_name                = var.project_name
  vpc_cidr                    = var.vpc_cidr
  public_subnet_cidrs         = var.public_subnet_cidrs
  private_subnet_cidrs        = var.private_subnet_cidrs
  azs                         = var.azs
  manage_route53_in_terraform = var.manage_route53_in_terraform
  route53_hosted_zone_id      = var.route53_hosted_zone_id
  route53_zone_name           = var.route53_zone_name
  route53_zone_id             = module.endpoints.arcanum_route53_zone_id
  enable_alb_access_logs      = var.enable_alb_access_logs
  enable_origin_cloaking      = var.enable_origin_cloaking
  alb_access_logs_prefix      = var.alb_access_logs_prefix
  tags                        = local.tags
  providers = {
    aws      = aws
    aws.use1 = aws.use1
  }
}

module "security" {
  source = "../../modules/security"

  project_name                     = var.project_name
  vpc_id                           = module.network.vpc_id
  alb_sg_id                        = module.network.arcanum_alb_sg_id
  alb_arn                          = module.network.arcanum_alb_arn
  enable_waf                       = true
  enable_origin_cloaking           = var.enable_origin_cloaking
  waf_log_destination              = var.waf_log_destination
  waf_log_retention_days           = var.waf_log_retention_days
  enable_waf_sampled_requests_only = var.enable_waf_sampled_requests_only
  my_ip_cidr                       = var.my_ip_cidr
  tags                             = local.tags
  alb_security_group_id            = module.network.arcanum_alb_sg_id
  providers = {
    aws      = aws
    aws.use1 = aws.use1
  }

}

module "database" {
  source = "../../modules/database"

  project_name          = var.project_name
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.arcanum_private_subnet_ids
  rds_security_group_id = module.security.arcanum_rds_sg_id

  db_engine         = var.db_engine
  db_instance_class = var.db_instance_class
  storage_type      = var.storage_type
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password

  tags = local.tags
}

module "app_ec2" {
  source = "../../modules/app_ec2"

  project_name           = var.project_name
  subnet_id              = module.network.arcanum_private_subnet_ids[0] # PRIVATE subnet
  ec2_security_group_id  = module.security.arcanum_ec2_sg_id
  ec2_instance_type      = var.ec2_instance_type
  ami_ssm_parameter_name = var.ami_ssm_parameter_name

  iam_instance_profile_name = module.iam.instance_profile_name

  associate_public_ip = false
  tags                = local.tags

  # endpoints first, so SSM registration works in a private subnet
  depends_on = [module.endpoints]
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name       = var.project_name
  sns_email_endpoint = var.sns_email_endpoint
  alb_arn_suffix     = module.network.arcanum_alb_arn_suffix

  tags = local.tags
}

module "incident_reporter" {
  count  = var.enable_bedrock_auto_ir ? 1 : 0
  source = "../../modules/incident_reporter"

  project_name                       = var.project_name
  sns_topic_arn                      = module.monitoring.arcanum_sns_topic_arn
  app_log_group_name                 = module.monitoring.arcanum_log_group_name
  waf_log_group_name                 = lower(var.waf_log_destination) == "cloudwatch" ? module.security.arcanum_cf_waf_cw_log_group_name : null
  secret_id                          = module.database.arcanum_secret_name
  ssm_param_path                     = "/lab/db/"
  bedrock_model_id                   = var.bedrock_model_id
  auto_ir_mode                       = var.auto_ir_mode
  fast_report_window_minutes         = var.auto_ir_fast_window_minutes
  report_prefix                      = var.auto_ir_reports_prefix
  enable_separate_report_ready_topic = var.enable_separate_report_ready_topic
  report_ready_topic_arn             = var.report_ready_topic_arn
  report_ready_email_endpoint        = var.sns_email_endpoint
  tags                               = local.tags
}

module "endpoints" {
  source = "../../modules/endpoints"

  project_name                = var.project_name
  vpc_id                      = module.network.vpc_id
  private_subnet_ids          = module.network.arcanum_private_subnet_ids
  private_route_table_id      = module.network.arcanum_private_route_table_id
  vpce_security_group_id      = module.security.arcanum_vpce_sg_id
  aws_region                  = var.aws_region
  alb_dns_name                = module.network.arcanum_alb_dns_name
  cloudfront_waf_arn          = module.security.cloudfront_waf_arn
  manage_route53_in_terraform = var.manage_route53_in_terraform
  route53_hosted_zone_id      = var.route53_hosted_zone_id
  route53_zone_name           = var.route53_zone_name
  domain_name                 = var.domain_name
  app_subdomain               = var.app_subdomain
  enable_origin_cloaking      = var.enable_origin_cloaking
  origin_header_name          = module.network.origin_header_name
  origin_header_value         = module.network.origin_header_value
  providers = {
    aws      = aws
    aws.use1 = aws.use1
  }
  tags = local.tags
}

module "iam" {
  source = "../../modules/iam" # or wherever your iam module lives

  project_name             = var.project_name
  aws_region               = var.aws_region
  secret_arn_guess         = module.database.arcanum_secret_arn # OR a string var you set
  cloudwatch_log_group_arn = module.monitoring.arcanum_log_group_arn
}

resource "aws_lb_target_group_attachment" "arcanum_tg_attach01" {
  target_group_arn = module.network.arcanum_target_group_arn
  target_id        = module.app_ec2.arcanum_instance_id
  port             = 80
}


resource "aws_route" "shinjuku_to_sp_route01" {
  route_table_id         = module.network.arcanum_private_route_table_id
  destination_cidr_block = var.saopaulo_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.shinjuku_tgw01.id
}

resource "aws_ec2_transit_gateway" "shinjuku_tgw01" {
  description = "shinjuku-tgw01 (Tokyo hub)"

  tags = {
    Name = "shinjuku-tgw01"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "shinjuku_attach_tokyo_vpc01" {
  transit_gateway_id = aws_ec2_transit_gateway.shinjuku_tgw01.id
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.arcanum_private_subnet_ids

  tags = {
    Name = "shinjuku-attach-tokyo-vpc01"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment" "shinjuku_to_liberdade_peer01" {
  transit_gateway_id      = aws_ec2_transit_gateway.shinjuku_tgw01.id
  peer_region             = "sa-east-1"
  peer_transit_gateway_id = var.saopaulo_tgw_id

  tags = {
    Name = "shinjuku-to-liberdade-peer01"
  }
}

resource "aws_security_group_rule" "shinjuku_rds_ingress_from_liberdade01" {
  type              = "ingress"
  security_group_id = module.security.arcanum_rds_sg_id
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"

  cidr_blocks = [var.saopaulo_vpc_cidr]

  description = "Allow MySQL from Sao Paulo VPC over TGW"
}

resource "aws_ec2_transit_gateway_route" "shinjuku_to_saopaulo_tgw_route01" {
  destination_cidr_block         = var.saopaulo_vpc_cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway.shinjuku_tgw01.association_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.shinjuku_to_liberdade_peer01.id
}