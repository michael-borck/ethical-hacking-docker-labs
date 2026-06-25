# Week 5: System and Network Enumeration — Student Worksheet
## CYB204 Ethical Hacking · Beginner Lab

Name: ______________________   Date: ____________   Partner: __________________

---

## **Before We Start (5 minutes)**

### **Important Rules**
✅ **DO:** Only enumerate inside this Docker lab network (`172.22.0.0/24`)
✅ **DO:** Write down what you find — the worksheet is your report
✅ **DO:** Ask for help if a command errors or a service will not respond
✅ **DO:** Treat every leaked credential as a real finding to report
❌ **DON'T:** Point these tools at any network you do not own
❌ **DON'T:** Reuse a password you discover on a real account
❌ **DON'T:** Skip SNMP because it is "just UDP" — it leaks a lot
❌ **DON'T:** Share found credentials outside of class

### **Quick Setup**
```bash
# Step 1: build the shared Kali base once (from the repo root)
make build-base

# Step 2: start the lab
cd labs/week5
docker compose up -d

# Step 3: wait ~30-60s for the attacker to install tools, then enter it
docker exec -it week5-attacker bash

# Step 4: confirm you can see the targets
nmap -sn 172.22.0.0/24
```

**Check:** Do you see hosts at .2 .10 .11 .12 .13 .14 .15 ?  ✓ Yes  ✓ No

---

## **Part 1: Host & Service Discovery (10 minutes)**

### **Exercise 1.1: Who is alive?**
```bash
nmap -sn 172.22.0.0/24
```
**How many hosts responded?** _________________

### **Exercise 1.2: What services are open?**
```bash
nmap -sV -p389,445,3306 172.22.0.10 172.22.0.12 172.22.0.13
nmap -sU -p161 172.22.0.14
```
**Fill in the table:**
| Host (IP)    | Port | Service name | Version |
|--------------|------|--------------|---------|
| 172.22.0.10  | 389  |              |         |
| 172.22.0.12  | 3306 |              |         |
| 172.22.0.13  | 445  |              |         |
| 172.22.0.14  | 161  |              |  (SNMP) |

---

## **Part 2: LDAP Enumeration (15 minutes)**

### **Exercise 2.1: Anonymous directory search**
```bash
ldapsearch -x -H ldap://172.22.0.10 -b dc=enum,dc=lab
```
**What is the organisation name in the directory?** _________________

**How many `inetOrgPerson` (user) entries did you find?** _________________

### **Exercise 2.2: Read specific attributes**
```bash
ldapsearch -x -H ldap://172.22.0.10 -b dc=enum,dc=lab \
  '(objectClass=inetOrgPerson)' cn mail title description
```
**List the usernames and their titles:**
| uid          | cn (full name) | title |
|--------------|----------------|-------|
| jdoe         |                |       |
| asmith       |                |       |
| adminservice |                |       |
| mharrison    |                |       |

### **Exercise 2.3: The leaked credential 🎯**
Look at the **`description`** attribute of the `adminservice` account.

**What is the leaked backup password?** _________________________________

