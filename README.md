# Lab 3 — Cross-Region Compute, Tokyo Data Residency, and Audit Evidence

## Overview

Lab 3 is the most advanced project in this portfolio. It combines runtime architecture, cross-region networking, and audit-style validation.

The design keeps authoritative storage in **Tokyo** while allowing application compute in **São Paulo**, connected through a controlled Transit Gateway corridor. The lab then proves the design through runtime checks, route validation, WAF and CloudFront evidence, and CloudTrail-based change history.

## Objectives

* keep database storage in Tokyo
* run application compute in São Paulo without duplicating the database there
* connect the two regions through a controlled TGW peering corridor
* prove that São Paulo can reach the Tokyo database at both the network and app level
* document the environment in a way that would make sense to an auditor or reviewer

## Region Roles

### Tokyo (`ap-northeast-1`)

Tokyo is the **authoritative region**.

It contains:

* the primary VPC for the storage side of the design
* the RDS database
* a TGW participating in the cross-region corridor
* the infrastructure outputs São Paulo consumes through remote state

### São Paulo (`sa-east-1`)

São Paulo is the **compute-only region**.

It contains:

* the application EC2 instance
* a VPC peered into the Tokyo corridor through TGW
* route and security-group logic needed to reach Tokyo storage
* no duplicate RDS instance

## Architecture Summary

At a high level, the design works like this:

* Tokyo hosts the database and acts as the authoritative storage region
* São Paulo hosts application compute only
* a TGW peering attachment creates the legal and technical corridor between regions
* route tables in both regions explicitly send remote CIDRs through TGW
* São Paulo reaches the Tokyo database over that corridor
* public edge traffic is supported by CloudFront and WAF
* CloudTrail, S3 logging, and validation evidence support auditability

## Lab 3A vs Lab 3B

This lab naturally splits into two parts.

### Lab 3A — Runtime / Infrastructure Wiring Proof

Lab 3A focuses on whether the architecture actually works.

Key proof items:

* São Paulo EC2 can reach Tokyo RDS on port 3306
* São Paulo app can submit a record
* Tokyo app can read that same record
* each region’s route tables include the remote CIDR pointing to TGW
* Tokyo exports infrastructure outputs that São Paulo consumes via remote state

### Lab 3B — Audit / Regulator-Style Proof

Lab 3B focuses on whether the environment can be explained and defended through evidence.

Key proof items:

* Tokyo-only database residency
* CloudFront edge behavior
* WAF deployment and WAF log evidence
* CloudTrail “who changed what” evidence
* S3 log retention, encryption, versioning, and CloudTrail log validation
* architecture summary, proof files, evidence JSON, and auditor narrative

## What This Lab Demonstrates

This lab demonstrates that I can:

* design across multiple AWS regions with clear role separation
* preserve data residency while still enabling cross-region application access
* build and validate TGW-based routing rather than ad hoc connectivity
* reason about runtime proof and audit proof as separate but connected deliverables
* create evidence that supports technical claims with screenshots, CLI output, and written validation files

```

## Why It Matters

Lab 3 is important because it shows more than deployment. It shows design intent, control boundaries, runtime validation, and evidence discipline. It combines cloud engineering, security posture, and technical documentation in a way that is much closer to real-world review and audit expectations.

## Key Takeaway

Lab 3 shows my ability to build a cross-region AWS architecture that preserves Tokyo as the authoritative storage region, enables São Paulo application access through a controlled TGW corridor, and backs every major claim with audit-style evidence.

