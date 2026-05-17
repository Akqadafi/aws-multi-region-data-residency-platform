# Lab 3B Screenshot Verification Index

This index explains what each kept screenshot proves for Lab 3B verification.

---

## Lab 3B — Data Residency / Audit / Edge Proof

### `3B_01_tokyo_rds_exists.png`

**What it proves**

* The authoritative RDS database exists in **Tokyo**
* Tokyo is the storage region for regulated application data

### `3B_01_saopaulo_no_rds.png`

**What it proves**

* São Paulo has **no RDS instance**
* There is no duplicate database in the compute region
* Strong proof for Tokyo-only storage residency, matching the data-residency objective

---

## Lab 3B — CloudFront Edge / Origin Protection

### `3B_02_cloudfront_cache_miss_then_refreshhit.png`

**What it proves**

* Public traffic is reaching **CloudFront**
* `X-Cache` behavior shows CloudFront edge handling rather than direct origin access
* Strong proof that CloudFront is functioning as the public edge layer

### `3B_02_cloudfront_invalidation_created.png`

**What it proves**

* A CloudFront invalidation request was created successfully
* Edge cache refresh behavior is being managed intentionally
* This supports the edge-control and logging claims in the Lab 3B validation evidence

---

## Lab 3B — WAF Security Proof

### `3B_03_waf_web_acl_exists.png`

**What it proves**

* A CloudFront-scoped **Web ACL** exists
* Edge protection is not merely conceptual; a real WAF object is deployed
* Managed rule protection is configured on the public edge

### `3B_03_waf_logging_enabled.png`

**What it proves**

* WAF logging is enabled
* The Web ACL is writing to a real logging destination
* Security evaluation is durable and queryable, not transient only

### `3B_03_waf_log_events.png`

**What it proves**

* Real WAF events are present in logs
* Requests are being evaluated at the **CloudFront** edge
* Managed-rule processing and request logging are active in production traffic

---

## Lab 3B — CloudTrail Change Proof

### `3B_04_cloudtrail_sg_change.png`

**What it proves**

* CloudTrail recorded security-group changes
* The actor, time, and API event are visible
* This is strong “who changed what” evidence for origin-hardening work

### `3B_04_cloudtrail_tgw_create_peering_attachment.png`

**What it proves**

* CloudTrail recorded creation of the TGW peering attachment
* The corridor was deliberately built through AWS control-plane actions
* This supports the controlled-corridor interpretation

### `3B_04_cloudtrail_tgw_accept_peering_attachment.png`

**What it proves**

* CloudTrail recorded acceptance of the TGW peering attachment
* The cross-region corridor was not accidental or inferred; it was explicitly accepted on the receiving side

### `3B_04_cloudtrail_tgw_create_route.png`

**What it proves**

* CloudTrail recorded creation of TGW routes
* Remote CIDR routing was intentionally added through management events
* This is the control-plane counterpart to the route-table runtime proof

### `3B_04_cloudtrail_waf_associate_web_acl.png`

**What it proves**

* CloudTrail recorded association of the Web ACL
* WAF attachment to the protected edge path was an explicit management action

### `3B_04_cloudtrail_waf_put_logging_configuration.png`

**What it proves**

* CloudTrail recorded WAF logging configuration changes
* Security telemetry was deliberately enabled, not just observed later

### `3B_04_cloudtrail_cloudfront_update_distribution.png`

**What it proves**

* CloudTrail recorded CloudFront distribution updates
* Edge behavior and public delivery posture were changed through traceable management events
* This contributes to a regulator-ready management-event trail

---

## Lab 3B — Supporting Logs / Retention / Integrity Controls

### `3B_05_log_and_audit_buckets_exist.png`

**What it proves**

* The log bucket and audit bucket both exist
* Dedicated storage locations are present for operational and audit evidence

### `3B_05_log_bucket_prefixes_exist.png`

**What it proves**

* Required prefixes for CloudFront, CloudTrail, WAF, and audit-pack storage exist
* The logging layout is organized and ready for evidence collection

### `3B_05_cloudtrail_objects_in_s3.png`

**What it proves**

* CloudTrail objects are actually landing in S3
* The trail is delivering durable artifacts, not merely configured on paper

### `3B_05_bucket_versioning_and_encryption.png`

**What it proves**

* Versioning is enabled on the audit-relevant buckets
* Default AES256 encryption is enabled
* Retention posture and basic storage hardening are in place

### `3B_05_cloudtrail_enabled_multiregion_validation_on.png`

**What it proves**

* CloudTrail is enabled
* The trail is **multi-Region**
* Log file validation is turned on

### `3B_05_cloudtrail_log_validation_success.png`

**What it proves**

* CloudTrail digest validation succeeded
* Audit logs can be integrity-checked
* This is the strongest proof that the logging chain is suitable for audit review

---

## Summary

### Lab 3B audit proof

* Storage remains in Tokyo and not in São Paulo
* Public access is forced through CloudFront
* WAF exists, logs, and evaluates real traffic
* CloudTrail records who changed SGs, TGW, WAF, and CloudFront
* S3 versioning, encryption, and CloudTrail digest validation provide retention and integrity controls

---

## Optional / Archive Screenshots

These are useful as backup evidence but are not required in the lean final Lab 3B set:

* repeated CloudFront `RefreshHit` screenshots
* extra WAF event crops
* extra SG-change CloudTrail crops
* extra TGW route/create-event crops
* partial or duplicate terminal crops
