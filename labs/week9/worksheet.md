# Week 9: Lateral Movement Between Systems and Services
## CYB204 Ethical Hacking — Student Worksheet

---

## Before We Start (5 minutes)

### Important Rules
✅ **DO:** Only pivot within this lab environment
✅ **DO:** Read each step before running it — pivoting involves multiple layers
✅ **DO:** Keep a note of each shell session you open (you will have several)
❌ **DON'T:** Attempt pivoting techniques on any real network without written authorisation
❌ **DON'T:** Close terminal windows mid-lab — you need active SSH sessions for tunnels

### Scenario
CyberCorp's external network has been partially compromised. You have obtained credentials for a DMZ host (`week9-pivot`). Your goal is to use that foothold to reach internal systems that are not exposed externally.

---

## Network Map

```
Your machine              Pivot host                 Internal targets
week9-attacker            week9-pivot                week9-internal-web
172.90.10.2  ───SSH──►  172.90.10.10               172.90.20.20 (HTTP)
             (can't reach)  │
                            └──────────────────────► week9-internal-db
                                                     172.90.20.21 (MySQL)
```

**Rule:** 172.90.20.x is unreachable from your attacker machine directly. Verify this first.

---

## Setup (5 minutes)

```bash
# Start the lab
make run-week9

# Enter attacker container
docker exec -it week9-attacker bash

# Confirm you CANNOT reach the internal network directly
ping -c 1 172.90.20.20
```

**Did the ping fail?**  ✓ Yes (expected)  ✓ No

If no, something is wrong — ask your instructor before continuing.

---

## Part 1: Foothold — SSH to the Pivot Host (15 minutes)

### Exercise 1.1: Verify Pivot Host is Reachable

```bash
# Check the pivot is on your network
ping -c 2 172.90.10.10

# Confirm SSH is running
nmap -p 22 172.90.10.10
```

**Is the pivot host reachable?**  ✓ Yes  ✓ No

---

### Exercise 1.2: Connect to the Pivot

```bash
# SSH into the pivot host
# Credentials: pivotuser / pivot123
ssh pivotuser@172.90.10.10
```

Accept the host key fingerprint when prompted (type `yes`).

**You should now have a shell on the pivot host.** Verify:

```bash
hostname
ip addr show
```

**What IP addresses does the pivot host have?**

| Interface | IP |
|-----------|-----|
|           |     |
|           |     |

**Question:** Why does the pivot host have two IP addresses?

_________________________________

---

### Exercise 1.3: Scout the Internal Network from the Pivot

From your SSH session on the pivot host:

```bash
# Check what's on the internal network
ip route
ping -c 1 172.90.20.20
ping -c 1 172.90.20.21
```

**Can the pivot host reach the internal targets?**  ✓ Yes  ✓ No

**Leave this SSH session open in a separate terminal tab** — you'll need it.

---

## Part 2: SSH Port Forwarding (25 minutes)

### Exercise 2.1: Local Port Forward (Single Service)

Open a **new terminal tab** on your attacker machine and run:

```bash
docker exec -it week9-attacker bash

# Forward local port 8080 to the internal web server via the pivot
# This creates: attacker:8080 → pivot:22 → internal-web:80
ssh -L 8080:172.90.20.20:80 pivotuser@172.90.10.10 -N -f
```

The `-N` flag means "no command", `-f` backgrounds the tunnel.

Now test the tunnel:

```bash
# Access the internal web server via the forwarded port
curl http://127.0.0.1:8080
```

**What does the internal web page say?**

_________________________________

**Question:** From an attacker's perspective, what information would you look for on an internal web admin portal?

_________________________________

---

### Exercise 2.2: Local Port Forward (Database)

```bash
# Forward local port 3307 to the internal MySQL server
ssh -L 3307:172.90.20.21:3306 pivotuser@172.90.10.10 -N -f

# Connect to the internal MySQL via the tunnel
mysql -h 127.0.0.1 -P 3307 -u appuser -papppass456
```

If mysql client is not in the Metasploit container, use nmap to confirm connectivity:

```bash
nmap -p 3307 127.0.0.1
```

