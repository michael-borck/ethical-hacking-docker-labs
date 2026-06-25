# Week 12: Social Engineering - Phishing Mitigation

---

## Before We Start (5 minutes)

### *** READ THIS FIRST ***

> ### *** BIG WARNING - INTERNAL USE ONLY ***
> This lab runs a **simulated** phishing attack against **fictional**
> employees inside an **isolated Docker network**. The mail server is MailHog,
> a catch-all inbox that lives only on your machine. **No email ever leaves the
> lab. No real person is ever contacted. No real credentials are ever
> collected.**
>
> **Running GoPhish (or any phishing tool) against real people, real email
> addresses, real mailboxes, or any organisation without their explicit
> WRITTEN authorization is a crime** in most countries (e.g. computer-fraud,
> unauthorised-access, and anti-spam laws). The skills here are for defending
> organisations that have **hired and authorized** you to test them.

### Important Rules

| | |
|---|---|
| :white_check_mark: **DO** | Only run this stack on the isolated `phish_net` (172.27.0.0/24). |
| :white_check_mark: **DO** | "Send" mail only to the MailHog catch-all (`mailhog:1025`). |
| :white_check_mark: **DO** | Use **fictional** employees you invent yourself. |
| :white_check_mark: **DO** | Check the README if anything looks unclear. |
| :x: **DON'T** | Connect this network to the internet or a real mail server. |
| :x: **DON'T** | Put a real person's name or email into GoPhish. |
| :x: **DON'T** | Point the Sending Profile at any host except `mailhog`. |
| :x: **DON'T** | Reuse any of this against real targets without written authorization. |

### Quick Setup
```bash
# Step 1: build the shared base image (from the repo root)
make build-base

# Step 2: start the lab
cd labs/week12
docker compose up -d

# Step 3: confirm the three services are running
docker compose ps
```

**Check:** Can you reach both UIs?
- GoPhish admin: https://localhost:13333  -> login `admin / admin` (change it!)  :white_check_mark: Yes  :white_check_mark: No
- MailHog inbox: http://localhost:18025                                       :white_check_mark: Yes  :white_check_mark: No

```bash
# Step 4: open the attacker container for crafting + analysing mail
docker exec -it week12-attacker bash
```

---

## Part 1 - ATTACKER VIEW: Build and Launch the Simulation (35 minutes)

Follow `README.md` Activities 1-5. As you go, record what you configure and
what GoPhish reports.

### Exercise 1.1: The Sending Profile
Configure the profile so GoPhish can only talk to MailHog.

- [ ] Interface Type set to **SMTP**.
- [ ] Host set to `mailhog:1025` (no username/password, no TLS).
- [ ] Test email delivered and visible at http://localhost:18025.

**From address you used:** _____________________________________________

**Custom Reply-To header you added:** _____________________________________________

### Exercise 1.2: Landing Page + Email Template
- [ ] Imported `templates/landing-page.html` as Landing Page `acme-sso`.
- [ ] Imported `templates/sample-phish.html` as Email Template `it-password-expiry`.

**Email Subject that appeared:** _____________________________________________

### Exercise 1.3: Users & Groups
You should invent fictional employees only. List the three you created:

1. _____________________________________________
2. _____________________________________________
3. _____________________________________________

### Exercise 1.4: Launch and Observe
Launch the `password-expiry-sim` campaign, then watch the messages arrive in
MailHog and the counts climb on the GoPhish Dashboard.

Simulate a victim opening and clicking from the attacker container
(replace `ABC123` with a real `rid` copied from a delivered link in MailHog):

```bash
# register an "open" via the tracking pixel, then "click" the link
curl -sL "http://172.27.0.10/?rid=ABC123" -o /tmp/landing.html
grep -i simulation /tmp/landing.html
```

**Did the landing page render (you see "SIMULATION" in the grep output)?**
:white_check_mark: Yes  :white_check_mark: No

### Exercise 1.5: Campaign Stats (fill in from the GoPhish Dashboard)

| Metric | Count |
|---|---|
| Emails Sent | __________ |
| Emails Opened | __________ |
| Links Clicked | __________ |
| Submitted Data | __________ |
| Error / Bounced | __________ |

**Which single metric best predicts whether a credential was actually stolen?**
(Circle one)
- A) Emails Sent
- B) Emails Opened
- C) Links Clicked
- D) Submitted Data

---

## Part 2 - DEFENDER VIEW: Hunt the Indicators (25 minutes)

