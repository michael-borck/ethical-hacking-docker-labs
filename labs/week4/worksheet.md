# Week 4: Reconnaissance and Information Gathering
## CYB204 Ethical Hacking — Student Worksheet

---

## Before We Start (5 minutes)

### Important Rules
✅ **DO:** Only scan targets within this lab environment
✅ **DO:** Ask your instructor if you get stuck
✅ **DO:** Document everything you find — recon notes matter for Assessment 1
❌ **DON'T:** Scan any real-world targets without written permission
❌ **DON'T:** Attempt to log in to target systems (this week is recon only)

### Connection to Assessment 1
Assessment 1 asks you to write an engagement proposal. A good proposal depends on knowing what you'd find during recon. Today's nmap skills are exactly what you'd use in the Discovery phase of a real engagement.

---

## Setup (5 minutes)

```bash
# From the repo root — only needed once
make build-base

# Start the lab
make run-week4

# Enter your attacker machine
docker exec -it week4-attacker bash

# Verify network connectivity
ping -c 2 172.40.0.10
```

**Check:** Do you see ping replies?  ✓ Yes  ✓ No

If no, run `docker compose ps` to check that all containers are `Up`.

---

## Part 1: Basic Port Scanning (20 minutes)

### Exercise 1.1: Connect-Scan (TCP SYN)

The most common Nmap scan type. Sends a SYN packet and listens for SYN-ACK.

```bash
# Scan a single target
nmap 172.40.0.10
```

**Write the open ports you found:**

| Port | Protocol | State |
|------|----------|-------|
|      |          |       |
|      |          |       |

**Question:** What does it mean when a port is listed as "filtered"?

_________________________________

---

### Exercise 1.2: Scan the Full Lab Subnet

```bash
# Scan all three targets at once
nmap 172.40.0.0/24
```

**How many hosts are up?** _____

**List each host IP and its open ports:**

| Host IP | Open Ports |
|---------|------------|
|         |            |
|         |            |
|         |            |

---

### Exercise 1.3: Ping Sweep (Host Discovery)

```bash
# Find live hosts without port scanning
nmap -sn 172.40.0.0/24
```

**How many hosts responded?** _____

**Question:** Why would you run `-sn` before a full port scan on a large network?

_________________________________

---

## Part 2: Service Version Detection (20 minutes)

### Exercise 2.1: Version Scan

The `-sV` flag makes Nmap probe open ports to identify the running software and version.

```bash
# Scan with version detection
nmap -sV 172.40.0.10
nmap -sV 172.40.0.11
nmap -sV 172.40.0.12
```

**Fill in the service version table:**

| Target IP | Port | Service | Version |
|-----------|------|---------|---------|
| 172.40.0.10 | 80 | | |
| 172.40.0.11 | 21 | | |
| 172.40.0.12 | 22 | | |

**Question:** Why is knowing the exact version of a service useful for an attacker?

_________________________________

---

### Exercise 2.2: Aggressive Scan

```bash
# Aggressive scan: version + OS detection + scripts + traceroute
nmap -A 172.40.0.0/24
```

This takes longer — while it runs, read ahead to the discussion questions.

**What additional information did `-A` reveal compared to `-sV`?**

_________________________________

**Did Nmap detect an operating system for any target?** ✓ Yes  ✓ No

If yes, which target and what OS? _________________________________

---

## Part 3: Scan Techniques and Stealth (20 minutes)

### Exercise 3.1: TCP SYN Scan (Stealth Scan)

```bash
# SYN scan — requires root/CAP_NET_RAW
nmap -sS 172.40.0.0/24
```

**Question:** How does a SYN scan differ from a full TCP connect scan (`-sT`)?

_________________________________

**Which is harder to detect in firewall logs, and why?**

_________________________________

---

### Exercise 3.2: Service Script Scan

Nmap has built-in scripts (NSE) that run extra checks against detected services.

```bash
# Run default scripts against FTP target
nmap -sC -sV 172.40.0.11

# Specifically test for anonymous FTP login
nmap --script ftp-anon 172.40.0.11
```

**Does the FTP server allow anonymous login?** ✓ Yes  ✓ No

**Question:** What's the security risk of anonymous FTP?

_________________________________

---

### Exercise 3.3: SSH Enumeration Scripts

```bash
# Check SSH host key algorithms
nmap --script ssh-hostkey 172.40.0.12

# Check SSH authentication methods
nmap --script ssh-auth-methods --script-args="ssh.user=sysadmin" 172.40.0.12
```

**What authentication methods does the SSH server support?**

_________________________________

---

## Part 4: Output and Reporting (15 minutes)

### Exercise 4.1: Save Scan Results

Pentest reports always include raw scan output. Nmap can save results in multiple formats.

```bash
# Save in all formats at once
nmap -sV -oA /tmp/week4-scan 172.40.0.0/24

# View the normal text output
cat /tmp/week4-scan.nmap
```

**What is the `.xml` format useful for?**

_________________________________

---

### Exercise 4.2: Write a Mini Recon Summary

Using your scan results, fill in this engagement-proposal-style summary. This is the kind of output you'd include in Assessment 1.

**Target Network:** 172.40.0.0/24

**Hosts Discovered:**

| IP | Hostname | OS (if detected) | Open Ports | Key Services |
|----|----------|-----------------|------------|--------------|
|    |          |                 |            |              |
|    |          |                 |            |              |
|    |          |                 |            |              |

**Notable Findings:**

1. ___________________________

2. ___________________________

3. ___________________________

**Recommended Next Steps (enumeration/exploitation):**

_________________________________

---

## Part 5: Ethics and Legal Considerations (10 minutes)

### Discussion Questions

1. **Scope:** You are hired to test `cybercorp.com.au`. The Nmap scan reveals the server also hosts `partnercorp.com.au`. Should you scan that domain too?

   **Answer:** _________________________________

2. **Disclosure:** During recon you discover the company is running software with a known critical CVE. Before you've been asked to exploit anything, what do you do?

   **Answer:** _________________________________

3. **Documentation:** Why is it important to timestamp and save your raw Nmap output rather than just writing notes?

   **Answer:** _________________________________

---

## Quick Knowledge Check

1. What Nmap flag enables service version detection?
   - A) `-sV`  B) `-sS`  C) `-A`  D) `-p`

2. What does `-sn` do?
   - A) Scan all ports  B) Ping sweep only  C) Enable scripts  D) Stealth scan

3. Which Nmap output format is best for importing into other tools?
   - A) `.nmap` (normal)  B) `.xml`  C) `.gnmap`  D) Plain text

4. True/False: Running Nmap against a system you don't have permission to scan is illegal in Australia under the Criminal Code Act 1995.

5. What does "filtered" mean in Nmap output?
   - A) Port is open  B) Port is closed  C) A firewall may be blocking the probe  D) Port doesn't exist

---

## Cleanup

```bash
# Exit the attacker container
exit

# Stop all Week 4 containers
cd labs/week4 && docker compose down
```

---

## Connecting to Assessment 1

Your Assessment 1 engagement proposal should include a **Reconnaissance Plan** section. After today's lab you can write:

- Which scanning tools you would use (Nmap, etc.)
- What scan types are appropriate for the engagement scope
- How you would document and report findings
- Legal/ethical constraints that apply to recon activities

---

## Summary

Today you learned to:
✓ Run basic Nmap port scans
✓ Detect service versions with `-sV`
✓ Use NSE scripts for automated checks
✓ Save scan output for reporting
✓ Explain the legal context of active reconnaissance

**Instructor Contact:** _________________________________
