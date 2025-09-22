# De-ICE S1.100 - Student Lab Worksheet

**Name:** _________________________ **Date:** _____________

## Lab Scenario
You have been hired to perform a penetration test on De-ICE Corporation's web server. The CEO believes the system is secure since they run regular Nessus scans. Your job is to prove that automated scanning isn't enough.

**Time Limit:** 2 hours  
**Submission:** Complete this worksheet and submit your findings

## Pre-Lab Setup
□ Start the lab environment: `docker compose up -d`  
□ Access attacker machine: `docker exec -it de-ice-attacker bash`  
□ Verify you're in the Kali container: `whoami` (should show "root")

---

## Phase 1: Reconnaissance (20 points)

### 1.1 Network Discovery
Run a network scan to identify all hosts in the lab network.

**Command used:**
```bash
_________________________________________________
```

**Hosts discovered:**
| IP Address | Hostname | Status |
|------------|----------|---------|
| | | |
| | | |
| | | |

### 1.2 Port Scanning
Scan the target services for open ports.

**Command used:**
```bash
_________________________________________________
```

**Open ports discovered:**
| Host | Port | Service | Version |
|------|------|---------|---------|
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |

---

## Phase 2: Web Application Enumeration (15 points)

### 2.1 Web Content Analysis
Examine the web application for useful information.

**Command used:**
```bash
_________________________________________________
```

**Employee information discovered:**
| Full Name | Email | Potential Username |
|-----------|-------|-------------------|
| | | |
| | | |
| | | |
| | | |
| | | |

### 2.2 Username Generation
Based on the naming convention, create a username list.

**Username list created:** □ Yes □ No

**File location:** _________________________________

---

## Phase 3: FTP Enumeration (15 points)

### 3.1 FTP Access
Attempt to access the FTP service.

**Connection command:**
```bash
_________________________________________________
```

**Authentication method:** _______________________

**Success:** □ Yes □ No

### 3.2 FTP File Discovery
Explore the FTP directory structure and identify interesting files.

**Directories found:**
_________________________________________________

**Files discovered:**
| Filename | Size | Location | Downloaded |
|----------|------|----------|------------|
| | | | □ |
| | | | □ |
| | | | □ |

---

## Phase 4: SSH Attack (25 points)

### 4.1 Password List Creation
Create a password list for brute force attacks.

**Common passwords included:**
□ password  □ 123456  □ admin  □ root  □ Other: ____________

**Password list file:** _________________________________

### 4.2 SSH Brute Force
Perform a brute force attack against the SSH service.

**Command used:**
```bash
_________________________________________________
```

**Successful credentials found:**
Username: _________________ Password: _________________

### 4.3 SSH Access
Log into the system with discovered credentials.

**Login successful:** □ Yes □ No

**User privileges discovered:**
```bash
whoami: _________________
id: _____________________
```

---

## Phase 5: File Analysis (15 points)

### 5.1 System Exploration
Explore the system for interesting files.

**Commands used:**
```bash
_________________________________________________
_________________________________________________
```

**Interesting files found:**
_________________________________________________

### 5.2 File Decryption
Attempt to decrypt any encrypted files found.

**Encrypted file:** _________________________________

**Decryption attempts:**
| Password Tried | Success |
|----------------|---------|
| | □ |
| | □ |
| | □ |

**Successful decryption password:** ____________________

**Decrypted content (first 3 lines):**
```
_________________________________________________
_________________________________________________
_________________________________________________
```

---

## Phase 6: Analysis & Reporting (10 points)

### 6.1 Vulnerability Summary
List the major vulnerabilities discovered:

1. **Information Disclosure:**
   _________________________________________________

2. **Weak Authentication:**
   _________________________________________________

3. **File Security:**
   _________________________________________________

4. **Service Configuration:**
   _________________________________________________

### 6.2 Risk Assessment
Rate each vulnerability (Low/Medium/High/Critical):

| Vulnerability | Risk Level | Impact |
|---------------|------------|--------|
| Information Disclosure | | |
| Weak SSH Password | | |
| Anonymous FTP Access | | |
| Weak Encryption | | |

### 6.3 Recommendations
Provide 3 key security recommendations:

1. _________________________________________________
   _________________________________________________

2. _________________________________________________
   _________________________________________________

3. _________________________________________________
   _________________________________________________

---

## Bonus Questions (Extra Credit - 5 points each)

1. **Pattern Analysis:** What pattern did you notice in the successful SSH password?
   _________________________________________________

2. **Attack Vector:** What other services could be targeted for additional access?
   _________________________________________________

3. **Persistence:** How might an attacker maintain access to this system?
   _________________________________________________

---

## Lab Cleanup
Before leaving:
□ Document all findings  
□ Stop the lab: `docker compose down`  
□ Submit completed worksheet

---

## Instructor Use Only

**Grade Breakdown:**
- Reconnaissance: ___/20
- Web Enumeration: ___/15  
- FTP Access: ___/15
- SSH Attack: ___/25
- File Analysis: ___/15
- Analysis & Reporting: ___/10
- Bonus: ___/15

**Total Score: ___/100 (+ ___/15 bonus)**

**Comments:**
_________________________________________________
_________________________________________________
_________________________________________________