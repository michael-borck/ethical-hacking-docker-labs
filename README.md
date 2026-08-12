# Ethical Hacking Docker Labs

<!-- BADGES:START -->
[![cybersecurity](https://img.shields.io/badge/-cybersecurity-f44336?style=flat-square)](https://github.com/topics/cybersecurity) [![docker](https://img.shields.io/badge/-docker-2496ed?style=flat-square)](https://github.com/topics/docker) [![docker-compose](https://img.shields.io/badge/-docker--compose-blue?style=flat-square)](https://github.com/topics/docker-compose) [![edtech](https://img.shields.io/badge/-edtech-4caf50?style=flat-square)](https://github.com/topics/edtech) [![educational](https://img.shields.io/badge/-educational-blue?style=flat-square)](https://github.com/topics/educational) [![ethical-hacking](https://img.shields.io/badge/-ethical--hacking-blue?style=flat-square)](https://github.com/topics/ethical-hacking) [![kali-linux](https://img.shields.io/badge/-kali--linux-blue?style=flat-square)](https://github.com/topics/kali-linux) [![penetration-testing](https://img.shields.io/badge/-penetration--testing-blue?style=flat-square)](https://github.com/topics/penetration-testing) [![security-training](https://img.shields.io/badge/-security--training-blue?style=flat-square)](https://github.com/topics/security-training) [![vulnerability-assessment](https://img.shields.io/badge/-vulnerability--assessment-blue?style=flat-square)](https://github.com/topics/vulnerability-assessment)
<!-- BADGES:END -->

> **Part of the [Assume-Breach series](https://security.borck.education/)** — five hands-on security labs, two companion books, and a game. Browse them all at the [series hub](https://github.com/michael-borck/security-labs).

**▶ Start here: https://ethicalhacking.borck.education/** — or run `./start.sh`.

> **Using an AI assistant?** Make it a thinking partner, not an autopilot — and never run a command you
> can't explain. The series guide **[Learning with AI](https://github.com/michael-borck/security-labs/blob/main/LEARNING-WITH-AI.md)**
> shows how, including how to repeat each lab until you don't need the assistant at all.

A hands-on, self-paced ethical hacking lab series — 12 Docker-based labs you can run anywhere. Each lab lives in its own folder with a Docker Compose setup, a lab guide, and supporting resources.

## Labs

| Week | Topic | Lab Focus | Key Tools/Services |
|------|--------|-----------|-------------------|
| 1 | Setup Docker Environment | Basic setup and toolkit check | Wireshark (browser), Kali base |
| 2 | Ethical and legal issues | Readings and discussions | N/A (docs only) |
| 3 | Scope and proposal development | Traffic analysis | Wireshark + sample captures |
| 4 | Reporting and engagement close out | Scanning targets | Nmap on targets |
| 5 | System and network enumeration | Enumeration | LDAP, MySQL, SMB, SNMP, Netshoot |
| 6 | Password cracking | Cracking techniques | John, Hydra, SSH target |
| 7 | Web app vulnerabilities | SQLi, XSS | DVWA, Juice Shop |
| 8 | Privilege escalation | Escalation vectors | De-ICE S1.100 sim (web, SSH, FTP, mail) |
| 9 | Lateral movement | Pivoting | SSH/SOCKS tunnels, dual-network sim |
| 10 | Exploit development | Buffer overflows | GDB, vulnerable bins |
| 11 | Bypassing physical access | Physical security | Access-control logic sim (RFID analog) |
| 12 | Social engineering | Phishing mitigation | GoPhish, MailHog, awareness |

## Shared Base Image

All labs share a base Kali image, `ghcr.io/michael-borck/ethical-base`, built from [`base.Dockerfile`](base.Dockerfile) with core tools (nmap, hydra, john, hashcat, wireshark, sqlmap, gobuster, …). A GitHub Actions workflow ([`.github/workflows/build-base.yml`](.github/workflows/build-base.yml)) builds and publishes it to GHCR on every change, so labs just pull it.

- **Default (online)**: `docker compose up -d` pulls the prebuilt image — no local build step.
- **Fallback (offline, or to customise the tools)**: `make build-base` builds `base.Dockerfile` locally and tags it with the same name, so `docker compose up` uses your local copy automatically.

> After the first workflow run, set the package to **Public** at `github.com/users/michael-borck/packages/container/ethical-base/settings` so anyone can pull without authenticating.

## Usage

1. **Clone & enter a week**:
   ```bash
   git clone https://github.com/michael-borck/ethical-hacking-docker-labs.git
   cd ethical-hacking-docker-labs/labs/week6
   ```

2. **Start the lab**: `docker compose up -d` — the base image and all target services pull automatically. (First run takes a few minutes to pull.)

3. **Enter the attacker shell**: `docker exec -it <container> bash` — each week's README names its attacker container (e.g. `password-cracking-lab`).

4. **Stop / clean up**: from the week folder, `docker compose down`; or `make stop-all` from the repo root.

Repo-root convenience targets: `make run-weekN` (start week *N*), `make status` (list all weeks), `make pull-base` (refresh the base image), `make build-base` (build the base locally).

### Lab Status
All 12 weeks are implemented. Week 2 is docs-only (ethics & law); weeks 1 and 3–12 are hands-on Docker labs. Run `make status` from the repo root to see which weeks are ready and their start commands. Each hands-on lab ships a `README.md`, a `LAB-GUIDE.md`, and any seed files its services need.

## Structure
- `base.Dockerfile`: Shared Kali base image source.
- `.github/workflows/build-base.yml`: CI that builds and publishes the base image to GHCR.
- `labs/weekN/`: Per-week setups (compose, README, worksheet, seed files).
- `data/`: Shared resources (e.g. packet captures for the traffic-analysis lab).
- `Makefile`: Orchestration (build/pull base, run/stop weeks, status).
- `.gitignore`, `LICENSE`: Housekeeping.

## Setup
Quickstart:
```bash
git clone https://github.com/michael-borck/ethical-hacking-docker-labs.git
cd ethical-hacking-docker-labs/labs/week6
docker compose up -d        # pulls the base image + targets
docker exec -it password-cracking-lab bash
```
Run in an isolated environment. You only need Docker installed — no local build step.

**Note**: Educational only. Follow ethics; no real-world testing without permission.

Generated with Claude Code.