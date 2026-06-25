# Rules of Engagement (RoE) — Engagement Template
## Week 2 Deliverable — Fill-In Professional Template

A **Rules of Engagement (RoE)** document is the contract within the contract.
The master services agreement (MSA) says you are allowed to test *something*;
the RoE says exactly *what*, *how*, *when*, and *what to do if something goes
wrong*. No professional engagement begins without one, and no tester should run
a tool until both parties have signed it.

Complete this template for the fictional client **Acme Logistics** described in
`discussion-guide.md`. Replace every `_____` and every `[bracketed]` prompt with
your own content. Bring the finished document to class.

> **Educational note:** This template is simplified for teaching. In real
> engagements an RoE is reviewed by lawyers on both sides, references a signed
> authorization letter (sometimes called a "get-out-of-jail-free" letter), and
> often includes indemnification, insurance, and data-handling clauses. The
> structure below captures the parts that matter for learning the *shape* of an
> agreement.

---

## 1. Engagement Summary

| Field | Value |
|-------|-------|
| **Client (organization)** | Acme Logistics |
| **Client primary contact** | _________________________________ |
| **Testing firm / tester(s)** | _________________________________ |
| **Engagement type** | [ ] Black-box  [ ] Grey-box  [ ] White-box |
| **Engagement objective** | ___________________________________ |
| **Start date / time** | ___________________________________ |
| **End date / time** | ___________________________________ |
| **Reference authorization letter** | dated ____________, signed by ____________ |
| **Master services agreement ref.** | ___________________________________ |