**Where else does the password appear (you'll confirm in Part 4)?**
(Circle one)  MySQL / SNMP / nowhere else

### **Exercise 2.4: Browse with a GUI**
Open **http://localhost:14081** and log in with DN `cn=admin,dc=enum,dc=lab`,
password `admin`. Navigate to `ou=groups` and back to `ou=people`.

**Which group is `adminservice` a member of?** _________________

---

## **Part 3: SMB Enumeration (15 minutes)**

### **Exercise 3.1: List the shares (anonymous)**
```bash
smbclient -L //172.22.0.13 -N
```
**List the shares you can see (name + comment):**
| Share name | Type | Comment |
|------------|------|---------|
|            |      |         |
|            |      |         |

### **Exercise 3.2: Anonymous read of the public share**
```bash
smbclient //172.22.0.13/public -N -c 'ls; get WELCOME.txt -'
```
**What does the WELCOME.txt file say the share is for?**
_________________________________

### **Exercise 3.3: Authenticated access to the staff share**
```bash
smbclient //172.22.0.13/staff -U 'jdoe%Summer2024!' -c 'ls'
```
**Were you able to list files as jdoe?**  ✓ Yes  ✓ No

**What happens if you use the WRONG password?** (Circle one)
- It still lets you in (anonymous fallback)
- Access is denied (NT_STATUS_LOGON_FAILURE)

### **Exercise 3.4: enum4linux — one tool, lots of output**
```bash
enum4linux 172.22.0.13        # if this is missing, run:  enum4linux-ng -A 172.22.0.13
```
**enum4linux tries to pull (check all that apply):**
- [ ] Share list
- [ ] User/group list
- [ ] OS / workgroup info
- [ ] Password policy
- [ ] Running processes

---

## **Part 4: MySQL Enumeration (15 minutes)**

### **Exercise 4.1: Connect and list databases**
```bash
mysql -h 172.22.0.12 -u root -p'enumR0ot'
```
At the `mysql>` prompt:
```bash
SHOW DATABASES;
```
**Which databases exist?** _________________________________

### **Exercise 4.2: Map the tables**
```bash
USE employees;
SHOW TABLES;
```
**List the tables:** _________________________________

### **Exercise 4.3: Find the sensitive data 🎯**
```bash
SELECT * FROM system_config;
SELECT * FROM salaries;
```
**What `backup_pw` is stored in `system_config`?** _________________________________

**Does it match the LDAP leak from Part 2.3?**  ✓ Yes (same password)  ✓ No

**Why is the `salaries` table a problem to leave exposed?**
_________________________________

---

## **Part 5: SNMP Enumeration (15 minutes)**

### **Exercise 5.1: Walk the agent**
```bash
snmpwalk -v2c -c public 172.22.0.14
```
**This worked with the community string `public`. Is that good security?**
(Circle one)  Yes — it's convenient  /  No — it's a weak default

### **Exercise 5.2: Read system information**
```bash
snmpget -v2c -c public 172.22.0.14 1.3.6.1.2.1.1.1.0   # sysDescr
snmpget -v2c -c public 172.22.0.14 1.3.6.1.2.1.1.5.0   # sysName
snmpget -v2c -c public 172.22.0.14 1.3.6.1.2.1.1.4.0   # sysContact
snmpget -v2c -c public 172.22.0.14 1.3.6.1.2.1.1.6.0   # sysLocation
```
**Fill in the device profile:**
| Field        | Value you found |
|--------------|-----------------|
| sysDescr (vendor/model) |          |
| sysName      |                 |
| sysContact   |                 |
| sysLocation  |                 |

**What kind of device is this?** (Circle one)  Router / Server / Printer / Switch

### **Exercise 5.3: Interfaces**
```bash
snmpwalk -v2c -c public 172.22.0.14 IF-MIB::ifDescr
```
**How many interfaces does it report?** _________________

---

## **Part 6: Correlate & Report (10 minutes)**

### **Exercise 6.1: Connect the dots**
The same secret appeared in **two** services. Describe the chain an attacker
could follow from "SNMP responds to `public`" all the way to sensitive payroll:

1. SNMP gives device/contact info → reveals `noc@enum.lab`.
2. _________________  (what LDAP leaked)
3. _________________  (where MySQL repeated it)
4. _________________  (what SMB access that password may grant)

### **Exercise 6.2: Fix it — recommendations**
For each service, write one hardening recommendation:
| Service | One thing to fix |
|---------|------------------|
| LDAP    |                  |
| SMB     |                  |
| MySQL   |                  |
| SNMP    |                  |

---

## **Ethics (5 minutes)**

Mark each scenario LEGAL or ILLEGAL:

| Scenario                                                              | Legal? |
|-----------------------------------------------------------------------|--------|
| Enumerating this Docker lab                                           |        |
| Running `snmpwalk -c public` against your home router                 |        |
| `ldapsearch` on a company's server because it answered anonymously    |        |
| Enumerating a system named in your signed engagement scope            |        |
| Using a password you found to log into a real account                 |        |
| Dumping a client's `salaries` table to your personal laptop           |        |

**Scenario:** During the lab you recover the `adminservice` backup password.
A classmate asks you to send it to them over Discord. What do you do and why?
_______________________________________________________________

---

## **Quick Quiz (5 minutes)**

1. **What does enumeration come AFTER?**
   - A) Reporting
   - B) Discovery / scanning
   - C) Exploitation
   - D) Cleanup

2. **`ldapsearch -x` uses which bind method by default (no -D given)?**
   - A) Simple + anonymous
   - B) SASL/GSSAPI
   - C) TLS client cert
   - D) None — it always needs a password

3. **Which command lists SMB shares anonymously?**
   - A) `smbclient //host -L`
   - B) `smbclient -L //host -N`
   - C) `smbwalk //host`
   - D) `nmap --script smb-all //host`

4. **The SNMP community string acts most like a…**
   - A) Username
   - B) Password
   - C) Port number
   - D) MAC address

5. **True/False: A weak SNMP community string can expose the device model, uptime, contacts and interfaces.**
   - True / False

6. **Which MySQL statement lists the tables in the current database?**
   - A) `LIST TABLES;`
   - B) `SHOW TABLES;`
   - C) `DESCRIBE DB;`
   - D) `SELECT * FROM tables;`

---
**Total lab time ≈ 95 minutes.**  Keep this worksheet as your engagement record.

**Instructor contact:** _________________________________
