# Week 4: Reconnaissance and Information Gathering

## CYB204 Ethical Hacking — Lab 4

**Topic:** Active reconnaissance using Nmap

---

## Overview

In this lab you will use Nmap to perform reconnaissance against three simulated target systems on an isolated lab network. You will practice port scanning, service version detection, and OS fingerprinting — core skills for the Assessment 1 engagement proposal.

| Container | IP | Services |
|---|---|---|
| week4-attacker | 172.40.0.2 | Kali attacker (your machine) |
| week4-web | 172.40.0.10 | HTTP (port 80, Nginx) |
| week4-ftp | 172.40.0.11 | FTP (port 21, vsftpd) |
| week4-ssh | 172.40.0.12 | SSH (port 22, OpenSSH) |

---

## Prerequisites

- Docker and Docker Compose installed
- Shared `ethical-base` image built (`make build-base` from repo root)

---

## Quick Start

```bash
# From repo root — build the base image once if you haven't already
make build-base

# Start Week 4 lab
make run-week4

# Enter the attacker container
docker exec -it week4-attacker bash
```

---

## Lab Exercises

See **worksheet.md** for step-by-step exercises.

---

## Cleanup

```bash
cd labs/week4 && docker compose down
```
