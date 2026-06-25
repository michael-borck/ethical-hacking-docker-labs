# Week 12: Social Engineering - Phishing Mitigation Lab

## Overview
This lab shows how organisations run **authorised phishing-simulation
exercises** to measure and improve security awareness. You stand up a complete
GoPhish + MailHog stack inside an isolated Docker network, craft a simulated
"IT password expiry" phishing email and a credential-harvest landing page,
"send" them to a few fictional employees (every message is captured by MailHog
- nothing ever leaves the lab), then switch to the **defender** seat and learn
to spot the exact indicators a real phisher leaves behind.

## Learning Objectives
- Operate GoPhish: build a Sending Profile, Landing Page, Email Template,
  Users & Groups, and launch a Campaign.
- Explain why mail is routed to MailHog so that **no real email ever leaves
  the lab**.
- Recognise common phishing indicators: spoofed display name, lookalike sender
  domain, mismatched Reply-To, urgency/fear, link text vs href mismatch, and
  the tracking pixel.
- Build a reusable awareness checklist and explain how authorised simulations
  strengthen an organisation's human-layer defences.

## Setup (5 min)
1. Build the shared base image (from the repo root):
   ```bash
   make build-base
   ```
2. Start the lab:
   ```bash
   cd labs/week12
   docker compose up -d
   ```
3. Reach the two UIs:
   - **GoPhish admin**: https://localhost:13333 - default login `admin / admin`
     (self-signed TLS - accept the browser warning). **Change this password
     now** in *Settings*.
   - **MailHog inbox** (the simulated victim mailbox): http://localhost:18025
4. Enter the attacker container for payload-crafting and email analysis:
   ```bash
   docker exec -it week12-attacker bash
   ```

> **Internal-only.** All mail flows from `gophish` to `mailhog`
> (`172.27.0.11:1025`) on the isolated `phish_net` network. This network must
> **never** be connected to the internet or to a real mail server.

## Activities

### 1. Start the stack and open both UIs (5 min)
Check the three containers are up, then open the GoPhish admin UI and the
MailHog inbox from Setup. Log in to GoPhish and change the `admin/admin`
password.

```bash
docker compose ps          # gophish, mailhog, attacker should be "running"
```

### 2. Create a Sending Profile (pointing ONLY at MailHog) (5 min)
GoPhish -> **Sending Profiles** -> *New Profile*:
- **Name**: `mailhog-relay`
- **Interface Type**: `SMTP`
- **From**: `ACME IT Service Desk <security@acme-corp-secure.com>`
- **Host**: `mailhog:1025`  *(resolves to MailHog inside phish_net)*
- **Username / Password**: *(leave blank - MailHog needs no auth)*
- Set **Email Protocol** to plain `SMTP` (no TLS).
- **Headers** -> *Add Custom Header*: name `Reply-To`, value
  `admin-reset@protonmail.com`
  *(deliberate indicator: a free-webmail Reply-To that mismatches the From domain).*
- Click **Send Test Email** to `admin@admin` -> the message should appear in
  MailHog at http://localhost:18025.

### 3. Create the Landing Page and Email Template (10 min)
- **Landing Pages** -> *New Page* -> *Source*: paste
  `templates/landing-page.html`, set **Name** `acme-sso`, **Save**.
- **Email Templates** -> *New Template* -> *Import Email*: paste
  `templates/sample-phish.html`, set **Name** `it-password-expiry`,
  **Import Template**, then **Save**.

### 4. Create Users & Groups (5 min)
**Users & Groups** -> *New Group* `staff`: add three fictional employees:
`alex.taylor@acme.com`, `jamie.rivera@acme.com`, `casey.morgan@acme.com`
(use *Add* or *Import CSV*). **Save**.

### 5. Launch the Campaign and watch MailHog (10 min)
**Campaigns** -> *New Campaign*:
- **Name**: `password-expiry-sim`
- **Email Template**: `it-password-expiry` - **Landing Page**: `acme-sso`
- **URL**: `http://172.27.0.10`  *(the GoPhish phish server - internal only)*
- **Launch Date**: now - **Groups**: `staff`
- Click **Launch Campaign** (or **Send Emails**).

Open http://localhost:18025 - the three simulated messages land in MailHog,
and the GoPhish **Dashboard** updates live as messages are sent / opened /
clicked.

The host browser cannot reach the internal phish IP, so "simulate a victim
click" from the attacker container instead:

```bash
# 1) Open a delivered message in MailHog and copy the rid from the link
#    (the link looks like  http://172.27.0.10/?rid=ABC123  -> rid is ABC123)
# 2) From the attacker container, fetch the landing page with that rid:
curl -sL "http://172.27.0.10/?rid=<RECIPIENT_ID>" -o /tmp/landing.html
grep -i simulation /tmp/landing.html     # confirms the phish page was served
```

### 6. DEFENSIVE: read a delivered email and hunt the indicators (20 min)
In MailHog, open a message and switch to the **Source** view (raw headers +
body). Work through the indicator checklist in `LAB-GUIDE.md`
(Defender view): spoofed display name, lookalike From domain, mismatched
Reply-To, urgency, link text vs href mismatch, tracking pixel, and the
credential-harvest landing page. Then turn those findings into a one-page
**awareness checklist** you could hand to a non-technical colleague.

## Cleanup
```bash
docker compose down
```

**Ethics**: Educational use only inside isolated Docker. No real phishing
delivery, no real credentials, internal networks only. Written authorization is
required to run phishing simulations against any real person, mailbox, or
organisation - running this against real targets without authorization is
illegal.

Generated with Claude Code.
