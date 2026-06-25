# Week 11: Bypassing Physical Access - Student Worksheet
## CYB204 Ethical Hacking - Beginner Lab

---

## **Before We Start (5 minutes)**

### **What this lab is (and isn't)**
Real RFID/NFC cloning needs **physical hardware** - a Proxmark3 or Flipper Zero
plus real cards. That **cannot** run in Docker. So we built a **software
simulation of the access-control backend**: a tiny "badge reader" web service.
The attacks you run here (enumerating badges, replaying a captured UID, finding
a vendor-default master) are the **exact same logic** an attacker uses with a
Proxmark3 against a real door. You learn the thinking; hardware is just the
delivery method.

### **Important Rules**
- ✅ **DO:** Only attack the lab reader at `172.26.0.10`
- ✅ **DO:** Ask for help if you get stuck
- ✅ **DO:** Write your answers in this worksheet
- ❌ **DON'T:** Try any of this on a real badge, door, or building
- ❌ **DON'T:** Clone or replay a badge you don't own - that's a crime
- ❌ **DON'T:** Tailgate into any real building, even "to test"

### **Quick Setup**
```bash
# Step 1: Build the shared base (from the repo root)
make build-base

# Step 2: Start the lab
cd labs/week11
docker compose up -d

# Step 3: Enter the attacker workstation
docker exec -it week11-attacker bash

# Step 4: Confirm the reader is reachable
curl http://172.26.0.10/status
```

**Check:** Did you get a response mentioning "ACME Access Systems"? ✓ Yes  ✓ No

---

## **Part 1: Fingerprint the Reader (5 minutes)**

A real attacker starts by learning what they're up against. The reader happily
tells anyone who asks.

```bash
curl http://172.26.0.10/status
```

**Fill in what it leaks:**

| Field | Value |
|-------|-------|
| Vendor | _________________________________ |
| Model | _________________________________ |
| Firmware | _________________________________ |
| UID format | _________________________________ |
| Badges enrolled | _________________ |

**Question:** The UID-format line is a huge hint. In the real world, how would
an attacker learn the format of a badge without `curl`?
(Circle one)
- A) Guess randomly
- B) Shoulder-surf a card or read the vendor's public datasheet
- C) They can't

---

## **Part 2: Enumerate a Valid Badge (10 minutes)**

Instead of stealing a card, we **guess** badge UIDs by walking a small range
and watching for a `200`. This mirrors a Proxmark3 bruteforcing a known
facility code.

```bash
for i in $(seq 0 255); do
  h=$(printf "%02X" $i)
  code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "http://172.26.0.10/present?uid=04A2:1B:$h")
  [ "$code" = "200" ] && echo "VALID BADGE FOUND: 04A2:1B:$h"
done
```

**Write the valid UID you found:** `_________________`

**How many tries did it take?** _________________

**Question:** A real 125 kHz HID Prox card uses a 26-bit format (facility code
+ card number). Why is a *small, predictable* identifier space dangerous?
_________________________________________________________

---

## **Part 3: Replay / "Clone" the Badge (5 minutes)**

Now replay the UID you captured - this is writing a stolen UID onto a blank
card.

```bash
curl -X POST "http://172.26.0.10/present?uid=<PUT-YOUR-UID-HERE>"
```

**What response did you get?** _________________________________

**Circle one:** The reader checked whether the card was *physically present*.
- YES - it verified the card itself
- NO - it only trusted the UID string

**Why does that matter?** (1 sentence)
_________________________________________________________

---

## **Part 4: Find the Vendor-Default Backdoor (10 minutes)**

Many controllers ship with a **maintenance master** code, documented in the
manual and never changed at install. Try some well-known "default/hex" patterns:

```bash
for guess in DEAD:BE:EF FF:FF:FF 00:00:00 AA:BB:CC FFFF:FFFF; do
  code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "http://172.26.0.10/present?uid=$guess")
  echo "$guess -> $code"
done
```

**Write the backdoor (vendor-default master) UID:** `_________________`

**What special message does it print?** _________________________________

**Circle one:** This risk is called...
- A) SQL injection
- B) Default / vendor credentials
- C) Tailgating
- D) Buffer overflow

---

## **Part 5: "Inside" - Dump Credentials from the Reader (10 minutes)**

Once you hold a valid badge, the reader exposes a hidden **diagnostics** port
that dumps its access log. This is the software analog of pulling stored badge
UIDs off a physically compromised reader's debug port.