Open a delivered message in MailHog, then click its **Source** view to read the
raw headers and HTML. For each phishing tell below, tick the box if you found it
and note **exactly where** you saw it (From header, Reply-To header, body text,
a link's href, an `<img>` tag, etc.).

### Indicator Checklist

- [ ] **Spoofed display name** - the friendly name ("ACME IT Service Desk") does
      not match the real From address.
      Where: _____________________________________________

- [ ] **Lookalike From domain** - the From domain imitates a real brand but is
      subtly different (e.g. `acme-corp-secure.com` vs the real `acme.com`).
      The From domain you saw: _____________________________________________

- [ ] **Mismatched Reply-To** - the Reply-To points to a different address
      (often free webmail like `@protonmail.com` / `@gmail.com`).
      Reply-To value: _____________________________________________

- [ ] **Urgency / fear** - language pressuring the reader to act fast
      ("within 24 hours", "account suspended").
      Phrase you found: _____________________________________________

- [ ] **Link text vs href mismatch** - the visible text says one domain but the
      underlying `href` goes somewhere else.
      Visible text: __________________  Actual href: ___________________

- [ ] **Tracking pixel** - a transparent 1x1 `<img>` that pings the sender when
      the message is opened.
      The `<img>` src looked like: _____________________________________________

- [ ] **Credential-harvest page** - the link leads to a fake login form, not a
      legitimate SSO page.
      Evidence: _____________________________________________

- [ ] **Spoofing / branding errors** - typos, wrong copyright year, or branding
      that doesn't match the claimed organisation.
      Example: _____________________________________________

### Tally
**Number of indicators you spotted:** __________ of 8

(Circle one) An email with three or more of these tells is almost certainly:
- PHISHING  /  LEGITIMATE

---

## Part 3 - Build an Awareness Checklist (15 minutes)

Turn your findings into a one-page checklist a **non-technical colleague** could
follow before clicking anything. Write 5 rules in plain language:

1. _______________________________________________________________
2. _______________________________________________________________
3. _______________________________________________________________
4. _______________________________________________________________
5. _______________________________________________________________

**Bonus:** Name one technical control an IT team can add to reduce phishing
risk even when users click (e.g. MFA, DMARC, link rewriting, banner warnings):

____________________________________________________________________

---

## Part 4 - Ethics (10 minutes)

### Exercise 4.1: Legal or Illegal?
Mark each scenario LEGAL or ILLEGAL:

| Scenario | Legal? |
|---|---|
| Running this lab's GoPhish against the fictional MailHog inbox | |
| Sending the sample phish to your own personal email to "test" it | |
| Running a phishing simulation for your employer with written authorization | |
| Phishing a coworker "as a prank" to see if they click | |
| Buying a real phishing kit and emailing random people | |
| Using these skills to teach colleagues how to spot phishing | |

### Exercise 4.2: What would you do?
**Scenario:** A manager asks you to "just quickly phish the whole company, no
 paperwork, to see who's weak." What is the right response? (Circle one)
- A) Do it - they're a manager, so it's authorized.
- B) Do it but only target a few people.
- C) Refuse until there is written authorization and a clear scope.
- D) Do it and don't tell anyone.

**Why?** _______________________________________________________________

---

## Quick Quiz (5 minutes)

1. **What does MailHog do in this lab?**
   - A) Sends real email to the internet
   - B) Acts as a catch-all inbox that keeps every message inside the lab
   - C) Cracks passwords
   - D) Blocks phishing

2. **A Reply-To pointing to `something@protonmail.com` on a "corporate" email is a sign of:**
   - A) Good security
   - B) A tracking pixel
   - C) Phishing
   - D) Normal automation

3. **In GoPhish, what does `{{.Tracker}}` insert?**
   - A) The victim's password
   - B) A 1x1 image that registers an "open" when the mail is viewed
   - C) The sender's real name
   - D) A CAPTCHA

4. **True / False:** Personalising an email with your first name proves it is legitimate.
   - True / False

5. **Before running a phishing simulation against any real person or mailbox, you MUST have:**
   - A) A fast internet connection
   - B) Written authorization
   - C) A password manager
   - D) A newer laptop

---

## Cleanup
```bash
# back on your host, inside labs/week12
docker compose down
```

---

## Summary
Today you learned:
- :white_check_mark: How to build and launch an authorized phishing simulation with GoPhish + MailHog.
- :white_check_mark: Why mail is routed to MailHog so nothing ever leaves the lab.
- :white_check_mark: The classic indicators of a phishing email and where to find them.
- :white_check_mark: How to turn detection into an awareness checklist.
- :white_check_mark: Why authorization is non-negotiable for any real-world test.

**Remember:** These skills exist to *protect* people and organisations - never
to attack them without permission.

