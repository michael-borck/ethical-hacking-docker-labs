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
