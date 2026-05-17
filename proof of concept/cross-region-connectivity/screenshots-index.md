# Lab 3A Screenshot Verification Index

This index explains what each kept screenshot proves for Lab 3A verification.

---

## Lab 3A — Cross-Region Runtime / Corridor Proof

### `3A_01_saopaulo_to_tokyo_rds_3306_connected.png`

**What it proves**

* The São Paulo EC2 instance can reach the Tokyo RDS endpoint on **port 3306**
* Cross-region network connectivity is working at the database port level
* The application path is not blocked by routing or security-group policy

### `3A_02_saopaulo_submit_record_redacted.png`

**What it proves**

* A record was submitted from the **São Paulo** application side
* The São Paulo application is able to write through the corridor to the Tokyo-backed database
* This is the write-half of the “same data, one DB” proof

### `3A_03_tokyo_reads_saopaulo_record.png`

**What it proves**

* The **Tokyo** application instance can read the exact note inserted from São Paulo
* Both regional application instances are reading the **same database**
* This is the strongest application-level proof that there is **one shared DB**, not duplicated regional storage

### `3A_04_saopaulo_route_table_to_tokyo_via_tgw.png`

**What it proves**

* The São Paulo VPC route table includes the Tokyo CIDR `10.10.0.0/16`
* That remote CIDR is routed through the **São Paulo TGW**
* The São Paulo side of the legal corridor is explicitly configured

### `3A_05_tokyo_route_table_to_saopaulo_via_tgw.png`

**What it proves**

* The Tokyo VPC route table includes the São Paulo CIDR `10.20.0.0/16`
* That remote CIDR is routed through the **Tokyo TGW**
* The Tokyo side of the legal corridor is explicitly configured

### `3A_06_repo_structure_tokyo_and_saopaulo.png`

**What it proves**

* The repository is split into distinct **`/tokyo/`** and **`/saopaulo/`** components
* The Tokyo side serves as the authoritative region and TGW hub
* The São Paulo side serves as the compute-only region and TGW spoke

### `3A_07_tokyo_terraform_outputs.png`

**What it proves**

* The Tokyo Terraform outputs export the values São Paulo needs to consume
* This includes:
  * `tokyo_vpc_cidr`
  * `tokyo_tgw_id`
  * `tokyo_rds_endpoint`
* Tokyo is acting as the authoritative output source for cross-region wiring

### `3A_08_saopaulo_remote_state_consumes_tokyo_outputs.png`

**What it proves**

* São Paulo consumes Tokyo values through **Terraform remote state**
* Cross-region routes and security-group logic are being driven from exported Tokyo outputs rather than hard-coded duplication
* This is the cleanest proof of the intended IaC dependency pattern

---

## Summary

### Runtime proof

* São Paulo compute can reach Tokyo storage over the TGW corridor
* São Paulo can write a record
* Tokyo can read that same record
* Route tables in both regions explicitly send the remote CIDR to TGW

### Repo / IaC proof

* The repository is split into Tokyo and São Paulo roles
* Tokyo exports the core values needed for cross-region wiring
* São Paulo is intended to consume those values for routing and security-group configuration

---

## Optional / Archive Screenshots

These are useful as backup evidence but are not required in the lean final Lab 3A set:

* extra connectivity or terminal crops
* mixed route and connectivity backup screenshots
* duplicate app-validation screenshots
* duplicate TGW or route outputs
