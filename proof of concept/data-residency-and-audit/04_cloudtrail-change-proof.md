# 04 CloudTrail Change Proof — Who Changed What

## Objective
Show who changed logging, edge controls, and security-relevant configuration.

## Verification commands
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=ModifySecurityGroupRules \
  --region ap-northeast-1 \
  --max-results 10 \
  --query 'Events[].{Time:EventTime,User:Username,Event:EventName,Source:EventSource,Id:EventId}' \
  --output table

aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=RevokeSecurityGroupIngress \
  --region ap-northeast-1 \
  --max-results 10 \
  --query 'Events[].{Time:EventTime,User:Username,Event:EventName,Source:EventSource,Id:EventId}' \
  --output table
```

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateTrail \
  --region ap-northeast-1 \
  --max-results 10 \
  --query 'Events[].{Time:EventTime,User:Username,Event:EventName,Source:EventSource,Id:EventId}' \
  --output table

aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=UpdateTrail \
  --region ap-northeast-1 \
  --max-results 10 \
  --query 'Events[].{Time:EventTime,User:Username,Event:EventName,Source:EventSource,Id:EventId}' \
  --output table
```

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=PutDeliverySource \
  --region us-east-1 \
  --max-results 10 \
  --query 'Events[].{Time:EventTime,User:Username,Event:EventName,Source:EventSource,Id:EventId}' \
  --output table

aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=PutDeliveryDestination \
  --region us-east-1 \
  --max-results 10 \
  --query 'Events[].{Time:EventTime,User:Username,Event:EventName,Source:EventSource,Id:EventId}' \
  --output table

aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateDelivery \
  --region us-east-1 \
  --max-results 10 \
  --query 'Events[].{Time:EventTime,User:Username,Event:EventName,Source:EventSource,Id:EventId}' \
  --output table
```

## Validation result
CloudTrail recorded multiple `ModifySecurityGroupRules` and `RevokeSecurityGroupIngress` events through `ec2.amazonaws.com`, initiated by user `AWSCLI`, corresponding to ALB hardening and direct-origin closure.

CloudTrail also recorded:
- `CreateTrail`
- `UpdateTrail`

through `cloudtrail.amazonaws.com`, proving that the audit trail itself was deliberately created and hardened.

In `us-east-1`, CloudTrail recorded:
- `PutDeliverySource`
- `PutDeliveryDestination`
- `CreateDelivery`

through `logs.amazonaws.com`, proving that CloudFront-to-S3 access logging was explicitly configured.

Additional `PutBucketPolicy` events through `s3.amazonaws.com` show that supporting bucket permissions were also changed as part of the logging control-plane setup.

## Interpretation
This gives a regulator-ready management-event trail showing who changed the environment, when the changes occurred, and which AWS services were involved.
