############################################
# Bonus B - Route53 (Hosted Zone + DNS records + ACM validation + ALIAS to ALB)
############################################

data "aws_route53_zone" "arcanum_existing" {
  count        = var.manage_route53_in_terraform ? 0 : 1
  zone_id      = var.route53_hosted_zone_id
  private_zone = false
}

############################################
# Hosted Zone (optional creation)
############################################

# Explanation: A hosted zone is like claiming Kashyyyk in DNS. Names here become law.
resource "aws_route53_zone" "arcanum_zone01" {
  count = var.manage_route53_in_terraform ? 1 : 0
  name  = local.arcanum_zone_name

  tags = {
    Name = "${var.project_name}-zone01"
  }
}



