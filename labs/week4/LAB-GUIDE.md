# Week 4: Nmap Scanning & Scan Reporting

---

## **Before We Start (5 minutes)**

### **Important Rules**
✅ **DO:** Only scan the lab network `172.21.0.0/24`
✅ **DO:** Save your scan output — it becomes your report
✅ **DO:** Ask for help if a command errors
✅ **DO:** Work with a partner if you want
❌ **DON'T:** Point nmap at any real or public IP
❌ **DON'T:** Try to log in to or exploit the targets — discovery only
❌ **DON'T:** Run a scan you were not given permission to run

### **Quick Setup**
```bash
# Step 1: Build the base image (from repo root, once)
make build-base

# Step 2: Start the lab
cd labs/week4
docker compose up -d

# Step 3: Wait ~30s for mysql/ssh to finish starting, then enter the attacker
docker exec -it week4-attacker bash

# Step 4: Confirm nmap works
nmap --version
```

**Check:** Do you see the nmap version banner? ✓ Yes ✓ No

**Your target map:**
| Hostname      | IP            | Expected service |
|---------------|---------------|------------------|
| web           | 172.21.0.10   | Apache httpd     |
| ssh-target    | 172.21.0.11   | OpenSSH          |
| mysql-target  | 172.21.0.12   | MySQL            |
| redis-target  | 172.21.0.13   | Redis            |
| silent-host   | 172.21.0.14   | (none)           |

---

## **Part 1: Host Discovery (10 minutes)**

### **Exercise 1.1: Who is alive?**
A "ping sweep" finds live hosts without scanning their ports.

```bash
# -s{n} = "skip port scan", just discover hosts
nmap -sn 172.21.0.0/24
```

**List every host nmap reports as "Up":**

| IP | Hostname (if shown) | Up? (✓/✗) |
|----|---------------------|-----------|
| 172.21.0.5  | attacker     |   |
| 172.21.0.10 | web          |   |
| 172.21.0.11 | ssh-target   |   |
| 172.21.0.12 | mysql-target |   |
| 172.21.0.13 | redis-target |   |
| 172.21.0.14 | silent-host  |   |

### **Exercise 1.2: The silent host**
`silent-host` exposes **no** open ports, yet it should still appear as **Up**.

**Question:** If a host answers ICMP but has no open ports, would a port-only scan
show it as useful? (Circle one)
- YES — open ports everywhere
- NO — "host up" but nothing to report

**Why does this matter for an engagement report?**
_________________________

---

## **Part 2: Port Scan Types (15 minutes)**

### **Exercise 2.1: TCP SYN scan (-sS)**
The SYN ("half-open") scan is nmap's default when you have privilege.

```bash
# Scan the 5 targets (note the - syntax means a range)
nmap -sS 172.21.0.10-14
```

**Fill in the open ports nmap found:**

| Host          | Open port(s) | Service |
|---------------|--------------|---------|
| web           |              |         |
| ssh-target    |              |         |
| mysql-target  |              |         |
| redis-target  |              |         |
| silent-host   |              |         |

### **Exercise 2.2: TCP connect scan (-sT)**
```bash
# -sT uses the normal connect() call — no raw sockets needed
nmap -sT 172.21.0.10-14
```

**Are the results the same as -sS?** ✓ Yes ✓ No

**Difference you noticed (speed / output):** ______________

### **Exercise 2.3: Why does -sS need privilege?**
Circle the best answer:
- A) Because it logs in to the target
- B) Because it crafts raw SYN packets, which need root/raw sockets
- C) Because it is illegal for normal users
- D) Because it uses more bandwidth

Our attacker runs with `cap_add: NET_ADMIN`, which is why `-sS` works here.

---

## **Part 3: Service & Version Detection (15 minutes)**

### **Exercise 3.1: Fingerprint the services**
```bash
# -sV probes open ports to identify the product + version
nmap -sV 172.21.0.10-14
```

**Fill in what nmap reports:**

| Host          | Port | Service | Product | Version |
|---------------|------|---------|---------|---------|
| web           | 80   | http    |         |         |
| ssh-target    | 22   | ssh     |         |         |
| mysql-target  | 3306 | mysql   |         |         |
| redis-target  | 6379 | redis   |         |         |