**Is the MySQL port accessible through the tunnel?**  ✓ Yes  ✓ No

---

## Part 3: SOCKS Proxy (Dynamic Port Forwarding) (20 minutes)

A SOCKS proxy lets you route *all* your traffic through the tunnel, not just one port.

### Exercise 3.1: Set Up a SOCKS5 Proxy

```bash
# Open a SOCKS5 proxy on local port 1080
# All traffic sent to this proxy will tunnel through the pivot
ssh -D 1080 pivotuser@172.90.10.10 -N -f

# Check it's listening
ss -tlnp | grep 1080
```

**Is the SOCKS proxy listening on port 1080?**  ✓ Yes  ✓ No

---

### Exercise 3.2: Route Traffic via Proxychains

```bash
# Test proxychains reaches internal web through SOCKS proxy
proxychains curl http://172.90.20.20

# Scan internal network through the proxy
proxychains nmap -sT -Pn 172.90.20.0/24
```

**What hosts did proxychains nmap find?**

_________________________________

**Question:** Why do we use `-sT` (full connect) instead of `-sS` (SYN) with proxychains?

_________________________________

---

## Part 4: Metasploit Route and Pivot (25 minutes)

Metasploit has built-in pivoting support via the `route` command once you have a session.

### Exercise 4.1: Start msfconsole

```bash
msfconsole
```

### Exercise 4.2: Set Up an SSH Session as a Route

```bash
# Use the SSH login module
use auxiliary/scanner/ssh/ssh_login
set RHOSTS 172.90.10.10
set USERNAME pivotuser
set PASSWORD pivot123
run
```

**Did the module create a session?**  ✓ Yes  ✓ No  (Session ID: ______)

---

### Exercise 4.3: Add a Route Through the Session

```bash
# In msfconsole — route all 172.90.20.0/24 traffic through session 1
route add 172.90.20.0/255.255.255.0 1

# Verify route
route print
```

---

### Exercise 4.4: Scan Through the Route

```bash
# Now scan the internal network via the Metasploit route
use auxiliary/scanner/portscan/tcp
set RHOSTS 172.90.20.0/24
set PORTS 22,80,443,3306,8080
run
```

**What ports did you find on the internal hosts?**

| Host | Open Ports |
|------|------------|
| 172.90.20.20 | |
| 172.90.20.21 | |

---

## Part 5: Ethics and Documentation (10 minutes)

### Discussion Questions

1. **Scope creep:** You're authorised to test `cybercorp.com.au`'s external network. Through pivoting you discover servers on an internal 10.0.0.0/8 range. What do you do before testing those?

   _________________________________

2. **Evidence:** Why is it important to log every pivot command with timestamps during a real engagement?

   _________________________________

3. **Clean-up:** After a real pentest, why must you remove all SSH tunnels, proxy listeners, and Metasploit routes you created?

   _________________________________

---

## Quick Knowledge Check

1. What SSH flag creates a local port forward?
   - A) `-R`  B) `-L`  C) `-D`  D) `-N`

2. What SSH flag creates a SOCKS proxy (dynamic forwarding)?
   - A) `-L`  B) `-R`  C) `-D`  D) `-T`

3. Why can't the attacker reach 172.90.20.x directly in this lab?
   - A) Firewall rules  B) The internal network is `internal: true` (no external routing)  C) Different VLAN  D) All of the above

4. What Metasploit command routes traffic through an active session?
   - A) `pivot add`  B) `route add`  C) `tunnel set`  D) `proxy add`

5. True/False: You must have valid credentials to pivot — you cannot pivot using a reverse shell.

---

## Cleanup

```bash
# Kill any background SSH processes
pkill -f "ssh -"
exit

# Stop the lab
cd labs/week9 && docker compose down
```

---

## Summary

Today you learned to:
✓ Identify a pivot host that straddles two networks
✓ Use SSH local port forwarding to access internal services
✓ Set up a SOCKS5 proxy for dynamic routing with proxychains
✓ Configure Metasploit routes for internal network scanning
✓ Explain the legal and documentation requirements for pivoting

**Instructor Contact:** _________________________________
