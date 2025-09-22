# Ethical Hacking Course Docker Labs

This repository organizes Docker labs for a 12-week ethical hacking course. Each week has a dedicated folder with Docker Compose setups, READMEs, and resources aligned to the course topics.

## Course Alignment

| Week | Topic | Lab Focus | Key Tools/Services |
|------|--------|-----------|-------------------|
| 1 | Setup Docker Environment | Basic setup with utils | HAProxy, Wireshark, SecUtils, Kali base |
| 2 | Ethical and legal issues | Readings and discussions | N/A (docs only) |
| 3 | Scope and proposal development | Traffic analysis | Wireshark + sample captures |
| 4 | Reporting and engagement close out | Scanning targets | Nmap on targets |
| 5 | System and network enumeration | Enumeration | LDAP, MySQL, Netshoot |
| 6 | Password cracking | Cracking techniques | John, Hydra, SSH target |
| 7 | Web app vulnerabilities | SQLi, XSS | DVWA, Juice Shop |
| 8 | Privilege escalation | Escalation vectors | DeICE sim, SUID vulns |
| 9 | Lateral movement | Pivoting | Metasploit, Windows network sim |
| 10 | Exploit development | Buffer overflows | GDB, vulnerable bins |
| 11 | Bypassing physical access | Physical security | RFID sim (future) |
| 12 | Social engineering | Phishing mitigation | Phishing kits, awareness |

## Shared Base Image

All labs use a shared `ethical-base` image built from `base.Dockerfile` (Kali with core tools like nmap, hydra, john, etc.). This reduces duplication.

## Usage

1. **Build base**: `make build-base`

2. **Run a week**: `make run-weekN` (e.g., `make run-week6`)

3. **Stop all**: `make stop-all`

4. **Clean**: `make clean-all`

### For Missing Weeks
Some weeks (2,3,4,5,9-12) need custom content. Examples:
- Week2: Add README with ethics readings.
- Week3: Copy wireshark compose from week1.

## Structure
- `base.Dockerfile`: Shared Kali base.
- `labs/weekN/`: Per-week setups.
- `Makefile`: Orchestration.

## Setup
Git clone if needed. Run in isolated environment.

**Note**: Educational only. Follow ethics; no real-world testing without permission.

Generated with Claude Code.