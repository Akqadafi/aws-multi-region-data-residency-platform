# 02 Edge Proof — CloudFront / Origin Protection

## Objective
Prove that public requests enter through CloudFront and that direct public access to the ALB origin is closed.

## Verification commands
```bash
curl -I https://arcanum-base.click/api/public-feed
curl -I https://app.arcanum-base.click/api/public-feed
```

```bash
curl -I http://arcanum-alb01-1373210956.ap-northeast-1.elb.amazonaws.com --connect-timeout 5
curl -k -I https://arcanum-alb01-1373210956.ap-northeast-1.elb.amazonaws.com --connect-timeout 5
```

```bash
aws ec2 describe-security-group-rules \
  --filters Name=group-id,Values=sg-015cc9c5d71a59501 \
  --region ap-northeast-1 \
  --query "SecurityGroupRules[].{RuleId:SecurityGroupRuleId,IsEgress:IsEgress,Protocol:IpProtocol,From:FromPort,To:ToPort,Cidr:CidrIpv4,PrefixList:PrefixListId,Description:Description}" \
  --output table
```

## Validation result
Requests to both public hostnames returned responses containing CloudFront headers such as `Via`, `X-Cache`, `X-Amz-Cf-Pop`, and `X-Amz-Cf-Id`, which proves that the public path traverses CloudFront.

Direct requests to the ALB hostname timed out over both HTTP and HTTPS, which shows that the origin is no longer publicly reachable and that direct internet access to the ALB has been closed.

The ALB security group now contains only:
- egress port 80 to targets
- ingress port 80 from managed prefix list `pl-58a04531` (`HTTP from CloudFront origin-facing only`)

No public ingress rules from `0.0.0.0/0` remain.

## CloudFront log evidence
CloudFront standard logs were delivered successfully to S3 under:

`AWSLogs/233781468925/CloudFront/cloudfront-logs/`

The latest log analysis found:
- Core total (Hit/Miss/RefreshHit): 1
- Miss: 1
- Other:Error: 18

This matches the observed edge tests: traffic reached CloudFront successfully, but the tested path returned 404/error outcomes rather than cached success objects.

## Interpretation
This proves that CloudFront is the public edge, that direct ALB access is closed, and that CloudFront request activity is being durably recorded in S3 for audit purposes.
