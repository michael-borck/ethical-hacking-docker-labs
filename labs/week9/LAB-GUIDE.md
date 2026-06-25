# Week 9: Lateral Movement & Pivoting

## Lab Scenario
You have a foothold on **bastion**, a dual‑homed jump box that sits on two networks. Behind it
is a corporate intranet the customer wants you to prove is reachable. You are **not** allowed
to add new routes or touch firewalls — you must **pivot** through the bastion using SSH
tunnels. Your workstation (`attacker`) can only see the external segment.

**Time:** ~50 minutes — work through each part and capture the flag.

---

## Before We Start (5 minutes)

### Important Rules
✅ **DO:** Pivot only inside this isolated Docker lab
✅ **DO:** Use the provided weak credentials (`jump` / `jump3r!`, db root `int3rnal`) — they are fake
✅ **DO:** Ask for help if a tunnel does not come up
❌ **DON'T:** Run these tunneling techniques against any network you do not own or are not **authorized** to test
❌ **DON'T:** Leave tunnels open on real systems after an engagement

### Quick Setup
```bash
# 1. From the repo root, build the shared image once
make build-base

# 2. Start the week 9 lab
cd labs/week9
docker compose up -d

# 3. Enter the attacker (all pivoting happens from here)
docker exec -it week9-attacker bash

# 4. Confirm you are the attacker
hostname
```
**Expected output of `hostname`:** _________________

**Check:** Did the prompt appear?   ✓ Yes   ✓ No

---

## Part 1: Map the Network (8 minutes)

### Exercise 1.1 — Draw the topology
Using the host table below, sketch the two segments. The attacker and bastion share the
external segment; the bastion and the three internal hosts share the internal segment.

| Host | External IP | Internal IP |
|------|-------------|-------------|
| attacker | 172.23.0.2 | — |
| bastion (pivot-host) | 172.23.0.3 | 172.24.0.3 |
| internal-web | — | 172.24.0.4 |
| internal-db | — | 172.24.0.5 |
| internal-flag | — | 172.24.0.6 |

Draw your diagram on the back of this sheet (or below):

```
   (sketch attacker → bastion → internal-web / internal-db / internal-flag)
```

### Exercise 1.2 — Which hosts can the attacker see directly?
From inside the attacker container, run:
```bash
ping -c 2 172.23.0.3
ping -c 2 172.24.0.4
ping -c 2 172.24.0.5
ping -c 2 172.24.0.6
```
Fill in the table (✓ reachable / ✗ no route):

| Target | IP | Directly reachable from attacker? |
|--------|----|-----------------------------------|
| bastion | 172.23.0.3 | ☐ Yes ☐ No |
| internal-web | 172.24.0.4 | ☐ Yes ☐ No |
| internal-db | 172.24.0.5 | ☐ Yes ☐ No |
| internal-flag | 172.24.0.6 | ☐ Yes ☐ No |

**Why can't the attacker reach 172.24.0.x?** (circle all that apply)
- A) The internal hosts are powered off
- B) The attacker has no network interface on the 172.24.0.0/24 segment
- C) A firewall is blocking it
- D) The two Docker bridges are isolated from each other

### Exercise 1.3 — Confirm with curl
```bash
curl --connect-timeout 5 http://172.24.0.4
```
**What error did you get?** _________________________________

This proves segmentation works. To reach the internal hosts we must relay through the
**bastion**, which is the only host with a foot on both networks.

---

## Part 2: SSH Local Forward — One Port (10 minutes)

A **local forward** maps a port on your machine to a `host:port` that the bastion can reach.

`ssh -L <local_port>:<target_host>:<target_port> jump@172.23.0.3`

### Exercise 2.1 — Build the tunnel
```bash
# -N = tunnel only, no shell    -f = background
sshpass -p 'jump3r!' ssh -N -f \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -L 8080:172.24.0.4:80 jump@172.23.0.3
```
**Did the command return to a prompt?**   ✓ Yes   ✓ No

### Exercise 2.2 — Use the tunnel
```bash
curl http://localhost:8080
```
**What page title do you see?** _________________________________

### Exercise 2.3 — Hostname resolves where?
```bash
sshpass -p 'jump3r!' ssh -N -f -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -L 8082:internal-web:80 jump@172.23.0.3
curl http://localhost:8082
```
**Did `internal-web` resolve even though the attacker cannot resolve it?**   ✓ Yes   ✓ No

**Explain (circle one):** the name `internal-web` is resolved…
- A) on the attacker, using its DNS
- B) on the bastion, because the bastion makes the final connection to the target

---

## Part 3: SSH Dynamic (SOCKS) Forward + proxychains (12 minutes)

A local forward is 1:1 (one port). A **dynamic forward** (`-D`) turns the bastion into a SOCKS5
proxy so *any* tool can reach *any* internal `host:port` through one tunnel.

### Exercise 3.1 — Start the SOCKS proxy
```bash
sshpass -p 'jump3r!' ssh -N -f \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -D 1080 jump@172.23.0.3
```
This opened a SOCKS5 proxy on the attacker's **127.0.0.1:1080**. proxychains is already
configured to use it (`socks5 127.0.0.1 1080` in `/etc/proxychains.conf`).