### **Exercise 3.2: Spot the banner**
Open the web banner in the attacker's browser / curl:
```bash
curl http://web
```
**What banner word appears in the `<h1>`?** ______________

**Did `-sV` also surface that banner text?** ✓ Yes ✓ No

---

## **Part 4: OS Detection (10 minutes)**

### **Exercise 4.1: Guess the operating system**
```bash
# -O fingerprints the TCP/IP stack to guess the OS (needs root)
nmap -O 172.21.0.10-14
```

**Write nmap's OS guess and confidence for each host:**

| Host          | OS nmap guessed | Confidence |
|---------------|-----------------|------------|
| web (httpd)   |                 |            |
| ssh-target    |                 |            |
| mysql-target  |                 |            |
| redis-target  |                 |            |
| silent-host   |                 |            |

> `silent-host` is Alpine Linux and `ssh-target` is Ubuntu 22.04. How close was nmap?

### **Exercise 4.2: All-in-one scan**
Combine detection in one command (this is what pros run):
```bash
nmap -sS -sV -O 172.21.0.10-14
```

**Did combining flags change the findings?** ✓ Yes ✓ No

---

## **Part 5: NSE Scripts (15 minutes)**

The Nmap Scripting Engine (NSE) runs small safe checks against discovered services.

### **Exercise 5.1: Default scripts (-sC)**
```bash
# -sC runs the "default" safe script set
nmap -sC 172.21.0.10-14
```

**Did -sC reveal any extra info (e.g. SSH host key, http title)?** ______________

### **Exercise 5.2: Targeted scripts**
```bash
# MySQL — does the root account have a blank password? (it won't here)
nmap --script mysql-empty-password 172.21.0.12

# Redis — pull server info
nmap --script redis-info 172.21.0.13

# SSH — show host key + allowed auth methods
nmap --script ssh-hostkey,ssh-auth-methods 172.21.0.11
```

**mysql-empty-password result:** ______________
**redis-info: redis_version reported:** ______________
**ssh-auth-methods: what methods are allowed?** ______________

> The contract's classic examples also include `--script vulners,smb-os-discovery`.
> `vulners` needs internet access to fetch data, so it is optional here — your offline
> scripts above are the graded activity.

---

## **Part 6: Timing & Stealth (15 minutes)**

### **Exercise 6.1: Compare timing templates**
Run the same scan at two different speeds and time them:

```bash
# Paranoid — slow, one probe, long waits (you can Ctrl-C early)
time nmap -T0 -p 22,80,3306,6379 172.21.0.10

# Aggressive — fast default for pros
time nmap -T4 -p 22,80,3306,6379 172.21.0.10
```

**Fill in the stealth-vs-noisy comparison table:**

| Option | Speed | Stealth (low=quiet, high=loud) | Logged by target? | Best use |
|--------|-------|--------------------------------|-------------------|----------|
| `-T0` (Paranoid) |       |                                |                   |          |
| `-T2` (Polite)   |       |                                |                   |          |
| `-T4` (Aggressive)|      |                                |                   |          |
| `-f` (fragments) |       |                                |                   |          |

### **Exercise 6.2: Packet fragmentation**
```bash
# -f splits probes into small fragments to evade simple IDS signatures
nmap -f 172.21.0.10
```

**Did `-f` change the results vs a plain scan?** ✓ Yes ✓ No

**Circle the trade-off of `-f`:**
- A) Faster + louder
- B) Slower + quieter / evades naive IDS
- C) Finds more ports
- D) No real effect

---

## **Part 7: Saving Output & The Scan Report (20 minutes)**

### **Exercise 7.1: Save in every format**
```bash
# -oA writes normal + XML + grepable files at once (best practice)
nmap -sS -sV -O -oA week4-scan 172.21.0.0/24

# Individual formats
nmap -sV -oN week4-normal.txt 172.21.0.0/24   # human-readable report
nmap -sV -oX week4-scan.xml   172.21.0.0/24   # machine-readable
nmap -sV -oG week4-grep.txt   172.21.0.0/24   # one line per host
```

