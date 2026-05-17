# Lab 3B Verification Report

## Purpose of Verification

This report documents the audit, edge, logging, and data-residency evidence collected for Lab 3B. Lab 3B focuses on proving that storage remains in Tokyo, public access is controlled at the edge, security controls are logged, and management changes are traceable.

---

## 1. Data Residency Validation

### Tokyo-only storage

The Tokyo RDS instance `arcanum-rds01` in `ap-northeast-1` was verified as available and private, with endpoint:

`arcanum-rds01.cdqyg4i0gz5f.ap-northeast-1.rds.amazonaws.com:3306`

### No database in São Paulo

The São Paulo RDS query returned an empty list `[]`.

## Interpretation

This proves that the authoritative database exists only in Tokyo and that São Paulo does not host a duplicate database. That is the core Lab 3B residency claim.

---

## 2. CloudFront Edge Validation

Public requests were verified against the public domain and app domain, and CloudFront-specific caching behavior was observed.

## Validation result

- CloudFront handled public traffic.
- `X-Cache` states showed edge behavior such as `Miss` and `RefreshHit`.
- Invalidation activity was created and verified.

## Interpretation

This proves that CloudFront is functioning as the public edge layer and that cache lifecycle behavior is visible and controlled.

---

## 3. WAF Validation

Lab 3B also required proof that WAF was deployed and logging traffic.

## Validation result

- A CloudFront-scoped Web ACL existed.
- WAF logging was enabled.
- Real WAF log events were returned from the log destination.
- Logged requests showed CloudFront as the source and included managed-rule evaluation.

## Interpretation

This proves that edge requests are being inspected and durably logged by AWS WAF.

---

## 4. CloudTrail Change Validation

Lab 3B required proof of “who changed what” for the edge, routing, and security control plane.

## Validation result

CloudTrail event-history evidence was collected for:

- security-group changes
- TGW peering creation and acceptance
- TGW route creation
- WAF association
- WAF logging configuration
- CloudFront distribution updates

## Interpretation

This provides regulator-ready management-event evidence showing who changed key components, when the changes happened, and which AWS service APIs were involved.

---

## 5. Supporting Logs and Audit Controls

Lab 3B also required durable evidence and integrity controls.

## Validation result

- Dedicated log and audit buckets existed.
- Expected prefixes existed for CloudFront, CloudTrail, WAF, and the audit pack.
- CloudTrail objects were present in S3.
- Bucket versioning and AES256 default encryption were enabled.
- CloudTrail was enabled as a multi-Region trail.
- CloudTrail digest validation succeeded.

## Interpretation

These controls show that the environment produces durable evidence and that the logging chain can be integrity-checked for audit use.

---

## 6. Auditor Narrative Alignment

The auditor narrative for Lab 3B argues that the design is APPI-minded because storage remains in Tokyo while access can be global and compute can operate outside Japan in a controlled way.

The technical evidence supports that claim:

- storage remains in Tokyo
- São Paulo has no database
- CloudFront is the public edge
- WAF protects and logs edge traffic
- CloudTrail records management changes
- S3 and CloudTrail validation provide durable audit evidence

---

## Final Conclusion

Lab 3B was successfully verified.

- Data residency was preserved in Tokyo
- CloudFront served as the public edge
- WAF existed, logged traffic, and evaluated requests
- CloudTrail recorded key management changes
- Supporting S3 and CloudTrail controls provided retention and integrity evidence

This confirms the intended Lab 3B model: controlled global access, Tokyo-only authoritative storage, and an auditor-ready chain of security and logging evidence.
