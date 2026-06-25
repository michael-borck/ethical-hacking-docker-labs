# Week 4: Reporting and Engagement Close-out — Nmap Scanning Lab

## Overview
This lab teaches network scanning and service discovery with Nmap, then ties those
results into a professional scan report — the kind of deliverable that closes out an
engagement. You run entirely inside an isolated Docker network (`172.21.0.0/24`) with
five purpose-built targets: a web server, an SSH host, MySQL, Redis, and one "silent"
host that exposes no services. No exploitation is performed; the focus is discovery,
fingerprinting, and reporting.

## Learning Objectives
- Perform host discovery and explain why a "silent" host can still be live.
- Distinguish TCP SYN (`-sS`), TCP connect (`-sT`), and why SYN scanning needs privilege.
- Use service/version detection (`-sV`) and OS detection (`-O`).
- Run Nmap NSE scripts (`-sC` and targeted `--script` categories).
- Apply timing/stealth options (`-T0`…`-T4`, `-f`) and save output in multiple formats.
- Produce a one-page scan report summarizing findings — the engagement close-out artifact.

## Setup (3 min)
1. Build the base image (from repo root): `make build-base`
2. Start the lab: `cd labs/week4 && docker compose up -d`
3. Enter the attacker container: `docker exec -it week4-attacker bash`

Target map (all on `scan_net`, `172.21.0.0/24`):

| Hostname      | IP            | Service        | Host port        |
|---------------|---------------|----------------|------------------|
| attacker      | 172.21.0.5    | Kali (you)     | —                |
| web           | 172.21.0.10   | Apache httpd   | 14080 → 80       |
| ssh-target    | 172.21.0.11   | OpenSSH        | 14022 → 22       |
| mysql-target  | 172.21.0.12   | MySQL 8        | 13306 → 3306     |
| redis-target  | 172.21.0.13   | Redis 7        | 16379 → 6379     |
| silent-host   | 172.21.0.14   | (none)         | —                |

## Activities

### 1. Host discovery (5 min)
Find which hosts are live **without** port scanning.
```bash
nmap -sn 172.21.0.0/24
```
Note which hosts appear. `silent-host` exposes no ports yet should still show as **up**
— host discovery uses ICMP echo, ARP, and TCP ACK/SYN probes to ports 80/443, not open
services. This is the core host-discovery nuance.

### 2. Port scan types: SYN vs connect (10 min)
```bash
# TCP SYN (half-open) scan — the default for a privileged user
nmap -sS 172.21.0.10-14

# TCP connect scan — used when you lack raw-socket privileges
nmap -sT 172.21.0.10-14
```
`-sS` sends a SYN and waits for SYN/ACK without completing the handshake, so it is
quieter and doesn't log a full connection — but it requires **root/raw sockets**
(that is why our attacker runs with `NET_ADMIN`). `-sT` uses the normal `connect()`
system call and works as any unprivileged user, at the cost of being noisier and
logging connections.

### 3. Service and version detection (10 min)
Identify the actual software behind each open port.
```bash
nmap -sV 172.21.0.10-14
```
Record the product and version nmap reports for the **web** (`Apache httpd`,
banner `WebServer`), **mysql-target**, and **redis-target**.

### 4. OS detection (10 min)
```bash
nmap -O 172.21.0.10-14
```
Nmap guesses the operating system from TCP/IP stack fingerprints. `silent-host` is
Alpine Linux; `ssh-target` is Ubuntu. Record nmap's guess and confidence. OS detection
requires root.

### 5. NSE scripts (15 min)
The Nmap Scripting Engine extends scanning with safe default checks and targeted probes.
```bash
# Default safe-script set across all targets
nmap -sC 172.21.0.10-14

# Targeted scripts — pick the script to the service you are examining
nmap --script mysql-empty-password   172.21.0.12
nmap --script redis-info             172.21.0.13
nmap --script ssh-hostkey,ssh-auth-methods 172.21.0.11
```
> Note: `vulners` / `smb-os-discovery` are shown here as canonical `--script` examples.
> `vulners` needs network access to fetch data and is **not** required; the scripts
> above run fully offline against these targets.

### 6. Timing, templates and stealth (10 min)
```bash
# Timing templates -T0 (paranoid) .. -T5 (insane). -T4 is a good default.
nmap -T4 172.21.0.10-14

# Fragment each probe across multiple IP packets to evade simple IDS
nmap -f 172.21.0.10
```
Compare how `-T0` (one probe at a time, long delays) differs from `-T4` (aggressive,
fast). Slower templates are stealthier but far slower; `-f` fragments packets to slip
past naive signature-based detection.

### 7. Saving output and producing the report (15 min)
Nmap can write results in several formats — capture all at once with `-oA`:
```bash
# -oA writes normal, XML, and grepable files in one shot
nmap -sS -sV -O -oA week4-scan 172.21.0.0/24

# Individual formats
nmap -sV -oN week4-normal.txt 172.21.0.0/24   # human-readable
nmap -sV -oX week4-scan.xml   172.21.0.0/24   # for tools/parsers
nmap -sV -oG week4-grep.txt   172.21.0.0/24   # grep-friendly one line/host
```
Turn these outputs into the **engagement close-out deliverable**: a one-page scan report
listing each host, its open ports, identified services/versions, guessed OS, and a short
risk note per host. See `LAB-GUIDE.md` for the report template.

## Cleanup
```bash
docker compose down
```
**Ethics**: Educational use only — scan only this isolated Docker network; any real-world
scanning requires written authorization.

Generated with Claude Code.
