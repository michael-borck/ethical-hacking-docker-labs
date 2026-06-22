# Week 5: System and Network Enumeration

## CYB204 Ethical Hacking — Lab 5

**Topic:** Active enumeration — LDAP, MySQL, SMB

---

## Overview

This lab provides three enumeration targets simulating a typical corporate network. You will extract usernames, database schemas, and file-share information using standard enumeration tools.

| Container | IP | Services |
|---|---|---|
| week5-attacker | 172.50.0.2 | Kali attacker (your machine) |
| week5-ldap | 172.50.0.10 | LDAP (port 389, OpenLDAP) |
| week5-mysql | 172.50.0.11 | MySQL (port 3306) |
| week5-smb | 172.50.0.12 | SMB/Samba (port 445) |
| week5-netshoot | 172.50.0.20 | Network diagnostic utility |

**LDAP credentials** (for authenticated queries): `cn=readonly,dc=cybercorp,dc=local` / `readonly123`

**MySQL credentials** (for authenticated queries): `dbuser` / `dbpass123`

---

## Prerequisites

- Docker and Docker Compose installed
- Shared `ethical-base` image built (`make build-base` from repo root)

---

## Quick Start

```bash
# Build base image (once)
make build-base

# Start Week 5 lab
make run-week5

# Enter the attacker container
docker exec -it week5-attacker bash
```

The attacker startup installs `enum4linux`, `ldap-utils`, `smbclient`, and `mysql-client` — this takes ~30 seconds on first run.

---

## Lab Exercises

See **worksheet.md** for step-by-step exercises.

---

## Cleanup

```bash
cd labs/week5 && docker compose down
```
