# Penetration Testing Strategy Guide
## The "Intelligence-First" Approach

**For Students:** Understanding the methodology behind effective penetration testing

---

## Why Strategy Matters

Think of penetration testing like **detective work** - you gather clues first, then act on them. Random attacks are ineffective and easily detected. Professional penetration testers follow a systematic approach that maximizes success while minimizing detection.

## Lab Scenario: Complete Black Box Testing

**Important:** Our lab simulates a **complete black box** scenario where you have **zero prior information**. This differs from typical professional engagements where some target information is provided upfront.

### **Typical Professional Engagement:**
Client says: *"Please test our company website at abc.com"*
```bash
# Start with passive intelligence (OSINT)
dig abc.com           # DNS information
whois abc.com         # Registration details  
curl http://abc.com   # Website content
# Then move to active reconnaissance
nmap abc.com          # Port scanning
```

### **Our Lab Scenario:**
Client says: *"You're connected to our network - find all vulnerabilities"*
```bash
# Must start with network discovery (no targets known)
ip addr show                # Where am I?
nmap -sn 172.20.0.0/24     # What hosts exist?
nmap -sC -sV [discovered]  # What services run?
curl http://[target]       # Now gather intelligence
```

**Key Difference:** In black box scenarios, you must perform **active reconnaissance first** to discover what targets exist, then gather **passive intelligence** from those discovered targets.

---

## The Four-Phase Strategy (Black Box Methodology)

### **Phase 1: Environmental Awareness** 🗺️
**Goal:** Understand your position and identify targets
**Type:** Active Reconnaissance (Required - No prior knowledge)

```bash
# Where am I in the network?
ip addr show
route -n

# Who else is on this network?
nmap -sn 172.20.0.0/24
```

**Why This Phase is First in Black Box:**
- **Zero knowledge starting point** - Must discover what exists
- **Maps your attack surface** - Can't attack what you don't know exists
- **Identifies all potential targets** - Ensures comprehensive coverage
- **Establishes network boundaries** - Prevents attacking out of scope
- **Active reconnaissance is necessary** - No passive sources available

---

### **Phase 2: Service Discovery** 🔍
**Goal:** Catalog all available services across all targets
**Type:** Active Reconnaissance (Builds on Phase 1 discoveries)

```bash
# What services are running on discovered hosts?
nmap -sC -sV 172.20.0.3 172.20.0.4 172.20.0.5 172.20.0.6 172.20.0.7
```

**Why This Phase is Second in Black Box:**
- **Builds on Phase 1** - Uses discovered IP addresses as targets
- **Reveals all possible attack vectors** - Complete service inventory
- **Identifies service versions** - Potential vulnerabilities and exploits
- **Shows security posture** - Understanding of target hardening
- **Prioritizes targets** - Determines which services offer best attack paths
- **Still active reconnaissance** - Direct interaction with target services

---

### **Phase 3: Intelligence Gathering** 🎯
**Goal:** Collect actionable intelligence before attacking
**Type:** Passive Reconnaissance (Now that we know what exists)

#### **Start with Web Services - Here's Why:**

##### **🌐 Web First Strategy**

**1. Lowest Risk, Highest Reward**
- Just browsing a website (passive reconnaissance)
- Won't trigger intrusion detection systems  
- Maximum information gain with minimal footprint
- **Now possible because we discovered web services in Phase 2**

**2. Information Goldmine**
```bash
curl http://172.20.0.3
# Discovers:
# - Employee names → Potential usernames
# - Email formats → Domain patterns  
# - Company structure → Target priorities
# - Technology versions → Known vulnerabilities
```

**3. Builds Your Attack Foundation**
```
From website: "Alice Adams - aadams@company.com"
Intelligence: Username likely "aadams"
Strategy: Use in targeted password attacks
```

##### **📁 Then FTP Services**
```bash
ftp 172.20.0.5
# Try: anonymous/anonymous
# Look for: configuration files, documents, credentials
```

**Why FTP Second:**
- Often misconfigured with anonymous access
- May contain sensitive files  
- Provides additional intelligence for attacks
- **Semi-passive** - connecting but not attacking, just exploring

---

### **Phase 4: Targeted Exploitation** ⚔️
**Goal:** Launch precise attacks using gathered intelligence

```bash
# Create targeted username list from web intelligence
echo "aadams" > users.txt
echo "bbanter" >> users.txt
echo "ccoffee" >> users.txt

# Create smart password list based on company/patterns
echo "nostaw" > passwords.txt    # "watson" backwards
echo "company123" >> passwords.txt
echo "password" >> passwords.txt

# Launch targeted attack
hydra -L users.txt -P passwords.txt 172.20.0.4 ssh -s 2222
```

---

## Strategy Comparison

