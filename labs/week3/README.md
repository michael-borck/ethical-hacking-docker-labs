# Week 3: Scope and Proposal Development - Traffic Analysis Lab

## Overview
This lab focuses on analyzing captured network traffic using Wireshark to inform scope/proposal writing. Use the shared packet captures in `data/caps` to identify assets, potential risks, and draft engagement scopes.

## Learning Objectives
- Load and filter .cap files in Wireshark.
- Identify protocols, hosts, and anomalies (e.g., unusual ports, payloads).
- Draft a pentest scope/proposal based on analysis (e.g., target services, rules of engagement).

## Setup (2 min)
1. Ensure base built: `make build-base` (from root).
2. Start lab: From root, `cd labs/week3 && docker compose up -d`
3. Access Wireshark: http://localhost:3000 (default creds: admin/admin or configure in env).
4. Sample target runs on 172.30.0.3 for live capture practice.

## Activities
1. **Static Analysis (30 min)**:
   - Open a .cap file: File > Open > /caps (e.g., sample-traffic.cap).
   - Filter: `http` or `ip.src == 192.168.x.x`.
   - Note: Hosts, ports, data volumes. Look for sensitive info (e.g., creds in cleartext).

2. **Live Capture (20 min)**:
   - Use Wireshark interface to capture from sample-target.
   - Run commands on target: `docker exec -it week3-target nmap -sV 172.30.0.2`.
   - Analyze: Identify enumeration patterns.

3. **Proposal Draft (40 min)**:
   - Based on findings, write a scope doc (use template in root/docs if exists):
     - In-scope: Specific IPs/services.
     - Out-of-scope: Production systems.
     - Rules: No DoS, report vulns immediately.
   - Example: "Scope includes HTTP/SSH analysis from cap; propose scanning ports 80,22."

## Resources
- Chapter 3: Analysing Captured Traffic.
- Wireshark docs: https://www.wireshark.org/docs/wsug_html_chunked/.
- Sample caps: Add more to data/caps (e.g., download innocent traffic from Wireshark wiki).

## Cleanup
`docker compose down`

**Ethics**: Analysis only—no active attacks. Document assumptions for proposals.

Generated with Claude Code.