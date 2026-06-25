# Ethical Hacking Course Docker Labs

<!-- BADGES:START -->
[![cybersecurity](https://img.shields.io/badge/-cybersecurity-f44336?style=flat-square)](https://github.com/topics/cybersecurity) [![docker](https://img.shields.io/badge/-docker-2496ed?style=flat-square)](https://github.com/topics/docker) [![docker-compose](https://img.shields.io/badge/-docker--compose-blue?style=flat-square)](https://github.com/topics/docker-compose) [![edtech](https://img.shields.io/badge/-edtech-4caf50?style=flat-square)](https://github.com/topics/edtech) [![educational](https://img.shields.io/badge/-educational-blue?style=flat-square)](https://github.com/topics/educational) [![ethical-hacking](https://img.shields.io/badge/-ethical--hacking-blue?style=flat-square)](https://github.com/topics/ethical-hacking) [![kali-linux](https://img.shields.io/badge/-kali--linux-blue?style=flat-square)](https://github.com/topics/kali-linux) [![penetration-testing](https://img.shields.io/badge/-penetration--testing-blue?style=flat-square)](https://github.com/topics/penetration-testing) [![security-training](https://img.shields.io/badge/-security--training-blue?style=flat-square)](https://github.com/topics/security-training) [![vulnerability-assessment](https://img.shields.io/badge/-vulnerability--assessment-blue?style=flat-square)](https://github.com/topics/vulnerability-assessment)
<!-- BADGES:END -->

This repository organizes Docker labs for a 12-week ethical hacking course. Each week has a dedicated folder with Docker Compose setups, READMEs, and resources aligned to the course topics.

## Course Alignment

| Week | Topic | Lab Focus | Key Tools/Services |
|------|--------|-----------|-------------------|
| 1 | Setup Docker Environment | Basic setup with utils | HAProxy, Wireshark, SecUtils, Kali base |
| 2 | Ethical and legal issues | Readings and discussions | N/A (docs only) |
| 3 | Scope and proposal development | Traffic analysis | Wireshark + sample captures |
| 4 | Reporting and engagement close out | Scanning targets | Nmap on targets |
| 5 | System and network enumeration | Enumeration | LDAP, MySQL, SMB, SNMP, Netshoot |
| 6 | Password cracking | Cracking techniques | John, Hydra, SSH target |
| 7 | Web app vulnerabilities | SQLi, XSS | DVWA, Juice Shop |
| 8 | Privilege escalation | Escalation vectors | DeICE sim, SUID vulns |
| 9 | Lateral movement | Pivoting | SSH/SOCKS tunnels, dual-network sim |
| 10 | Exploit development | Buffer overflows | GDB, vulnerable bins |
| 11 | Bypassing physical access | Physical security | Access-control logic sim (RFID analog) |
| 12 | Social engineering | Phishing mitigation | GoPhish, MailHog, awareness |

## Shared Base Image

All labs use a shared `ethical-base` image built from `base.Dockerfile` (Kali with core tools like nmap, hydra, john, etc.). This reduces duplication.

## Usage

1. **Build base**: `make build-base`

2. **Run a week**: `make run-weekN` (e.g., `make run-week6`)

3. **Stop all**: `make stop-all`

4. **Clean**: `make clean-all`

5. **Check availability**: `make status` lists every week and whether it's ready.

### Lab Status
All 12 weeks are implemented. Week 2 is docs-only (ethics & law); weeks 1 and 3–12 are hands-on Docker labs. Run `make status` from the repo root to see which weeks are ready and their start commands. Each hands-on lab ships a `README.md`, a `STUDENT-WORKSHEET.md`, and any seed files its services need.

## Structure
- `base.Dockerfile`: Shared Kali base.
- `labs/weekN/`: Per-week setups.
- `Makefile`: Orchestration.

## Setup
Git clone if needed. Run in isolated environment.

**Note**: Educational only. Follow ethics; no real-world testing without permission.

Generated with Claude Code.