# Lab 3A Verification Report

## Purpose of Verification

This report documents the runtime and infrastructure evidence for the Lab 3A cross-region application design. Lab 3A focuses on proving that São Paulo compute can use the authoritative Tokyo database through a controlled Transit Gateway corridor, while the repo structure and outputs support that design.

---

## 1. Core Lab 3A Objective

Lab 3A was designed to prove five engineering truths:

1. São Paulo EC2 can reach the Tokyo RDS endpoint on port 3306.
2. The São Paulo application can submit a record.
3. The Tokyo application can read the same record, proving one shared database.
4. Route tables in both regions send the remote CIDR through Transit Gateway.
5. Tokyo exports the values São Paulo needs for cross-region wiring.

---

## 2. Network Reachability from São Paulo EC2 to Tokyo RDS

The assignment required verification from a São Paulo EC2 Systems Manager session that the Tokyo RDS endpoint was reachable on port 3306.

The successful command was:

```bash
nc -zv arcanum-rds01.cdqyg4i0gz5f.ap-northeast-1.rds.amazonaws.com 3306
```

## Validation result

- The Tokyo RDS hostname resolved successfully.
- The connection succeeded to the Tokyo database endpoint on port 3306.
- A second raw socket test using Bash `/dev/tcp` also returned `CONNECTED`.

## Interpretation

This proves that the São Paulo compute tier can reach the Tokyo database over the intended cross-region corridor.

---

## 3. App-Level Verification: One Shared Database

The assignment required a write in São Paulo and a confirming read from the Tokyo side.

### 3.1 São Paulo app write

From the São Paulo EC2 host, the application successfully initialized the database and inserted a note:

```bash
curl http://localhost/init
curl "http://localhost/add?note=lab3-saopaulo-test"
curl http://localhost/list
```

## Validation result

- `/init` returned: `Initialized arcdb + notes table.`
- `/add` returned: `Inserted note: lab3-saopaulo-test`
- `/list` returned the record in the HTML output.

### 3.2 Tokyo app read

From the Tokyo EC2 host, the application was queried for the same note:

```bash
curl http://localhost/list | grep "lab3-saopaulo-test"
```

## Validation result

- The Tokyo-side query returned the same `lab3-saopaulo-test` record.

## Interpretation

This is the strongest application-level proof in Lab 3A. São Paulo wrote the note, and Tokyo read the same note, which proves both regional application hosts are using the same authoritative Tokyo database rather than separate regional storage.

---

## 4. Route Verification

The assignment required route verification in both regions using AWS CLI.

### 4.1 São Paulo VPC route table

The São Paulo VPC route table was queried and verified to contain:

- `10.10.0.0/16` -> `tgw-07cf5b59d76c3556c`

This shows Tokyo-bound traffic is sent to the São Paulo TGW.

### 4.2 Tokyo VPC route table

The Tokyo VPC route table was queried and verified to contain:

- `10.20.0.0/16` -> `tgw-0f43bb3559a4397f3`

This shows São Paulo-bound return traffic is sent to the Tokyo TGW.

## Interpretation

Together, these route-table proofs show that both VPCs are explicitly configured to use Transit Gateway for the remote CIDR, satisfying the corridor-routing requirement of Lab 3A.

---

## 5. Repo Structure Deliverable

The assignment suggested a repo split like this:

- `/tokyo/` = Lab 2 plus marginal TGW hub code
- `/saopaulo/` = Lab 2 minus DB plus TGW spoke code

## Validation result

This structure was met functionally:

- The Tokyo side contains the Tokyo VPC, private RDS, TGW, TGW attachment, peering creation, Route 53, ALB, CloudFront, and outputs.
- The São Paulo side contains the São Paulo application EC2, TGW, TGW attachment, peering acceptance, cross-region routing, and no separate database.

## Interpretation

This matches the intended design: Tokyo is the authoritative region and São Paulo is the compute-only spoke.

---

## 6. Output Deliverable

The assignment stated that Tokyo should export values for São Paulo to consume.

The Tokyo outputs were verified as:

- `tokyo_vpc_cidr = "10.10.0.0/16"`
- `tokyo_tgw_id = "tgw-0f43bb3559a4397f3"`
- `tokyo_rds_endpoint = "arcanum-rds01.cdqyg4i0gz5f.ap-northeast-1.rds.amazonaws.com"`

An additional useful output was also present:

- `tokyo_tgw_peering_attachment_id = "tgw-attach-087be19171b508a2f"`

## Interpretation

These outputs provide the core values needed for São Paulo route and connectivity configuration.

---

## 7. Remote State Caveat

The teacher’s suggested structure stated that São Paulo should consume Tokyo outputs through Terraform remote state.

## Validation result

This was only partially met.

- The Tokyo outputs existed and were used functionally.
- The final working implementation relied on variables and `terraform.tfvars` for part of the cross-region handoff.
- Remote-state structure existed conceptually, but it was not the sole final working path.

## Interpretation

The functional deliverable was achieved, but the implementation differed slightly from the teacher’s exact suggested wiring pattern.

---

## Final Conclusion

Lab 3A was successfully verified.

- São Paulo EC2 reached Tokyo RDS on port 3306
- São Paulo inserted a record successfully
- Tokyo read the same record successfully
- Both regional route tables sent the remote CIDR through Transit Gateway
- Tokyo exported the core values required for cross-region wiring

This confirms the intended Lab 3A design: São Paulo serves as compute, Tokyo remains authoritative for storage, and the cross-region application path works through a controlled TGW corridor.
