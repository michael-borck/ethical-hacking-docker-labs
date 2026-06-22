# Week 5: System and Network Enumeration
## CYB204 Ethical Hacking — Student Worksheet

---

## Before We Start (5 minutes)

### Important Rules
✅ **DO:** Only enumerate targets within this lab environment
✅ **DO:** Record everything — enumeration output feeds directly into pentest reports
✅ **DO:** Try both unauthenticated and authenticated queries where applicable
❌ **DON'T:** Attempt enumeration against any real systems without written permission
❌ **DON'T:** Move on to exploitation — enumeration is this week's focus

### Why Enumeration Matters
Scanning (Week 4) tells you what ports are open. Enumeration tells you *what's running on them* — usernames, groups, shares, database names, software versions. This is the intelligence that drives every subsequent attack phase.

---

## Setup (5 minutes)

```bash
# Start the lab (from repo root)
make run-week5

# Wait ~30 seconds for attacker to install tools, then enter it
docker exec -it week5-attacker bash

# Verify all targets are reachable
for ip in 172.50.0.10 172.50.0.11 172.50.0.12; do
    echo -n "$ip: "; ping -c 1 -W 1 $ip > /dev/null && echo "UP" || echo "DOWN"
done
```

**Are all three targets up?**  ✓ Yes  ✓ No

---

## Part 1: LDAP Enumeration (25 minutes)

LDAP (Lightweight Directory Access Protocol) stores user accounts, groups, and organisational data. It is common in corporate environments (Active Directory is LDAP-based).

### Exercise 1.1: Unauthenticated LDAP Listing

```bash
# Check if port 389 is open
nmap -p 389 172.50.0.10

# Attempt anonymous LDAP bind and list base DN
ldapsearch -x -H ldap://172.50.0.10 -b "dc=cybercorp,dc=local"
```

**Did the anonymous query return results?**  ✓ Yes  ✓ No

**What is the base DN (Distinguished Name) of the directory?**

_________________________________

---

### Exercise 1.2: Authenticated LDAP Enumeration

```bash
# Bind as readonly user and list all objects
ldapsearch -x -H ldap://172.50.0.10 \
  -D "cn=readonly,dc=cybercorp,dc=local" \
  -w readonly123 \
  -b "dc=cybercorp,dc=local" \
  "(objectClass=*)"
```

**List all usernames (uid attributes) you find:**

| Username | Full Name (cn) |
|----------|---------------|
|          |               |
|          |               |
|          |               |

---

### Exercise 1.3: LDAP with Nmap Scripts

```bash
# Nmap LDAP enumeration scripts
nmap -p 389 --script ldap-rootdse 172.50.0.10
nmap -p 389 --script ldap-search --script-args \
  'ldap.base="dc=cybercorp,dc=local"' 172.50.0.10
```

**What does `ldap-rootdse` reveal about the server?**

_________________________________

**Question:** An attacker finds a corporate LDAP server that allows anonymous bind. What information could they extract, and how would that help them?

_________________________________

---

## Part 2: MySQL Enumeration (25 minutes)

### Exercise 2.1: Banner Grab and Port Check

```bash
# Check MySQL port
nmap -p 3306 -sV 172.50.0.11

# Banner grab with netcat
echo "" | nc -w 2 172.50.0.11 3306 | strings
```

**What MySQL version is running?**

_________________________________

---

### Exercise 2.2: Nmap MySQL Scripts

```bash
# Enumerate databases (unauthenticated)
nmap -p 3306 --script mysql-databases 172.50.0.11

# Try default credentials
nmap -p 3306 --script mysql-brute --script-args \
  brute.firstonly=true 172.50.0.11
```

**Did the script find any accessible databases?**  ✓ Yes  ✓ No

**What credentials (if any) did mysql-brute find?**

_________________________________

---

### Exercise 2.3: Authenticated MySQL Enumeration

```bash
# Connect with known credentials
mysql -h 172.50.0.11 -u dbuser -pdbpass123

# Inside MySQL shell:
SHOW DATABASES;
USE corpdb;
SHOW TABLES;
SELECT * FROM employees;
SELECT * FROM systems;
EXIT;
```

**List the databases visible to `dbuser`:**

_________________________________

