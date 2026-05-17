# 00 Architecture Summary — arcanum Lab 3B

## Objective

This lab demonstrates an APPI-minded cross-region design where regulated storage remains in Tokyo while application compute can operate in São Paulo. The goal is not only that the system works, but that the design can be proven to an auditor through durable evidence.

## Region roles

### Tokyo (`ap-northeast-1`) — authoritative region
- VPC CIDR: `10.10.0.0/16`
- RDS identifier: `arcanum-rds01`
- RDS endpoint: `arcanum-rds01.cdqyg4i0gz5f.ap-northeast-1.rds.amazonaws.com`
- TGW: `tgw-0f43bb3559a4397f3`
- TGW route table: `tgw-rtb-048aa07338bfff225`
- CloudFront distribution: `E1WPGBH6FX7324`
- WAF log group: `aws-waf-logs-arcanum-cf-webacl01`

### São Paulo (`sa-east-1`) — compute-only region
- VPC CIDR: `10.20.0.0/16`
- EC2 application instance: `i-037f9efb34d4e6454`
- TGW: `tgw-07cf5b59d76c3556c`
- TGW route table: `tgw-rtb-01970b7ad46d3c115`

## Controlled corridor

Tokyo and São Paulo are connected through TGW peering attachment `tgw-attach-087be19171b508a2f`.  
The Tokyo private route table sends `10.20.0.0/16` to the Tokyo TGW.  
The São Paulo private route table sends `10.10.0.0/16` to the São Paulo TGW.  
Both TGW route tables include static routes for the remote CIDR through the peering attachment.

## Edge posture

Public access enters through CloudFront.  
The ALB security group now permits ingress only from the CloudFront origin-facing managed prefix list `pl-58a04531` and no longer permits public ingress from `0.0.0.0/0`.

## Audit evidence sources

- Data residency: RDS API evidence
- Edge access: CloudFront headers and CloudFront standard logs in S3
- WAF proof: CloudWatch Logs in `us-east-1`
- Change trail: CloudTrail multi-Region trail
- Retention / integrity: versioned and encrypted S3 buckets plus CloudTrail digest validation

## Auditor takeaway

This architecture separates **global access** from **global storage**. The application can run in São Paulo, but the database remains in Tokyo, and each critical claim is backed by logs, CLI evidence, or management-event history.
