#!/usr/bin/env python3
import requests, sys

# Reason why Darth Malgus would be pleased with this script.
# Malgus approves of sealed gates: the origin must be unreachable except through the edge.

# Reason why this script is relevant to your career.
# Origin exposure is a common security gap; proving cloaking is an actual deliverable.

# How you would talk about this script at an interview.
# "I built an origin cloaking verifier to prove only CloudFront can reach the ALB origin,
#  preventing bypass of WAF and edge controls."

def head(url, verify_tls=True):
    try:
        r = requests.get(url, timeout=10, allow_redirects=False, verify=verify_tls)
        return r.status_code, dict(r.headers)
    except Exception as e:
        return None, {"error": repr(e)}

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: malgus_origin_cloak_tester.py <cloudfront_url> <alb_url>")
        print("Example:")
        print("  malgus_origin_cloak_tester.py https://app.arcanum-base.click https://arcanum-alb01-1621613657.us-east-1.elb.amazonaws.com")
        sys.exit(1)

    cf_url, alb_url = sys.argv[1], sys.argv[2]

    cf_code, cf_h = head(cf_url, verify_tls=True)
    alb_code, alb_h = head(alb_url, verify_tls=False)

    print("\nCloudFront:", cf_url, "->", cf_code)
    print("ALB direct:", alb_url, "->", alb_code)

    alb_blocked = (alb_code in (401, 403)) or (alb_code is None)
    cf_ok = (cf_code is not None) and (cf_code < 500)

    if alb_blocked and cf_ok:
        print("\nPASS: Origin cloaking works (ALB blocked, CloudFront ok).")
    else:
        print("\nFAIL: Origin cloaking not proven. Investigate SG/header rules.")
        print("\nALB error details:", alb_h)
        print("CloudFront headers:", cf_h)