# 01 Data Residency Proof — arcanum

## Objective
Prove that the database exists only in Tokyo and that São Paulo has no RDS instance.

## Verification commands
```bash
aws rds describe-db-instances --region ap-northeast-1 \
  --query "DBInstances[].{DB:DBInstanceIdentifier,AZ:AvailabilityZone,Region:'ap-northeast-1',Endpoint:Endpoint.Address}"

aws rds describe-db-instances --region sa-east-1 \
  --query "DBInstances[].DBInstanceIdentifier"
```

## Validation result
The Tokyo query returned database instance `arcanum-rds01` in `ap-northeast-1` with endpoint `arcanum-rds01.cdqyg4i0gz5f.ap-northeast-1.rds.amazonaws.com`.  
The São Paulo query returned an empty list `[]`.

## Interpretation
This proves that the authoritative database exists only in Tokyo and that no duplicate RDS database exists in São Paulo. That satisfies the core APPI-style residency requirement: global access may be allowed, but regulated storage remains in Japan.
