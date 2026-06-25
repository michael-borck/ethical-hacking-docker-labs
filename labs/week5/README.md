# Week 5: System and Network Enumeration Lab

## Overview
This lab teaches **enumeration** — the phase where, after discovering live
hosts and open ports, you query each service to learn *what it is and what it
knows*. You practise against four classic enterprise services — LDAP, SMB,
MySQL and SNMP — running in an isolated Docker network. The same leaked
credential appears in two places (LDAP and MySQL), which is exactly the kind
of finding real engagements produce.

## Learning Objectives
- Enumerate an LDAP directory with `ldapsearch` and read directory attributes.
- Enumerate SMB shares with `smbclient` and `enum4linux` (anonymous + authenticated).
- Enumerate a MySQL database with the `mysql` client and discover sensitive tables.
- Enumerate an SNMP agent with `snmpwalk` and read system/interface information.
- Tie host discovery to `nmap` NSE scripts for each service.

## Setup (3 min)
1. Build the shared base (once, from the repo root): `make build-base`
2. Start the lab:
   ```bash
   cd labs/week5
   docker compose up -d
   ```
3. Wait ~30-60 s for the attacker to install tools, then enter it:
   ```bash
   docker exec -it week5-attacker bash
   ```
4. Useful entry points from your host browser/terminal:
   - phpLDAPadmin web UI: **http://localhost:14081** — login DN
     `cn=admin,dc=enum,dc=lab`, password `admin`
   - LDAP on the host: `ldap://localhost:1389`  (container `172.22.0.10:389`)
   - MySQL on the host: `localhost:23306`  (container `172.22.0.12:3306`, root / `enumR0ot`)

> **Note:** SMB (`445/tcp`) and SNMP (`161/udp`) are **internal-only** on the
> `enum_net` network and are not published to your host. Reach them from inside
> the attacker container at `172.22.0.13` and `172.22.0.14`.

### Lab network (172.22.0.0/24)
| Host              | IP            | Service                         | Reach from host? |
|-------------------|---------------|---------------------------------|------------------|
| attacker          | 172.22.0.2    | Kali (`ethical-base`)           | `docker exec`    |
| ldap              | 172.22.0.10   | OpenLDAP (`dc=enum,dc=lab`)     | `localhost:1389` |
| ldap-admin        | 172.22.0.11   | phpLDAPadmin UI                 | `localhost:14081`|
| mysql             | 172.22.0.12   | MySQL 8 (`employees` db)        | `localhost:23306`|
| smb               | 172.22.0.13   | Samba (`public`, `staff`)       | internal only    |
| snmp              | 172.22.0.14   | SNMP simulator (community `public`)| internal only |
| netshoot          | 172.22.0.15   | network toolbox                 | `docker exec`    |

## Activities
Run everything from inside the attacker container unless a step says otherwise.

### 1. Host discovery + service fingerprinting (10 min)
Confirm the targets and the services behind each open port.
```bash
nmap -sn 172.22.0.0/24                       # who is alive?
nmap -sV -p- 172.22.0.10 172.22.0.12 172.22.0.13  # versions on ldap/mysql/smb
nmap -sU -p161 -sV 172.22.0.14               # SNMP is UDP
```
**Try:** point NSE at each service:
```bash
nmap -p389 --script ldap-search 172.22.0.10
nmap -p445 --script smb-enum-shares,smb-os-discovery 172.22.0.13
nmap -p3306 --script mysql-info 172.22.0.12 --script-args mysqluser=root,mysqlpass=enumR0ot
nmap -sU -p161 --script snmp-sysdescr,snmp-interfaces 172.22.0.14
```

### 2. LDAP enumeration (15 min)
Anonymous search is enabled. Dump the directory and read attributes.
```bash
ldapsearch -x -H ldap://172.22.0.10 -b dc=enum,dc=lab
# Just the users and their mail/title:
ldapsearch -x -H ldap://172.22.0.10 -b dc=enum,dc=lab '(objectClass=inetOrgPerson)' cn mail title description
# List groups and members:
ldapsearch -x -H ldap://172.22.0.10 -b 'ou=groups,dc=enum,dc=lab' cn member
```
🎯 **Key finding:** the `adminservice` account's `description` leaks a backup
password. Write it down — it should match a secret you find in MySQL later.
You can also browse the tree visually at **http://localhost:14081**.

### 3. SMB enumeration (15 min)
List shares anonymously, then connect to the public share and enumerate the host.
```bash
smbclient -L //172.22.0.13 -N                 # list shares, anonymous (-N)
smbclient //172.22.0.13/public -N -c 'ls; get WELCOME.txt -'   # anon read
# Authenticated access to the 'staff' share as jdoe:
smbclient //172.22.0.13/staff -U 'jdoe%Summer2024!' -c 'ls'
```
Now let a tool do the walking (tries null sessions, users, shares, OS info):
```bash
enum4linux 172.22.0.13            # classic (perl). If missing, use:
enum4linux-ng -A 172.22.0.13      # the maintained python rewrite
```

### 4. MySQL enumeration (15 min)
Connect and map the database — find the tables, then the sensitive one.
```bash
mysql -h 172.22.0.12 -u root -p'enumR0ot'
# inside the mysql> prompt:
SHOW DATABASES;
USE employees;
SHOW TABLES;
SELECT * FROM employees;
SELECT * FROM system_config;        # <-- leaks the same backup password
SELECT * FROM salaries;             # <-- sensitive payroll data
exit
```
Reflect: what business impact does exposing `salaries`/`system_config` have?

### 5. SNMP enumeration (15 min)
SNMP returns a surprising amount of device detail for a single community string.
```bash
snmpwalk -v2c -c public 172.22.0.14                 # the whole tree
snmpwalk -v2c -c public 172.22.0.14 SNMPv2-MIB::system   # system group
snmpwalk -v2c -c public 172.22.0.14 IF-MIB::interfaces   # interfaces
# Individual values:
snmpget -v2c -c public 172.22.0.14 1.3.6.1.2.1.1.5.0    # sysName
snmpget -v2c -c public 172.22.0.14 1.3.6.1.2.1.1.1.0    # sysDescr (device/model)
```
What device is this? What is its uptime, contact, and how many interfaces?

### 6. Correlate findings (10 min)
Combine the leaked LDAP/MySQL backup password with the SMB `staff` share and
the SNMP contact address. In a real engagement these threads link one weak
service to broader access. **Document every finding in `STUDENT-WORKSHEET.md`.**

## Cleanup
```bash
docker compose down          # from labs/week5
```
**Ethics**: Educational use only. This is an isolated Docker network with
fabricated data — no real credentials, no real organisations. Enumerating any
system you do not own or do not have **written authorization** to test is
illegal.

Generated with Claude Code.