**Match the flag to its format (draw a line / fill the letter):**
| Flag  | Format           | Your match |
|-------|------------------|------------|
| `-oN` | grepable         |            |
| `-oX` | normal text      |            |
| `-oG` | XML              |            |
| `-oA` | all three at once|            |

### **Exercise 7.2: Produce a one-page scan report (THE deliverable)**
This is the **engagement close-out artifact**. Using your saved output, fill in the
report template below. Keep it to one page.

```
====================  SCAN REPORT  ====================
Engagement:  Week 4 Nmap Scanning Lab
Tester:      ____________________
Date:        ____________________
Scope:       172.21.0.0/24 (isolated Docker lab network)
Tools:       nmap __________ (version)
--------------------------------------------------------

HOST FINDINGS

1) web (172.21.0.10)
   Open ports:    ____________________
   Service/ver:   ____________________
   OS guess:      ____________________
   Risk note:     ____________________

2) ssh-target (172.21.0.11)
   Open ports:    ____________________
   Service/ver:   ____________________
   OS guess:      ____________________
   Risk note:     ____________________   (hint: weak guest password)

3) mysql-target (172.21.0.12)
   Open ports:    ____________________
   Service/ver:   ____________________
   OS guess:      ____________________
   Risk note:     ____________________

4) redis-target (172.21.0.13)
   Open ports:    ____________________
   Service/ver:   ____________________
   Risk note:     ____________________

5) silent-host (172.21.0.14)
   Status:        Up but no open ports
   Implication:   ____________________
--------------------------------------------------------
SUMMARY
- Total hosts up:           ____
- Total open ports found:   ____
- Top risk (pick one):      ____________________
- Recommended next step
  (for an authorized engagement only): ____________________
========================================================
```

**Self-check:** Would a client understand this report without asking you questions?
✓ Yes ✓ No

---

## **Part 8: Ethics & Professional Conduct (10 minutes)**

### **Exercise 8.1: Authorized or not?**
Mark each scenario as OK (authorized) or NOT OK:

| Scenario                                                     | OK? |
|--------------------------------------------------------------|-----|
| Scanning `172.21.0.0/24` in this lab                         |     |
| Running `nmap -sS` against your organization's website    |     |
| Scanning a server a client gave you written permission for   |     |
| Saving scan output to include in a paid pentest report       |     |
| Scanning a random public IP "to see what's there"            |     |
| Using `-O` against a host you were only told to web-test     |     |

### **Exercise 8.2: Scope creep**
**Scenario:** Your written scope says "test `172.21.0.0/24` only." During scanning you
notice a router at `172.21.0.1` and want to OS-fingerprint it.

What should you do? (Circle one)
- A) Scan it — it's on the same subnet
- B) Stop and request written authorization to add it to scope
- C) Scan it quietly and not mention it
- D) Scan it and only report if you find something

**Why?** ______________

---

## **Quick Quiz (5 minutes)**

1. **What does `-sn` do?**
   - A) Slow scan
   - B) Ping sweep / host discovery, no port scan
   - C) Scan named hosts only
   - D) Stealth nmap

2. **Why does a SYN scan (`-sS`) need root?**
   - A) It writes to system logs
   - B) It crafts raw SYN packets needing raw sockets
   - C) It is the only "legal" scan
   - D) It downloads scripts

3. **Which flag identifies the product and version behind a port?**
   - A) `-O`
   - B) `-sV`
   - C) `-sC`
   - D) `-f`

4. **Which flag saves normal, XML, and grepable files all at once?**
   - A) `-oN`
   - B) `-oX`
   - C) `-oG`
   - D) `-oA`

5. **True/False: A host with no open ports can still be "Up" in a host-discovery scan.**
   - True / False

---

## **Cleanup**

```bash
# Leave the attacker
exit

# Stop and remove the lab
docker compose down
```

---

## **Summary**
Today you learned:
✓ Host discovery and the "silent host" nuance
✓ The difference between `-sS` and `-sT`
✓ Service/version and OS fingerprinting
✓ Running NSE scripts safely
✓ Timing/stealth trade-offs (`-T`, `-f`)
✓ Saving output and writing a one-page scan report

**Remember:** These skills are for defending systems and closing out authorized
engagements — never for scanning networks you don't own or weren't paid to test.
