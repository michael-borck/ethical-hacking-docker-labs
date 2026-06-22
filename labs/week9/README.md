# Week 9: Lateral Movement Between Systems and Services

## CYB204 Ethical Hacking — Lab 9

**Topic:** Network pivoting — using a compromised host to reach internal systems

---

## Overview

This lab simulates a segmented corporate network. You start on the external network and must pivot through a compromised host to reach the internal network.

```
EXTERNAL (172.90.10.0/24)          INTERNAL (172.90.20.0/24)
┌─────────────────────┐            ┌──────────────────────────┐
│  week9-attacker     │            │  week9-internal-web :80  │
│  172.90.10.2        │            │  172.90.20.20            │
│                     │            │                          │
│  week9-pivot ───────┼────────────┤  week9-internal-db :3306 │
│  172.90.10.10       │            │  172.90.20.21            │
└─────────────────────┘            └──────────────────────────┘
```

The attacker **cannot directly reach** 172.90.20.x — all traffic must go through the pivot host.

---

## Prerequisites

- Docker and Docker Compose installed
- No `make build-base` needed — week9-attacker uses the Metasploit Framework image

---

## Quick Start

```bash
# Start Week 9 lab
make run-week9

# Enter the attacker container
docker exec -it week9-attacker bash
```

---

## Lab Exercises

See **worksheet.md** for step-by-step exercises.

---

## Cleanup

```bash
cd labs/week9 && docker compose down
```
