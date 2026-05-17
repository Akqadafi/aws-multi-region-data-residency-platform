output "arcanum_ec2_sg_id" { value = aws_security_group.arcanum_ec2_sg01.id }
output "arcanum_rds_sg_id" { value = aws_security_group.arcanum_rds_sg01.id }
output "arcanum_vpce_sg_id" {
  value = aws_security_group.arc_bonus_a_vpce_sg01.id
}
# output "arcanum_waf_arn" {
#   value = "${length(aws_wafv2_web_acl.arcanum_waf01) > 0 ? aws_wafv2_web_acl.arcanum_waf01[0].arn : null}"
# }

output "arcanum_waf_arn" {
  value = length(aws_wafv2_web_acl.arcanum_waf01) > 0 ? aws_wafv2_web_acl.arcanum_waf01[0].arn : null
}

output "arcanum_waf_log_destination" {
  value = var.waf_log_destination
}

output "arcanum_waf_cw_log_group_name" {
  value = lower(var.waf_log_destination) == "cloudwatch" && length(aws_cloudwatch_log_group.arcanum_waf_log_group01) > 0 ? aws_cloudwatch_log_group.arcanum_waf_log_group01[0].name : null
}

output "arcanum_waf_logs_s3_bucket" {
  value = lower(var.waf_log_destination) == "s3" && length(aws_s3_bucket.arcanum_waf_logs_bucket01) > 0 ? aws_s3_bucket.arcanum_waf_logs_bucket01[0].bucket : null
}

output "arcanum_waf_firehose_name" {
  value = lower(var.waf_log_destination) == "firehose" && length(aws_kinesis_firehose_delivery_stream.arcanum_waf_firehose01) > 0 ? aws_kinesis_firehose_delivery_stream.arcanum_waf_firehose01[0].name : null
}


# output "cloudfront_waf_arn" {
#   description = "ARN of the CloudFront WAF web ACL"
#   value       = aws_wafv2_web_acl.arcanum_cf_waf01.arn
# }

output "cloudfront_waf_arn" {
  value = var.enable_waf && var.enable_origin_cloaking ? aws_wafv2_web_acl.arcanum_cf_waf01[0].arn : null
}

output "arcanum_cf_waf_cw_log_group_name" {
  value = var.enable_waf && var.enable_origin_cloaking && var.waf_log_destination == "cloudwatch" ? aws_cloudwatch_log_group.arcanum_cf_waf_log_group01[0].name : null
}


# output "origin_header_name" {
#   value = local.origin_header_name
# }

# output "origin_header_value" {
#   value     = random_password.origin_header_value.result
#   sensitive = true
# }

