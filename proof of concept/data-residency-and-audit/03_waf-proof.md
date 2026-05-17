# 03 WAF Proof — Security Evidence

## Objective
Show that AWS WAF is deployed in front of CloudFront and that request evaluation is being logged.

## Verification commands
```bash
aws logs describe-log-groups \
  --log-group-name-prefix "aws-waf-logs-arcanum-cf-webacl01" \
  --region us-east-1

aws logs describe-log-streams \
  --log-group-name "aws-waf-logs-arcanum-cf-webacl01" \
  --order-by LastEventTime \
  --descending \
  --limit 5 \
  --region us-east-1

aws logs filter-log-events \
  --log-group-name "aws-waf-logs-arcanum-cf-webacl01" \
  --limit 20 \
  --region us-east-1
```

## Validation result
The WAF log group `aws-waf-logs-arcanum-cf-webacl01` exists in `us-east-1`, has a 14-day retention period, and contains stored log data. The active log stream `cloudfront_arcanum-cf-waf01_0` confirms that WAF logging is active.

Recent WAF events show:
- `httpSourceName` = `CF`
- `httpSourceId` = `E1WPGBH6FX7324`
- `action` = `ALLOW`
- `ruleGroupList` includes `AWSManagedRulesCommonRuleSet`

The captured events include both ordinary browser traffic and suspicious probe paths such as:
- `//wp-includes/wlwmanifest.xml`
- `//xmlrpc.php`

## Interpretation
This proves that WAF is deployed on the CloudFront edge, that requests are being evaluated by managed rules, and that security-relevant traffic is being logged in a durable, queryable destination.
