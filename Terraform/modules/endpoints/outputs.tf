output "arcanum_endpoint_ids" {
  value = {
    s3          = aws_vpc_endpoint.arcanum_vpce_s3_gw01.id
    ssm         = aws_vpc_endpoint.arcanum_vpce_ssm01.id
    ec2messages = aws_vpc_endpoint.arcanum_vpce_ec2messages01.id
    ssmmessages = aws_vpc_endpoint.arcanum_vpce_ssmmessages01.id
    logs        = aws_vpc_endpoint.arcanum_vpce_logs01.id
    secrets     = aws_vpc_endpoint.arcanum_vpce_secrets01.id
    # kms       = aws_vpc_endpoint.arcanum_vpce_kms01.id  # only if you actually created it
  }
}

output "arcanum_cf_distribution_id" {
  description = "CloudFront distribution ID"
  value       = try(aws_cloudfront_distribution.arcanum_cf01.id, null)
}

output "arcanum_cf_domain_name" {
  description = "CloudFront domain name"
  value       = try(aws_cloudfront_distribution.arcanum_cf01.domain_name, null)
}

output "arcanum_app_url_https" {
  description = "App HTTPS URL"
  value       = "https://${var.app_subdomain}.${var.domain_name}"
}

output "arcanum_apex_url_https" {
  description = "Apex HTTPS URL"
  value       = "https://${var.domain_name}"
}

output "arcanum_app_fqdn" {
  description = "App FQDN (e.g., app.arcanum-base.click)"
  value       = "${var.app_subdomain}.${var.domain_name}"
}

output "arcanum_route53_zone_id" {
  description = "Route53 hosted zone ID used for DNS records."
  value       = local.arcanum_zone_id
}

output "arcanum_zone_id" {
  value = local.arcanum_zone_id
}

output "arcanum_zone_name" {
  value = local.arcanum_zone_name
}