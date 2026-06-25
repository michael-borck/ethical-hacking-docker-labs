# Week 6: Password Security — Cracking & Defense Lab

## Overview
A self-paced introduction to password security. You learn how passwords are stored
as hashes, crack weak ones offline with John the Ripper, run an online SSH brute
force with Hydra against a practice target, and turn those findings into stronger
password habits — all inside an isolated Docker network. No external system is ever
contacted.

## Learning Objectives
- Explain password hashing and why hashes are one-way.
- Identify common hash types (MD5, SHA-1, SHA-256) by length and format.
- Crack offline hashes with John the Ripper using wordlists.
- Run an online SSH brute force with Hydra against a practice target.
- Evaluate password strength and design a strong-password policy.
- Apply the legal and ethical boundaries of password testing.

## Setup (3 min)
```bash
# 1. Clone the repo and enter the lab directory
git clone https://github.com/michael-borck/ethical-hacking-docker-labs.git
cd ethical-hacking-docker-labs/labs/week6

# 2. Start the lab
docker compose up -d

# 3. Enter the container
docker exec -it password-cracking-lab bash
```
> `setup-script.sh` (optional) regenerates `wordlists/` and `hashes/` and fetches the
> RockYou top-1000 sample into `wordlists/rockyou-small.txt`.

Container map (all on `labnet`):

| Container             | Hostname      | Role                                 | Host port |
|-----------------------|---------------|--------------------------------------|-----------|
| password-cracking-lab | hacklab       | Your workspace (John, Hydra, Python) | —         |
| ssh-target            | target-server | Hydra brute-force target (SSH)       | —         |
| web-target            | web-server    | HTTP login form                      | 8080 → 80 |

The lab mounts `./wordlists`, `./hashes`, and `./scripts` into the container at
`/wordlists`, `/hashes`, and `/scripts`. See `LAB-GUIDE.md` for the full walkthrough.

## What's Included

```
labs/week6/
├── docker-compose.yml   # lab network and containers
├── setup-script.sh      # generates wordlists/hashes, fetches the rockyou sample
├── LAB-GUIDE.md         # full walkthrough and exercises
├── wordlists/           # basic.txt, lab-wordlist.txt, rockyou-small.txt
├── hashes/              # easy-md5.txt, medium-sha256.txt, john-format.txt
└── scripts/             # hash-identifier.py, password-gen.py
```

### Tools (in the container)
- **John the Ripper** — offline, CPU-based hash cracking.
- **Hydra** — online network-service brute force.
- **Python 3** for inline hash generation and password-strength checks.
- Helper scripts in `scripts/` for hash identification and password generation.

## Troubleshooting
| Problem | Fix |
|---------|-----|
| "Cannot connect to Docker" | Ensure Docker Desktop / the daemon is running |
| "No hashes cracked" | Check the hash has no trailing spaces; try `wordlists/basic.txt` first |
| Hydra reports no valid pairs | Wait ~30 s for `ssh-target` to finish installing OpenSSH, then retry |
| Wrong password recovered | Confirm you copied the hash with no leading/trailing whitespace |
| Stuck on a step | Check the notes and troubleshooting in `LAB-GUIDE.md` |

Reset the environment:
```bash
docker compose down -v
docker compose up -d
```

## Resources
- [TryHackMe — Crack the Hash](https://tryhackme.com/room/crackthehash)
- [OverTheWire — Bandit](https://overthewire.org/wargames/bandit/)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [NIST SP 800-63B password guidelines](https://pages.nist.gov/800-63-3/sp800-63b.html)
- [Have I Been Pwned](https://haveibeenpwned.com/) — breach examples

## Ethics
Educational use only. All testing stays inside this isolated Docker network — no
external system is contacted. Running these techniques against any system you do not
own requires **written authorization**; unauthorized password cracking is illegal in
most jurisdictions.

## Cleanup
```bash
docker compose down
```

Generated with Claude Code.
