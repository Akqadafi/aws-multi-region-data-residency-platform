############################################
# CloudFront ACM DNS validation records
# Validates the us-east-1 CloudFront viewer cert
############################################

resource "aws_acm_certificate" "arcanum_cf_cert01" {
  provider          = aws.use1
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "${var.app_subdomain}.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "arcanum_cf_acm_validation_records01" {
  allow_overwrite = true

  for_each = {
    for dvo in aws_acm_certificate.arcanum_cf_cert01.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = local.arcanum_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "arcanum_cf_cert_validation01" {
  provider = aws.use1

  certificate_arn = aws_acm_certificate.arcanum_cf_cert01.arn

  validation_record_fqdns = [
    for r in aws_route53_record.arcanum_cf_acm_validation_records01 : r.fqdn
  ]
}