**What employee usernames did you find in the `employees` table?**

_________________________________

**Question:** Why is it dangerous to store employee usernames and email addresses in a database accessible from the network, even if it requires authentication?

_________________________________

---

## Part 3: SMB/Samba Enumeration (25 minutes)

### Exercise 3.1: Nmap SMB Scripts

```bash
# Enumerate SMB shares and info
nmap -p 445 --script smb-enum-shares,smb-enum-users,smb-os-discovery 172.50.0.12
```

**What shares are listed?**

| Share Name | Type | Comment |
|------------|------|---------|
|            |      |         |
|            |      |         |
|            |      |         |

**Were any users enumerated?**  ✓ Yes  ✓ No

---

### Exercise 3.2: enum4linux

`enum4linux` is a wrapper around Samba tools that automates common SMB enumeration tasks.

```bash
# Full enum4linux scan
enum4linux -a 172.50.0.12
```

This will take 30–60 seconds. Look through the output for:

**Workgroup/Domain:**  _________________________________

**Server description:**  _________________________________

**User accounts found:**

_________________________________

**Shares found:**

_________________________________

---

### Exercise 3.3: Access Shares with smbclient

```bash
# List shares anonymously
smbclient -L //172.50.0.12 -N

# Access the public share as guest
smbclient //172.50.0.12/public -N

# Inside smbclient:
ls
get notice.txt
exit
```

**What file(s) are in the public share?**

_________________________________

**Try to access the private share as alice:**

```bash
smbclient //172.50.0.12/private -U alice%alice123
ls
exit
```

**Can alice access the private share?**  ✓ Yes  ✓ No

**Question:** What would an attacker do with the list of SMB users they just enumerated?

_________________________________

---

## Part 4: Cross-Service Intelligence (15 minutes)

Real engagements require connecting findings across services — a username from LDAP might work on SSH, MySQL, or SMB.

### Exercise 4.1: Build a User List

Combine all usernames collected from LDAP, MySQL, and SMB into one list:

```bash
# Create a combined user list
echo "alice
bob
jsmith
mjones
awilson
tbrown" > /tmp/users.txt

cat /tmp/users.txt
```

**How many unique usernames did you collect across all three services?** _____

---

### Exercise 4.2: Cross-Reference Services

Answer from your enumeration notes:

| Username | Found in LDAP? | Found in MySQL? | Found in SMB? |
|----------|---------------|----------------|--------------|
| alice    |               |                |              |
| bob      |               |                |              |

**Question:** If you found the same username in both LDAP and SMB, what would you try next (without exploiting anything yet)?

_________________________________

---

## Part 5: Ethics and Reporting (10 minutes)

### Discussion Questions

1. **Passive vs. Active:** LDAP enumeration requires sending probes to the target. How would you log your activity to show a client you stayed within scope?

   _________________________________

2. **Data handling:** You've just pulled a list of employee names and email addresses from a corporate database. What are your legal and ethical obligations regarding this data?

   _________________________________

3. **Least privilege:** The MySQL `dbuser` account can read the `employees` table. What database hardening step would have prevented this?

   _________________________________

---

## Quick Knowledge Check

1. What port does LDAP typically use?
   - A) 22  B) 389  C) 443  D) 3306

2. What does `enum4linux -a` do?
   - A) Scans for open ports  B) Runs all SMB enumeration modules  C) Brute-forces SMB  D) Dumps LDAP

3. True/False: An anonymous LDAP bind should always be disabled on internet-facing servers.

4. What MySQL command lists all databases?
   - A) `LIST DATABASES;`  B) `SHOW DATABASES;`  C) `SELECT * FROM DATABASES;`  D) `ENUM DATABASES;`

5. Which tool specifically targets SMB enumeration on Linux?
   - A) ldapsearch  B) nmap  C) enum4linux  D) hydra

---

## Cleanup

```bash
exit
cd labs/week5 && docker compose down
```

---

## Summary

Today you learned to:
✓ Enumerate LDAP directories for user accounts and organisational data
✓ Identify and access MySQL databases to extract schema and data
✓ Use enum4linux and smbclient to map SMB shares and users
✓ Combine cross-service findings into a unified user list
✓ Explain why enumeration data requires careful handling

**Instructor Contact:** _________________________________
