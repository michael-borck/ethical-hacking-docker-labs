#!/bin/bash

echo "==================================="
echo "Password Cracking Lab Setup"
echo "==================================="

# Create necessary directories
mkdir -p wordlists hashes scripts

# Create sample hash files
echo "Creating sample hash files..."

# MD5 hashes
cat > hashes/easy-md5.txt << 'EOF'
5f4dcc3b5aa765d61d8327deb882cf99
e10adc3949ba59abbe56e057f20f883e
25d55ad283aa400af464c76d713c07ad
d8578edf8458ce06fbc5bb76a58c5ca4
EOF

# SHA256 hashes
cat > hashes/medium-sha256.txt << 'EOF'
5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8
65e84be33532fb784c48129675f9eff3a682b27168c0ea744b2cf58ee02337c5
a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3
EOF

# Create John the Ripper format hashes
cat > hashes/john-format.txt << 'EOF'
admin:5f4dcc3b5aa765d61d8327deb882cf99
user1:e10adc3949ba59abbe56e057f20f883e
guest:25d55ad283aa400af464c76d713c07ad
EOF

# Create a basic wordlist
cat > wordlists/basic.txt << 'EOF'
password
123456
password123
12345678
qwerty
admin
letmein
welcome
monkey
dragon
EOF

# Create a custom wordlist for the lab
cat > wordlists/lab-wordlist.txt << 'EOF'
password
password123
123456
12345678
qwerty
letmein
admin
administrator
welcome
monkey
dragon
master
hello
football
iloveyou
abc123
111111
1234567
sunshine
princess
EOF

# Download rockyou wordlist (small version for lab)
echo "Downloading small rockyou wordlist..."
wget -q -O wordlists/rockyou-small.txt https://raw.githubusercontent.com/zacheller/rockyou/master/rockyou-top1000.txt 2>/dev/null || echo "Note: Could not download rockyou sample. Using local wordlists only."

# Create helper scripts
cat > scripts/hash-identifier.py << 'EOF'
#!/usr/bin/env python3
import sys
import hashlib

def identify_hash(hash_string):
    hash_len = len(hash_string)
    
    if hash_len == 32:
        return "Likely MD5 (32 characters)"
    elif hash_len == 40:
        return "Likely SHA-1 (40 characters)"
    elif hash_len == 64:
        return "Likely SHA-256 (64 characters)"
    elif hash_len == 128:
        return "Likely SHA-512 (128 characters)"
    else:
        return f"Unknown hash type (length: {hash_len})"

if len(sys.argv) > 1:
    print(f"Hash: {sys.argv[1]}")
    print(f"Type: {identify_hash(sys.argv[1])}")
else:
    print("Usage: python3 hash-identifier.py <hash>")
EOF

# Create password generator script
cat > scripts/password-gen.py << 'EOF'
#!/usr/bin/env python3
import hashlib
import sys

if len(sys.argv) > 1:
    password = sys.argv[1]
    print(f"Password: {password}")
    print(f"MD5:      {hashlib.md5(password.encode()).hexdigest()}")
    print(f"SHA-1:    {hashlib.sha1(password.encode()).hexdigest()}")
    print(f"SHA-256:  {hashlib.sha256(password.encode()).hexdigest()}")
else:
    print("Usage: python3 password-gen.py <password>")
EOF

chmod +x scripts/*.py

echo ""
echo "Setup complete! Directories created:"
echo "  - wordlists/ : Contains password wordlists"
echo "  - hashes/    : Contains sample hash files"
echo "  - scripts/   : Contains helper Python scripts"
echo ""
echo "To start the lab:"
echo "  1. Run: docker-compose up -d"
echo "  2. Enter container: docker exec -it password-cracking-lab sh"
echo "  3. Start cracking!"
echo ""
echo "==================================="