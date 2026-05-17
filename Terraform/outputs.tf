# # outputs.tf (ROOT)

# output "private_subnet_ids" { value = module.network.arcanum_private_subnet_ids }

# output "vpc_id" { value = module.network.vpc_id }
output "alb_arn" { value = module.network.arcanum_alb_arn }



output "ec2_instance_id" { value = module.app_ec2.arcanum_instance_id }

# # EC2 is private; this will be null (expected)
# output "ec2_public_ip" { value = module.app_ec2.arcanum_public_ip }

# output "db_identifier" { value = module.database.arcanumdb_identifier }
# output "db_endpoint" { value = module.database.arcanum_db_endpoint }

# output "db_secret_arn" { value = module.database.arcanum_secret_arn }
# output "db_secret_name" { value = module.database.arcanum_secret_name }

# output "endpoint_ids" { value = module.endpoints.arcanum_endpoint_ids }

# output "log_group_name" { value = module.monitoring.arcanum_log_group_name }
# output "log_group_arn" { value = module.monitoring.arcanum_log_group_arn }

# output "network" {
#   value     = module.network
#   sensitive = true
# }

# output "monitoring" {
#   value = module.monitoring
# }

# output "security" {
#   value = module.security
# }

# output "database" {
#   value = module.database
# }

# output "app_ec2" {
#   value = module.app_ec2
# }

# output "iam" {
#   value = module.iam
# }

output "arcanum_route53_zone_id" {
  value = module.endpoints.arcanum_route53_zone_id
}

# output "arcanum_app_url_https" {
#   value = "https://${var.app_subdomain}.${var.domain_name}"
# }

# output "arcanum_apex_url_https" {
#   value = "https://${var.domain_name}"
# }

# output "arcanum_alb_logs_bucket_name" {
#   value = module.network.arcanum_alb_logs_bucket_name
# }

# output "arcanum_waf_log_destination" {
#   value = module.security.arcanum_waf_log_destination
# }

# output "arcanum_waf_cw_log_group_name" {
#   value = module.security.arcanum_waf_cw_log_group_name
# }

# output "arcanum_waf_logs_s3_bucket" {
#   value = module.security.arcanum_waf_logs_s3_bucket
# }

# output "arcanum_waf_firehose_name" {
#   value = module.security.arcanum_waf_firehose_name
# }

# output "arcanum_ir_reports_bucket" {
#   value = length(module.incident_reporter) > 0 ? module.incident_reporter[0].arcanum_ir_reports_bucket : null
# }

# output "arcanum_ir_lambda_function_name" {
#   value = length(module.incident_reporter) > 0 ? module.incident_reporter[0].arcanum_ir_lambda_function_name : null
# }

# output "arcanum_ir_mode" {
#   value = var.enable_bedrock_auto_ir ? var.auto_ir_mode : null
# }

# output "arcanum_ir_report_ready_topic_arn" {
#   value = length(module.incident_reporter) > 0 ? module.incident_reporter[0].arcanum_ir_report_ready_topic_arn : null
# }

output "arcanum_cf_distribution_id" {
  value = module.endpoints.arcanum_cf_distribution_id
}

output "arcanum_cf_domain_name" {
  value = module.endpoints.arcanum_cf_domain_name
}

# output "arcanum_alb_sg_id" {
#   description = "ALB security group ID from the network module"
#   value       = module.network.arcanum_alb_sg_id
# }

output "arcanum_app_fqdn" {
  description = "Fully qualified domain name for the application (e.g., app.example.com)"
  value       = module.endpoints.arcanum_app_fqdn
}