# Security Policy

## What this repository is

Teaching material for an ethical-hacking course. It ships **deliberately vulnerable
targets and real offensive tooling** — DVWA, OWASP Juice Shop, a phishing framework,
exposed databases, a telnet service, and a Kali-based attacker workstation. That is
the curriculum, not an oversight.

Run it on a machine you control. Do not deploy it on anything reachable from a
network you do not own.

## Reporting a vulnerability

Open an issue at
<https://github.com/michael-borck/ethical-hacking-docker-labs/issues>.

Please report:

- Anything that lets a lab container reach the **host** or the host's network when
  it should not.
- Anything that exposes a lab service **beyond `localhost`** by default.
- Supply-chain problems: unpinned or compromised images, workflow permissions.

Please do **not** report the items in the next section — they are the exercises.

## Deliberate by design

### Vulnerable targets

| Lab | What it runs | Why |
|---|---|---|
| 4, 7 | DVWA, OWASP Juice Shop | Exploitable by design; the point of the exercise. |
| 4, 5, 7 | MySQL / MariaDB / Redis / OpenLDAP with weak configuration | Enumeration and credential-attack practice. |
| 7 | telnet on `2323` | Cleartext protocol analysis — the lesson is *why not to use it*. |
| 8, 9 | SSH targets with weak credentials | Password attacks, lateral movement, pivoting. |
| 12 | GoPhish + MailHog | Phishing simulation, entirely self-contained; no mail leaves the host. |

### Raised privileges

| Where | Setting | Why it is required |
|---|---|---|
| Week 10 `target` | `privileged: true` | Disables ASLR by writing `/proc/sys/kernel/randomize_va_space`. That sysctl is not namespaced, so a container cannot set it any other way. Without it the buffer-overflow lab has no stable addresses and cannot work. |
| Week 10 `attacker` | `SYS_PTRACE`, `seccomp:unconfined` | gdb needs `ptrace`; `setarch -R` needs the `personality()` syscall, which Docker's default seccomp profile **blocks**. Verified: `setarch -R` fails under the default profile and succeeds unconfined. |
| Week 1 `wireshark` | `NET_ADMIN`, `NET_RAW` | Packet capture. Verified: `dumpcap` fails with "Operation not permitted" without them. |
| Weeks 3, 7 `wireshark` | `NET_ADMIN` | Packet capture. |
| Attacker boxes | `NET_ADMIN` | Interface manipulation for scanning and traffic work. |

## Hardening that is in place

**Nothing is reachable from outside the host.** All 28 published ports bind
`127.0.0.1` via `${LAB_BIND:-127.0.0.1}`. They previously used Compose's short
syntax, which binds `0.0.0.0` — serving DVWA, Juice Shop, MySQL, Redis, LDAP, SMB,
telnet, three SSH targets and a phishing admin UI to every device on the network.

**The browser desktops require a login.** Weeks 3 and 7 (`linuxserver/wireshark`) and
week 7 (`webtop`) served a full desktop **with a terminal in it** and **no
authentication at all** — verified as HTTP 200 with no credentials. All three now
require a login (`analyst` / `labpass` by default). Override per-site:

```
LAB_GUI_USER=your-user
LAB_GUI_PASSWORD=your-password
```

in a `.env` beside the compose file — it is git-ignored and Compose reads it
automatically. Worth doing wherever `127.0.0.1` is not a boundary: several accounts
on one machine, RDP, or a shared server.

**External images are pinned**, by version where the project publishes one and by
digest where only a rolling tag exists. A lab behaves the same next year as this
year, and a guide that cites what a tool shows keeps matching it.

## Known limitations

1. **Lab networks are not isolated.** Unlike the sibling `assume-breach-labs`, these
   containers can reach the internet and the network the host sits on. Several labs
   route or pivot between segments, and `internal: true` breaks that — Docker drops
   traffic whose source is not in the target bridge's subnet, so the labs would
   start cleanly and be quietly useless. The `127.0.0.1` bindings stop anything
   reaching *in*; nothing stops a determined student reaching *out*. On a managed
   network, that is worth knowing before a class runs.

2. **`seccomp:unconfined` is broader than most labs need.** It is genuinely required
   in week 10 (see above). Elsewhere it rides along on the shared attacker service;
   `nmap -sS`, `tcpdump` and `hydra` were all verified to work under the default
   profile. Removing it per-lab is a safe cleanup, but each lab should be run
   afterwards rather than removed in one sweep.

3. **Week 1 uses a stale third-party image** (`ffeldhaus/wireshark:0.5`), amd64-only
   and unmaintained. It is pinned, and `privileged: true` has been removed, but the
   longer-term fix is moving that lab to the `linuxserver/wireshark` image used in
   weeks 3 and 7.

4. **Anyone who can run containers on a machine can act as root on it.** A container
   runtime creates containers as root and mounts host paths on request, so
   permission to use it is effectively administrative access to that machine —
   whatever the user's own account allows. This is documented, intended runtime
   behaviour, not something this repository introduces or can fix. On shared or
   managed machines: accept it, constrain the runtime's file sharing and registries,
   reimage between sessions, or use **rootless Podman**, which carries no root
   equivalence.