```bash
curl "http://172.26.0.10/diag?uid=<PUT-YOUR-UID-HERE>"
```

**Paste one sample log line here:**
_________________________________________________________

**How many badge UIDs appear in the log that you did NOT find by enumeration?**
_________________

**Write down those extra UIDs** (reusable credentials for other doors!):
_________________________________________________________

**Try the diagnostics port with your backdoor UID from Part 4:**
```bash
curl "http://172.26.0.10/diag?uid=<BACKDOOR-UID-HERE>"
```
Does the master also open the diagnostics port? ✓ Yes  ✓ No

---

## **Part 6: Physical Mitigations (Discussion - 10 minutes)**

You just defeated the reader using only software. Talk through how a defender
stops each technique. Circle the best mitigation for each:

1. **Stop badge enumeration** of the `04A2:1B:XX` space:
   - A) Use a longer, random, unguessable UID per badge
   - B) Add more zeroes to the UID
   - C) Nothing, enumeration is harmless

2. **Stop replay/cloning** of a captured UID:
   - A) Switch from clonable 125 kHz cards to **MIFARE DESFire** (cryptographic challenge-response)
   - B) Print UIDs on the card
   - C) Use a louder buzzer

3. **Stop tailgating / piggybacking** through an opened door:
   - A) A **mantrap** (two-door interlock - only one opens at a time)
   - B) A bigger door
   - C) A "please don't" sign

4. **Stop shoulder surfing** of badges / PINs:
   - A) **Multi-factor** (badge + PIN + biometric) and shielded keypads
   - B) Taping badges to the wall
   - C) Brighter lighting

5. **Catch a stolen/cloned badge in use** after the fact:
   - A) **Badge-audit log review** + anomaly alerts (e.g. same badge in two places)
   - B) Ignoring the logs
   - C) Deleting old logs

**Short answer:** Why is a **125 kHz** HID Prox card far more dangerous to
deploy than a **MIFARE DESFire** card? (2 sentences)
_________________________________________________________
_________________________________________________________

**Short answer:** Name one reason a "maintenance master" UID shipped in
firmware is a bad idea even if it's "convenient" for the vendor.
_________________________________________________________

---

## **Part 7: Professional Ethics (10 minutes)**

Physical and RFID attacks are treated very seriously by the law. Mark each
scenario LEGAL or ILLEGAL:

| Scenario | Legal? |
|----------|--------|
| Cloning your own office badge for a class demo | |
| Copying a coworker's badge to "see if it works" | |
| Following someone through a secure door without a badge (tailgating) | |
| A physical pentest of your employer's building **with a signed scope + escort** | |
| Reading badge UIDs off a reader you found in a hallway | |
| Selling cloned badges online | |

**Scenario:** A client hires you to physically pentest their office. You
tailgate through the front door before checking in with your escort.

What should you have done differently? (Circle one)
- A) Nothing, tailgating is the test
- B) Stop at reception, confirm the **written authorization** scope, and have the **escort** present before any action
- C) Climb in through a window instead

**Key rule:** Physical pentests need **explicit written authorization** and
**very often an on-site escort**. Even with permission, you can be mistaken for
an intruder by staff or law enforcement. Document everything, stay in scope, and
never touch a badge, door, or reader you don't have documented permission to
test.

---

## **Quick Quiz (5 minutes)**

1. **Why can't real RFID cloning run in this Docker lab?**
   - A) Docker doesn't allow networking
   - B) It needs physical radio hardware (Proxmark3 / Flipper Zero + real cards)
   - C) Python can't read cards
   - D) Cards are too expensive

2. **Finding a valid badge by walking `04A2:1B:00`..`FF` is an example of:**
   - A) Tailgating
   - B) Enumeration
   - C) Shoulder surfing
   - D) Social engineering

3. **A "maintenance master" UID shipped by the vendor and never changed is a:**
   - A) Default / vendor-credential risk
   - B) Buffer overflow
   - C) Man-in-the-middle
   - D) Feature, not a bug

4. **Which card type is hardest for an attacker to clone?**
   - A) 125 kHz HID Prox
   - B) EM410x
   - C) MIFARE DESFire
   - D) Mag-stripe

5. **True/False: A physical pentest needs written authorization and often an escort.**
   - True / False

---

**Instructor Contact:** _________________________________