### ❌ **Amateur Approach: Random Attacks**
```bash
# Blind brute force - ineffective and noisy
hydra -L /usr/share/wordlists/common-users.txt -P /usr/share/wordlists/rockyou.txt target ssh
```
**Problems:**
- Low success rate
- Easily detected
- Takes excessive time
- May trigger account lockouts

### ✅ **Professional Approach: Intelligence-Driven**
```bash
# Targeted attack using discovered intelligence  
hydra -L discovered-employees.txt -P company-patterns.txt target ssh
```
**Benefits:**
- High success rate
- Stealthier approach
- Efficient use of time
- Mimics real attacker behavior

---

## Methodology Comparison: Known Target vs. Black Box

### **Professional Engagement (Known Target)**
**OSINT → Reconnaissance → Exploitation**

```bash
# Given target: "abc.com"
# Phase 1: OSINT (Passive Intelligence)
dig abc.com                    # DNS records
whois abc.com                  # Registration info
curl http://abc.com            # Website content
# Phase 2: Active Reconnaissance  
nmap abc.com                   # Port scanning
# Phase 3: Exploitation
hydra -L users.txt abc.com ssh # Targeted attacks
```

### **Our Lab (Complete Black Box)**
**Active Recon → Service Discovery → Passive Intel → Exploitation**

```bash
# Given: "Network access only"
# Phase 1: Network Discovery (Active - Required)
nmap -sn 172.20.0.0/24        # Find what exists
# Phase 2: Service Discovery (Active - Required)
nmap -sC -sV [discovered IPs] # Find what services run
# Phase 3: Intelligence Gathering (Passive - Now possible)
curl http://172.20.0.3         # Extract intelligence
# Phase 4: Exploitation (Active - Targeted)
hydra -L users.txt [target] ssh # Informed attacks
```

**Key Insight:** Black box scenarios **invert the traditional order** because you must discover targets before you can gather intelligence about them.

## Real-World Application

This black box methodology mirrors how **actual cybercriminals** operate when they gain initial network access:

1. **Reconnaissance Phase**
   - Social media research (LinkedIn, Facebook)
   - Company website analysis
   - Public records investigation

2. **Intelligence Gathering**
   - Employee name harvesting
   - Email format identification
   - Technology stack discovery

3. **Targeted Attack**
   - Spear phishing campaigns
   - Credential stuffing with company-specific patterns
   - Social engineering using gathered intelligence

---

## Key Principles for Students

### **1. Intelligence → Action**
Always gather information before attacking. Knowledge is your most powerful weapon.

### **2. Quality over Quantity**
One targeted attack is worth a hundred random attempts.

### **3. Think Like a Detective**
Every piece of information is a clue that leads to the next step.

### **4. Minimize Your Footprint**
Passive reconnaissance is invisible; active attacks leave traces.

### **5. Follow the Evidence**
Let discovered information guide your next moves, don't work against it.

---

## Common Student Mistakes to Avoid

### **❌ Mistake 1: Skipping Reconnaissance**
```bash
# Wrong: Immediately attacking without intelligence
ssh admin@target  # Guessing credentials
```

### **❌ Mistake 2: Ignoring Web Applications**
```bash
# Wrong: Only focusing on "exciting" services
nmap target | grep -v http  # Ignoring port 80
```

### **❌ Mistake 3: Using Generic Wordlists**
```bash
# Wrong: Using default wordlists without customization
hydra -L common.txt -P rockyou.txt target ssh
```

### **❌ Mistake 4: Random Service Order**
```bash
# Wrong: Attacking services in random order
# FTP → SSH → Web → Email (no logical progression)
```

---

## Success Checklist

Before moving to the next phase, ensure you have:

### **Phase 1 Complete:**
- [ ] Identified your network position
- [ ] Discovered all live hosts
- [ ] Documented target IP addresses

### **Phase 2 Complete:**
- [ ] Scanned all discovered hosts
- [ ] Cataloged all open ports and services
- [ ] Identified service versions

### **Phase 3 Complete:**
- [ ] Extracted intelligence from web applications
- [ ] Created targeted username lists
- [ ] Explored file services (FTP, SMB, etc.)
- [ ] Built company-specific password lists

### **Phase 4 Ready:**
- [ ] Have targeted wordlists ready
- [ ] Understand which accounts to attack
- [ ] Know which services are most likely to be vulnerable

---

## Remember: The Professional Mindset

**"A penetration tester is a puzzle solver, not a script kiddie."**

Your goal is to think strategically, work methodically, and use intelligence to guide every decision. This approach will serve you well in both academic exercises and real-world security assessments.

---

## Questions for Reflection

1. Why might attacking SSH first be a poor strategy?
2. What types of intelligence can you gather from a simple website?
3. How does this methodology reduce your chances of detection?
4. What would happen if you skipped the reconnaissance phases?

**Remember:** Every professional penetration tester started by learning this fundamental principle - **intelligence drives successful attacks.**