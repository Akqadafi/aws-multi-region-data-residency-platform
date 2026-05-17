output "saopaulo_tgw_id" {
  description = "Sao Paulo Transit Gateway ID for cross-region peering"
  value       = aws_ec2_transit_gateway.liberdade_tgw01.id
}

output "saopaulo_vpc_cidr" {
  description = "Sao Paulo VPC CIDR for cross-region routing"
  value       = module.network.vpc_cidr
}

output "saopaulo_instance_id" {
  description = "Sao Paulo EC2 instance ID"
  value       = module.app_ec2.arcanum_instance_id
}