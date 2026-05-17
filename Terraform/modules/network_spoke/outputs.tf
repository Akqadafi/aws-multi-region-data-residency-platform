output "vpc_id" { value = aws_vpc.arcanum_vpc01.id }

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.arcanum_vpc01.cidr_block
}

output "arcanum_alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.arcanum_alb01.arn
}

output "arcanum_alb_sg_id" {
  description = "ALB security group ID"
  value       = aws_security_group.arcanum_alb_sg01.id
}

output "arcanum_alb_arn_suffix" {
  value = aws_lb.arcanum_alb01.arn_suffix
}

output "arcanum_target_group_arn" {
  description = "Target group ARN for the ALB forward action"
  value       = aws_lb_target_group.arcanum_tg01.arn
}

output "arcanum_alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.arcanum_alb01.dns_name
}

output "arcanum_alb_zone_id" {
  description = "ALB hosted zone ID (for Route53 alias records)"
  value       = aws_lb.arcanum_alb01.zone_id
}

output "arcanum_public_subnet_ids" { value = aws_subnet.arcanum_public_subnets[*].id }
output "arcanum_private_subnet_ids" { value = aws_subnet.arcanum_private_subnets[*].id }
output "arcanum_nat_gateway_id" { value = aws_nat_gateway.arcanum_nat01.id }
output "arcanum_private_route_table_id" {
  value = aws_route_table.arcanum_private_rt01.id
}

output "arcanum_http_listener_arn" {
  description = "HTTP listener ARN"
  value       = aws_lb_listener.arcanum_http_listener01.arn
}


# output "arcanum_waf_arn" {
#   value = "${length(aws_wafv2_web_acl.arcanum_waf01) > 0 ? aws_wafv2_web_acl.arcanum_waf01[0].arn : null}"
# }


output "arcanum_target_group_name" {
  description = "Target group name"
  value       = aws_lb_target_group.arcanum_tg01.name
}



output "arcanum_alb_logs_bucket_name" {
  description = "ALB access logs S3 bucket name."
  value       = var.enable_alb_access_logs ? local.arcanum_alb_logs_bucket_name : null
}



