# 05 Network Corridor Proof — TGW Legal Corridor

## Objective
Prove that São Paulo reaches Tokyo through a controlled TGW corridor rather than through ad hoc or public cross-region networking.

## Key resources
- Tokyo TGW: `tgw-0f43bb3559a4397f3`
- São Paulo TGW: `tgw-07cf5b59d76c3556c`
- Peering attachment: `tgw-attach-087be19171b508a2f`
- Tokyo TGW route table: `tgw-rtb-048aa07338bfff225`
- São Paulo TGW route table: `tgw-rtb-01970b7ad46d3c115`
- Tokyo private route table: `rtb-082a069c8a65e4d6f`
- São Paulo private route table: `rtb-008eee8f71fd72312`

## Validation facts
The Tokyo and São Paulo transit gateways were both verified as `available`, and the peering attachment `tgw-attach-087be19171b508a2f` was verified as `available`.

The São Paulo private route table `rtb-008eee8f71fd72312` contains an active route for `10.10.0.0/16` through `tgw-07cf5b59d76c3556c`.

The Tokyo RDS security group allows MySQL port 3306 from São Paulo CIDR `10.20.0.0/16` with description `Allow MySQL from Sao Paulo VPC over TGW`.

After the missing TGW route-table entries were added, end-to-end connectivity succeeded from São Paulo to Tokyo RDS.

## Application-path validation
From the São Paulo EC2 instance, the app successfully:
- initialized the Tokyo database: `Initialized arcdb + notes table.`
- inserted a record: `Inserted note: lab3-saopaulo-test`
- read the record back: `<li>1: lab3-saopaulo-test</li>`

A direct TCP test also succeeded from São Paulo EC2 to the Tokyo RDS endpoint on port 3306.

## Interpretation
This proves that the cross-region database path is deliberate, routed, and controlled: São Paulo compute reaches Tokyo storage only through the TGW peering corridor, and the application can perform real read/write operations across that corridor.
