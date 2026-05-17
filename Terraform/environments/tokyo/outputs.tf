output "tokyo_vpc_cidr" {
  value = module.network.vpc_cidr
}

output "tokyo_tgw_id" {
  value = aws_ec2_transit_gateway.shinjuku_tgw01.id
}

output "tokyo_tgw_peering_attachment_id" {
  value = aws_ec2_transit_gateway_peering_attachment.shinjuku_to_liberdade_peer01.id
}

output "tokyo_rds_endpoint" {
  value = module.database.arcanum_db_endpoint
}