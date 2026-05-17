
locals {
  interface_services = [
    "com.amazonaws.${var.aws_region}.ssm",
    "com.amazonaws.${var.aws_region}.ec2messages",
    "com.amazonaws.${var.aws_region}.ssmmessages",
    "com.amazonaws.${var.aws_region}.logs",
    "com.amazonaws.${var.aws_region}.secretsmanager"
  ]
}




# ############################################
# # VPC Endpoint - S3 (Gateway)
# ############################################

resource "aws_vpc_endpoint" "arcanum_vpce_s3_gw01" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.private_route_table_id]

  tags = merge(var.tags, { Name = "${var.project_name}-vpce-s3-gw01" })
}

resource "aws_vpc_endpoint" "arcanum_vpce_ssm01" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.vpce_security_group_id]
  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.project_name}-vpce-ssm01" })
}

resource "aws_vpc_endpoint" "arcanum_vpce_ec2messages01" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.vpce_security_group_id]
  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.project_name}-vpce-ec2messages01" })
}

resource "aws_vpc_endpoint" "arcanum_vpce_ssmmessages01" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.vpce_security_group_id]
  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.project_name}-vpce-ssmmessages01" })
}

resource "aws_vpc_endpoint" "arcanum_vpce_logs01" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.vpce_security_group_id]
  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.project_name}-vpce-logs01" })
}

resource "aws_vpc_endpoint" "arcanum_vpce_secrets01" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.vpce_security_group_id]
  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.project_name}-vpce-secrets01" })
}
