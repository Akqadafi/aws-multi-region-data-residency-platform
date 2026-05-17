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
  source = "../../modules/network_spoke"

  project_name           = var.project_name
  vpc_cidr               = var.vpc_cidr
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  azs                    = var.azs
  enable_alb_access_logs = var.enable_alb_access_logs
  alb_access_logs_prefix = var.alb_access_logs_prefix
  tags                   = local.tags
  providers = {
    aws      = aws
    aws.use1 = aws.use1
  }
}

module "security" {
  source = "../../modules/security_spoke"

  project_name                     = var.project_name
  vpc_id                           = module.network.vpc_id
  alb_sg_id                        = module.network.arcanum_alb_sg_id
  alb_arn                          = module.network.arcanum_alb_arn
  enable_waf                       = true
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

module "app_ec2" {
  source = "../../modules/app_ec2"

  project_name           = var.project_name
  subnet_id              = module.network.arcanum_private_subnet_ids[0] # PRIVATE subnet
  ec2_security_group_id  = module.security.arcanum_ec2_sg_id
  ec2_instance_type      = var.ec2_instance_type
  ami_ssm_parameter_name = var.ami_ssm_parameter_name

  iam_instance_profile_name = aws_iam_instance_profile.liberdade_instance_profile_private.name

  associate_public_ip = false
  tags                = local.tags

}

data "aws_iam_policy_document" "liberdade_ec2_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "liberdade_ec2_role01" {
  name               = "liberdade-ec2-role01"
  assume_role_policy = data.aws_iam_policy_document.liberdade_ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "liberdade_ec2_ssm_attach" {
  role       = aws_iam_role.liberdade_ec2_role01.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "liberdade_instance_profile_private" {
  name = "liberdade-instance-profile-private"
  role = aws_iam_role.liberdade_ec2_role01.name
}

# module "iam" {
#   source = "../../modules/iam"

#   project_name             = var.project_name
#   aws_region               = var.aws_region
#   secret_arn_guess         = var.tokyo_secret_arn
#   cloudwatch_log_group_arn = var.saopaulo_log_group_arn
# }

resource "aws_lb_target_group_attachment" "arcanum_tg_attach01" {
  target_group_arn = module.network.arcanum_target_group_arn
  target_id        = module.app_ec2.arcanum_instance_id
  port             = 80
}

############################################
# Lab 3A - Sao Paulo TGW Spoke
############################################

resource "aws_ec2_transit_gateway" "liberdade_tgw01" {
  description = "liberdade-tgw01 (Sao Paulo spoke)"

  tags = {
    Name = "liberdade-tgw01"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "liberdade_attach_sp_vpc01" {
  transit_gateway_id = aws_ec2_transit_gateway.liberdade_tgw01.id
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.arcanum_private_subnet_ids

  tags = {
    Name = "liberdade-attach-sp-vpc01"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "liberdade_accept_peer01" {
  transit_gateway_attachment_id = var.tokyo_tgw_peering_attachment_id

  tags = {
    Name = "liberdade-accept-peer01"
  }
}

resource "aws_route" "liberdade_to_tokyo_route01" {
  route_table_id         = module.network.arcanum_private_route_table_id
  destination_cidr_block = var.tokyo_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.liberdade_tgw01.id
}

resource "aws_ec2_transit_gateway_route" "liberdade_to_tokyo_tgw_route01" {
  destination_cidr_block         = var.tokyo_vpc_cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway.liberdade_tgw01.association_default_route_table_id
  transit_gateway_attachment_id  = var.tokyo_tgw_peering_attachment_id
}