**Objective (2–3 sentences):** What is the client trying to learn or prove?
(e.g., "Identify externally exploitable weaknesses in Acme's public-facing web
applications prior to the holiday sales season.")

___________________________________________________________

___________________________________________________________

---

## 2. In-Scope Systems, IPs, and Services

List **only** what the client has explicitly authorized. Vague entries like
"the website" are not acceptable — name hosts, IP ranges, ports, and
applications. If a target is not listed here, it is out of scope by default.

| # | Hostname / IP range | Service / port | Notes |
|---|---------------------|----------------|-------|
| 1 | _________________________ | _______________ | ____________________ |
| 2 | _________________________ | _______________ | ____________________ |
| 3 | _________________________ | _______________ | ____________________ |
| 4 | _________________________ | _______________ | ____________________ |
| 5 | _________________________ | _______________ | ____________________ |

**Confirmation:** I have verified that every asset above is owned or controlled
by the client, or that the client has written permission from the owner for me
to test it.

- [ ] Yes

---

## 3. Out-of-Scope Systems and Actions

Anything not granted above is out of scope. Spell out the obvious exclusions so
there is no ambiguity — and to protect yourself if a dispute arises.

| # | Out-of-scope asset or action | Reason |
|---|------------------------------|--------|
| 1 | Third-party / cloud provider infrastructure (e.g., Globex Cloud) | Not owned by client |
| 2 | Production systems during business hours | Client revenue impact |
| 3 | _________________________ | ____________________ |
| 4 | _________________________ | ____________________ |
| 5 | _________________________ | ____________________ |

**What to do if you discover an out-of-scope asset is reachable:** Stop, do not
interact further, log the observation, and notify the client contact. Do **not**
"just take a quick look."

---

## 4. Permitted Techniques

Mark each technique as **Allowed**, **Allowed with notice**, or **Prohibited**.
When in doubt, default to the more restrictive option and ask the client.

| Technique | Status | Conditions |
|-----------|--------|------------|
| Passive reconnaissance (OSINT, DNS, certificate transparency) | [ ] Allowed / [ ] Notice / [ ] Prohibited | __________ |
| Port scanning (e.g., `nmap -sS`, `-sV`) | [ ] Allowed / [ ] Notice / [ ] Prohibited | __________ |
| Vulnerability scanning (e.g., Nessus, OpenVAS, Nikto) | [ ] Allowed / [ ] Notice / [ ] Prohibited | __________ |
| Web application testing (e.g., SQLi, XSS, directory brute force) | [ ] Allowed / [ ] Notice / [ ] Prohibited | __________ |
| Credential brute force against authorized services | [ ] Allowed / [ ] Notice / [ ] Prohibited | __________ |
| Password / hash cracking of captured material (offline) | [ ] Allowed / [ ] Notice / [ ] Prohibited | __________ |
| Exploitation of identified vulnerabilities to demonstrate impact | [ ] Allowed / [ ] Notice / [ ] Prohibited | __________ |
| Post-exploitation on authorized systems | [ ] Allowed / [ ] Notice / [ ] Prohibited | __________ |

**Testing windows** (when activity that could cause impact is permitted):

___________________________________________________________

(e.g., "High-impact tests only 22:00–05:00 local, Monday–Thursday. Passive and
read-only tests permitted at any time during the engagement window.")

---

## 5. Prohibited Actions

The following are **never** permitted during this engagement, regardless of
technique columns above. Checking a box here is the tester's personal commitment
as much as the client's requirement.

- [ ] **Denial-of-Service (DoS / DDoS).** No technique whose purpose or likely
      effect is to make a service unavailable. This includes volumetric floods,
      resource-exhaustion exploits, and "accidentally" destructive payloads.
- [ ] **Social engineering of real staff.** No pretexting, phishing, vishing, or
      impersonation targeting actual Acme employees. (If a social-engineering
      assessment is in scope, it is conducted against pre-briefed targets under
      a separate, explicit authorization — see week 12.)
- [ ] **Physical intrusion / tailgating** at client sites, unless covered by a
      separate physical-security assessment with its own authorization.
- [ ] **Malware, ransomware, or persistent backdoors** deployed to client
      systems beyond the minimum needed to demonstrate a finding.
- [ ] **Accessing, copying, or exfiltrating real customer or employee data.**
      Use synthetic or clearly-fake test data wherever possible.
- [ ] **Modifying or deleting production data.** If a write primitive is found,
      demonstrate it with a benign, reversible change (e.g., append a known
      string) and record evidence — do not corrupt records.
- [ ] **Attacking third parties** (cloud providers, payment processors, SaaS
      vendors, other tenants) even if reachable through the client.
- [ ] **Sharing engagement data** with anyone outside the named tester(s) and
      the client contact, during or after the engagement, except as required by
      the data-handling clause in the MSA.
- [ ] **Continuing after an unexpected impact.** If any test causes an outage,
      error spike, or alert, stop immediately and notify (see §6).

**Add any client-specific prohibitions:**

___________________________________________________________

---

## 6. Reporting Cadence and Communication

| Item | Detail |
|------|--------|
| **Primary (non-urgent) channel** | _________________________________ |
| **Status update frequency** | [ ] Daily  [ ] Twice-weekly  [ ] Weekly  [ ] End-of-engagement only |
| **Status update recipient** | _________________________________ |
| **Draft report due** | ___________________________________ |
| **Final report due** | ___________________________________ |
| **Report format** | [ ] PDF  [ ] Client portal  [ ] Other: __________ |
| **Findings severity scale** | [ ] CVSS v3.1  [ ] Custom: __________ |
| **Re-test of fixes included?** | [ ] Yes — within _____ days  [ ] No  [ ] Separate engagement |

**What every status update should contain:** what was tested, what was found,
any impact observed, and what is planned next.

---

## 7. Emergency Contacts and Incident Response

If anything goes wrong — an outage, an accidental data exposure, a finding that
poses imminent risk to the client or the public — these are the people to reach,
in this order.

| Priority | Name | Role | Phone | Email | Notes |
|----------|------|------|-------|-------|-------|
| 1 (first call) | ___________ | ___________ | ___________ | ___________ | 24/7? [ ] Y / [ ] N |
| 2 (escalation) | ___________ | ___________ | ___________ | ___________ | 24/7? [ ] Y / [ ] N |
| 3 (backup) | ___________ | ___________ | ___________ | ___________ | 24/7? [ ] Y / [ ] N |

**Tester-side emergency contact** (for the client to reach you):
Name: ___________  Phone: ___________  Email: ___________

**Emergency response steps (memorize these):**
1. **Stop** all active testing immediately.
2. **Notify** priority-1 contact by phone, then follow up in writing.
3. **Document** the timestamp, the exact action taken, the system affected, and
   the observed impact.
4. **Do not attempt to "fix" or hide** anything on the client's systems without
   explicit instruction.
5. **Preserve evidence** (logs, screenshots, command history) for the incident
   review.

---

## 8. Data Handling and Closeout

- [ ] All client data collected during the engagement will be stored **encrypted
      at rest** on tester-controlled media only.
- [ ] No client data will be transferred to personal devices, personal cloud
      accounts, or shared with anyone outside the named tester(s).
- [ ] At engagement closeout, **all client data, captured credentials, and
      tooling artifacts will be securely deleted** within _____ days, and a
      deletion confirmation will be provided to the client.
- [ ] Findings will be reported **responsibly**: to the client first, with an
      agreed remediation window before any external disclosure.

---

## 9. Signatures

By signing below, both parties confirm that they have read, understood, and
agreed to the terms of this Rules of Engagement, and that the client
authorizes the tester to perform only the activities described in §2 and §4,
subject to the prohibitions in §5.

| Role | Name | Signature | Date |
|------|------|-----------|------|
| **Client authorized signer** | ___________ | ___________ | ___________ |
| **Client technical contact** | ___________ | ___________ | ___________ |
| **Lead tester** | ___________ | ___________ | ___________ |
| **Testing firm authorized signer** | ___________ | ___________ | ___________ |

> **Remember:** An RoE is not a formality — it is the document that proves you
> had permission. Keep a signed copy. If you are ever asked "did you have
> authorization to do that?", this is your answer.

---

*Template for educational use — CYB204 Ethical Hacking, Week 2.*
