output "arcanum_ec2_sg_id" { value = aws_security_group.arcanum_ec2_sg01.id }
output "arcanum_vpce_sg_id" {
  value = aws_security_group.arc_bonus_a_vpce_sg01.id
}

output "arcanum_waf_log_destination" {
  value = var.waf_log_destination
}








