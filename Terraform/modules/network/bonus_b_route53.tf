############################################
# Bonus B - Route53 (Hosted Zone + DNS records + ACM validation + ALIAS to ALB)
############################################

data "aws_route53_zone" "arcanum_existing" {
  count        = var.manage_route53_in_terraform ? 0 : 1
  zone_id      = var.route53_hosted_zone_id
  private_zone = false
}



# ############################################
# # ACM DNS Validation Records
# ############################################

# # Explanation: ACM asks for proof of domain ownership. DNS records provide that proof.
# resource "aws_route53_record" "arcanum_acm_validation_records01" {
#   allow_overwrite = true

#   for_each = upper(var.certificate_validation_method) == "DNS" ? {
#     for dvo in aws_acm_certificate.arcanum_acm_cert01.domain_validation_options :
#     dvo.domain_name => {
#       name   = dvo.resource_record_name
#       type   = dvo.resource_record_type
#       record = dvo.resource_record_value
#     }
#   } : {}

#   zone_id = local.arcanum_zone_id
#   name    = each.value.name
#   type    = each.value.type
#   ttl     = 60
#   records = [each.value.record]
# }

# # Explanation: This ties proof records back to ACM so the certificate can become ISSUED.
# resource "aws_acm_certificate_validation" "arcanum_acm_validation01_dns_bonus" {
#   count = upper(var.certificate_validation_method) == "DNS" ? 1 : 0

#   certificate_arn = aws_acm_certificate.arcanum_acm_cert01.arn
#   validation_record_fqdns = [
#     for r in aws_route53_record.arcanum_acm_validation_records01 : r.fqdn
#   ]
# }

############################################
# ALIAS record: app.arcanum-base.click -> ALB
############################################


# # Explanation: app subdomain points at the ALB.
# resource "aws_route53_record" "arcanum_app_alias01" {
#   count   = var.enable_origin_cloaking ? 0 : 1
#   zone_id = local.arcanum_zone_id
#   name    = local.arcanum_app_fqdn
#   type    = "A"

#   alias {
#     name                   = aws_lb.arcanum_alb01.dns_name
#     zone_id                = aws_lb.arcanum_alb01.zone_id
#     evaluate_target_health = true
#   }
# }

# # app -> ALB
# resource "aws_route53_record" "arcanum_app_to_alb" {
#   zone_id = data.aws_route53_zone.arcanum_existing.zone_id
#   name    = "app.${var.domain_name}"
#   type    = "A"

#   alias {
#     name                   = aws_lb.arcanum_alb01.dns_name
#     zone_id                = aws_lb.arcanum_alb01.zone_id
#     evaluate_target_health = true
#   }
# }