### Exercise 3.2 — Route tools through the proxy
```bash
proxychains curl http://172.24.0.4
proxychains curl http://internal-web
```
**Both worked?**   ✓ Yes   ✓ No

Now scan the internal segment through the pivot:
```bash
proxychains nmap -sT -Pn -p 80,3306,8080 172.24.0.4 172.24.0.5 172.24.0.6
```
**Record open ports:**

| Host | Port | Service |
|------|------|---------|
| 172.24.0.4 | | |
| 172.24.0.5 | | |
| 172.24.0.6 | | |

### Exercise 3.3 — Hit the database through the pivot
```bash
proxychains mysql -h 172.24.0.5 -u root -pint3rnal -e 'SHOW DATABASES;'
```
**List the databases:** _________________________________

**Bonus flag — run this and record the output:**
```bash
proxychains mysql -h 172.24.0.5 -u root -pint3rnal -e 'SELECT * FROM corpdb.secrets;'
```
Bonus flag: _________________________________

---

## Part 4: Capture the Flag (5 minutes)

The `internal-flag` service (172.24.0.6:8080) replies with the lab flag to any connection.

### Exercise 4.1 — Via a local forward
```bash
sshpass -p 'jump3r!' ssh -N -f -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -L 8081:172.24.0.6:8080 jump@172.23.0.3
curl http://localhost:8081
```

### Exercise 4.2 — Via the SOCKS proxy from Part 3
```bash
proxychains curl http://172.24.0.6:8080
```

**Primary flag:** _________________________________

**How many SSH passwords did you type to reach all four internal targets?** ______
(The point of pivoting: authenticate once to the bastion, reach everything behind it.)

---

## Part 5: Reverse Tunnel (Bonus, 5 minutes)
A **remote forward** (`-R`) does the mirror image: a box with no inbound access can punch a
tunnel *out* to you. From the attacker you can demonstrate the shape:
```bash
sshpass -p 'jump3r!' ssh -N -f -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -R 9090:172.24.0.4:80 jump@172.23.0.3
```
**In your own words, what does `-R` do differently from `-L`?**

_________________________________________________
_________________________________________________

---

## Part 6: Metasploit Connection (8 minutes)

Metasploit automates exactly what you just did by hand — but **after** you have a Meterpreter
session on the bastion (no SSH needed).

**Match the SSH technique to its Metasploit equivalent (draw a line / fill the letter):**

| SSH / manual (this lab) | Metasploit |
|--------------------------|------------|
| 1. `ssh -L 8080:target:80` | ___ A) `auxiliary/server/socks_proxy` + `proxychains` |
| 2. `ssh -D 1080` + proxychains | ___ B) `post/multi/manage/autoroute` (or `route add`) |
| 3. "route internal subnet through the bastion" | ___ C) Meterpreter `portfwd` |

**Short answer:** In one sentence, why is the dual‑homed bastion the linchpin of the whole
attack in both the SSH lab and the Metasploit version?

_________________________________________________
_________________________________________________

---

## Part 7: Ethics (5 minutes)

Mark each scenario LEGAL or ILLEGAL:

| Scenario | Legal? |
|----------|--------|
| Pivoting through a box you own in this Docker lab | |
| Using `ssh -D` against a company server without permission | |
| Running `autoroute` on a customer network named in your signed scope | |
| Tunneling into a former employer's network after you quit | |
| Reporting a tunnel you accidentally found to the owner | |

**Circle the best answer.** You are on an engagement and your tunnel accidentally reaches an
out‑of‑scope subnet. You should:
- A) Keep exploring — you're already inside
- B) Stop, document it, and notify the customer immediately
- C) Delete your tunnel and say nothing
- D) Pivot further to "test their detection"

**Why?** _________________________________________________

---

## Quick Quiz (5 minutes)

1. **Which flag creates a SOCKS proxy for arbitrary tools?**
   - A) `ssh -L`
   - B) `ssh -R`
   - C) `ssh -D`
   - D) `ssh -P`

2. **Why can't the attacker curl 172.24.0.4 directly?**
   - A) Apache is down
   - B) It has no route to the 172.24.0.0/24 segment
   - C) The firewall blocks HTTP
   - D) DNS is broken

3. **In `ssh -L 8080:172.24.0.4:80 jump@172.23.0.3`, where is `172.24.0.4` resolved/connected from?**
   - A) The attacker
   - B) The bastion
   - C) Your host laptop
   - D) Docker Hub

4. **Metasploit's `autoroute` is closest to which manual step?**
   - A) Running `proxychains`
   - B) Adding a route so the internal subnet is reachable through a session
   - C) Starting Apache
   - D) Cracking a password

5. **True / False:** The internal "hosts" in this lab are Linux stand‑ins, but the pivoting
   skills transfer directly to a real Windows/AD environment.
   - True / False

---

## Lab Cleanup
```bash
docker compose down
```
- [ ] Flag captured and recorded above
- [ ] Tunnels stopped / container torn down
