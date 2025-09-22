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
