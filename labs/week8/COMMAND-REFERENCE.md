# Command Reference Guide

This document explains every command used in the De-ICE S1.100 lab in simple terms.

## Network Discovery Commands

### `nmap -sn 172.20.0.0/24`
**What it does:** Discovers which computers are "alive" on the network  
**How it works:** Sends ping packets to all IP addresses from 172.20.0.1 to 172.20.0.254  
**Output:** List of active IP addresses  
**Why we use it:** First step in any network penetration test - find targets

### `nmap -sC -sV 172.20.0.2 172.20.0.3 172.20.0.4`
**What it does:** Scans specific computers for open ports and services  
**Flags explained:**
- `-sC`: Run default scripts (safe checks for common vulnerabilities)  
- `-sV`: Detect service versions (what software is running)  
**Output:** List of open ports with service details  
**Why we use it:** Identifies potential attack vectors (services we can exploit)

## Web Enumeration Commands

### `curl http://172.20.0.5`
**What it does:** Downloads and displays a webpage  
**How it works:** Makes HTTP request like a web browser, but shows raw HTML  
**Output:** HTML source code of the webpage  
**Why we use it:** Looking for sensitive information exposed on websites

### `curl -s http://172.20.0.5 | grep -E '(Name|Email)'`
**What it does:** Downloads webpage and searches for lines containing "Name" or "Email"  
**Flags explained:**
- `-s`: Silent mode (no progress bar)  
- `|`: Pipe (sends output to next command)  
- `grep -E`: Search with extended regex patterns  
- `(Name|Email)`: Find lines with either "Name" OR "Email"  
**Output:** Only lines containing employee names or emails  
**Why we use it:** Extract usernames for password attacks

## FTP Commands

### `ftp 172.20.0.4`
**What it does:** Connects to FTP (file transfer) server  
**Interactive commands:**
- `ls`: List files on server  
- `cd dirname`: Change to directory  
- `binary`: Set transfer mode for files  
- `get filename`: Download file  
- `quit`: Exit FTP  
**Why we use it:** Look for sensitive files left accessible

### Anonymous FTP Login
**Username:** `anonymous`  
**Password:** (just press Enter)  
**What it means:** Many FTP servers allow "guest" access without credentials  
**Why it's dangerous:** Sensitive files might be accessible to anyone

## Password Attack Commands

### `hydra -L users.txt -P passwords.txt 172.20.0.3 ssh -t 4`
**What it does:** Attempts to guess SSH passwords by trying many combinations  
**Flags explained:**
- `-L users.txt`: Try all usernames from this file  
- `-P passwords.txt`: Try all passwords from this file  
- `172.20.0.3`: Target IP address  
- `ssh`: Attack SSH service  
- `-t 4`: Use 4 parallel connections (faster)  
**Output:** Shows successful login combinations  
**Why we use it:** Exploits weak passwords to gain system access

### Creating Word Lists
```bash
cat > users.txt << 'EOF'
aadams
bbanter
EOF
```
**What it does:** Creates a text file with usernames  
**How it works:**
- `cat >`: Write to file  
- `<< 'EOF'`: Start multiline input, stop at 'EOF'  
- Everything between gets written to file  
**Why we do it:** Hydra needs lists of usernames and passwords to try

## SSH Commands

### `ssh aadams@172.20.0.3`
**What it does:** Connects securely to remote computer  
**Format:** `ssh username@ip-address`  
**What happens:** Prompts for password, then gives command line access  
**Why we use it:** Once we crack password, this gives us system access

### Basic SSH Session Commands
- `whoami`: Shows current username  
- `id`: Shows user privileges and groups  
- `pwd`: Shows current directory location  
- `ls -la`: Lists all files with detailed information  
- `find . -name "*.txt"`: Searches for text files  

## File Manipulation Commands

### `openssl enc -aes-256-cbc -d -salt -in file.enc -out file.txt -k "password"`
**What it does:** Decrypts an encrypted file  
**Flags explained:**
- `enc`: Encryption/decryption mode  
- `-aes-256-cbc`: Encryption algorithm used  
- `-d`: Decrypt (not encrypt)  
- `-salt`: Use salt for security  
- `-in file.enc`: Input encrypted file  
- `-out file.txt`: Output decrypted file  
- `-k "password"`: Use this password  
**Why we use it:** Recover readable content from encrypted files

### `cat filename`
**What it does:** Displays entire contents of a file  
**When to use:** View small files or check file contents  
**Alternative:** `less filename` for large files (use q to quit)

## Service Banner Checking

### `telnet 172.20.0.6 110`
**What it does:** Connects directly to a service port  
**Format:** `telnet ip-address port-number`  
**Purpose:** See what software version is running  
**Why it matters:** Different versions have different vulnerabilities  
**Exit:** Press Ctrl+] then type `quit`

## Docker Commands (For Lab Setup)

### `docker compose up -d`
**What it does:** Starts all lab containers in background  
**Flags explained:**
- `up`: Start containers  
- `-d`: Detached mode (runs in background)  
**Output:** Status of each container starting

### `docker exec -it de-ice-attacker bash`
**What it does:** Opens command line inside the attacker container  
**Flags explained:**
- `exec`: Execute command in running container  
- `-it`: Interactive terminal  
- `de-ice-attacker`: Container name  
- `bash`: Command to run (shell)  
**Result:** You're now "inside" the Kali Linux attacker machine

### `docker compose down`
**What it does:** Stops and removes all lab containers  
**When to use:** Clean shutdown of entire lab environment

## Understanding Command Output

### Successful Hydra Attack
```
[22][ssh] host: 172.20.0.3   login: aadams   password: smadaa
```
**What it means:**
- `[22]`: SSH service (port 22)  
- `[ssh]`: Service type  
- `host:`: Target IP  
- `login:`: Username that worked  
- `password:`: Password that worked  

### Nmap Port Scan Results
```
22/tcp   open  ssh     OpenSSH 8.2
80/tcp   open  http    Apache httpd 2.4
```
**What it means:**
- `22/tcp open`: Port 22 is accepting connections  
- `ssh OpenSSH 8.2`: SSH service version 8.2 is running  
- `80/tcp open`: Port 80 is accepting connections  
- `http Apache 2.4`: Web server Apache version 2.4 is running  

## Common Error Messages

### "Connection refused"
**What it means:** The service isn't running or is blocking connections  
**Solutions:** Check IP address, check if service is started, try different port

### "Permission denied"
**What it means:** Wrong username/password or insufficient privileges  
**Solutions:** Try different credentials, check if account exists

### "No route to host"
**What it means:** Cannot reach the target IP address  
**Solutions:** Check network connection, verify IP address, ensure containers are running

## Security Learning Points

### Why These Commands Work
1. **Network Discovery:** Many networks don't hide their devices  
2. **Service Enumeration:** Services often reveal version information  
3. **Web Information:** Websites frequently expose sensitive data  
4. **Weak Passwords:** Users choose predictable passwords  
5. **Anonymous Access:** Services misconfigured for convenience  

### Real-World Applications
- **Penetration Testing:** Authorized security assessments  
- **Network Administration:** Managing and securing networks  
- **Incident Response:** Investigating security breaches  
- **Security Research:** Understanding vulnerabilities  

**Important:** These techniques should only be used on systems you own or have explicit permission to test.