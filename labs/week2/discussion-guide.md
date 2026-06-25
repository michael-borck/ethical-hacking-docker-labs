# Week 2: Ethical and Legal Issues — Discussion Guide

Welcome! This week has no computers to hack — just ideas to think about. That is
because the law and ethics of hacking have to come *before* the tools. A person
who can run `nmap` without knowing whether they are allowed to is not a security
professional; they are a suspect.

Work through this guide alone or in a group. Write your answers in the spaces
provided. Plan on about 45 minutes.

---

## Before We Start (5 minutes)

### Important Rules

✅ **DO:** Test only on systems you own, or that you have **written permission**
   to test, inside the time window you were given.
✅ **DO:** Stop and ask the moment you are unsure whether something is in scope.
✅ **DO:** Report anything dangerous you find (a live vulnerability, leaked
   credentials) to the system owner through the agreed channel.
✅ **DO:** Keep what you learn confidential — client data is not for show-and-tell.
❌ **DON'T:** Run *any* tool against a system you don't own just to "see what
   happens." Curiosity is not authorization.
❌ **DON'T:** Assume "I work here" or "I'll only look, I won't change
   anything" makes access legal. It does not.
❌ **DON'T:** Reuse, publish, or share credentials, data, or vulnerabilities you
   find during a test.
❌ **DON'T:** Keep going if your scan produces an unexpected outage — stop,
   notify your contact, and document what happened.

### The One Rule

> **Never test a system you do not own without written permission.**

If you remember nothing else from this week, remember that sentence. Everything
in this guide is really just unpacking it.

**Check (circle one):** I understand that "I was just curious" / "I was trying
to help" is **not** a legal defense. — **Yes / Not sure yet**

---

## Part 1: Three Real-World Case Studies (15 minutes)

For each scenario, decide whether you think it is **legal** or **illegal**,
write down *why*, and then compare with your group. There are honest
disagreements here — what matters is your reasoning, not just the label.

### Case Study 1 — "The Helpful Researcher"

> Maya reads a news article about a local hospital's new patient portal. Out of
> curiosity she opens the portal's login page in her browser, views the page
> source, and notices a URL pointing at an internal API. She changes a number
> in the URL and is suddenly reading other patients' appointment records. She
> did not log in, she did not guess any password, and the data was just sitting
> there. She emails the hospital: "Your portal is leaking data, you should fix
> this."

**Is this legal or illegal?** _________________

**Why? (1–2 sentences)**

___________________________________________________________

___________________________________________________________

**Things to weigh:** Did Maya have authorization? Does "the data was easy to
reach" change anything? Does emailing the hospital make her a whistleblower or
a trespasser? Under the U.S. CFAA, the key question is usually whether she
accessed a "protected computer" *without authorization* — and "I didn't have to
hack hard" is not a defense.

### Case Study 2 — "The Curious Operator"

> Jordan works in IT and has been learning about port scanning. Wanting to
> practice, he first runs `nmap -sS scanme.nmap.org` — a host explicitly set up
> for scanning practice. That works, so he then turns the same scanner on his
> employer's public-facing web server from the office network. He doesn't find
> anything interesting, so he moves on to scanning the customer portal and the
> internal wiki. He never tries to log in to anything.

**Is this legal or illegal?** _________________

**Why? (1–2 sentences)**

___________________________________________________________

___________________________________________________________

**Things to weigh:** Does having an account on the corporate network
count as authorization to scan it? Does it matter that `nmap -sS` (a SYN/"half
open" scan) is stealthier than a normal scan? Many organizations' acceptable-use
policies explicitly prohibit unauthorized scanning — and a policy violation can
become a CFAA violation. The famous `scanme.nmap.org` host exists *because*
its owner explicitly invites scanning; nothing else is scan-by-default.

### Case Study 3 — "The Eager Bug Hunter"

> Priya wants to build a bug-bounty portfolio. She picks a large online retailer
> that does **not** publish a bug bounty program, finds a SQL injection flaw in
> their search page, and uses it to dump a small sample of the user table
> (about 50 rows) to "prove" the bug. She then emails security@… demanding a
> bounty and threatening to publish the write-up if they don't pay.

**Is this legal or illegal?** _________________

**Why? (1–2 sentences)**

___________________________________________________________

___________________________________________________________

**Things to weigh:** Is *finding* a flaw illegal, or is *exploiting* it the
line? Does the lack of an invited program change things versus an official
`security.txt` or HackerOne page? What about the demand for payment and the
threat to publish — does that turn a disclosure into something closer to
extortion? (Real bug-bounty platforms and a responsible-disclosure process
exist precisely to keep researchers on the legal side of this line.)

---

## Part 2: Rules of Engagement Activity (15 minutes)

You have been hired to test **Acme Logistics**, a fictional mid-size shipping
company. Here is what they told you on the kickoff call:

> "We're Acme Logistics. We run a public website at `www.acme-logistics.example`,
> a customer portal at `portal.acme-logistics.example`, an internal warehouse
> app, an employee Wi-Fi network in our three warehouses, and we use a
> third-party cloud provider (Globex Cloud) for our databases. Our main office
> has about 80 staff on a corporate network. Please don't touch anything in
> production during business hours, and don't try to break into Globex — that's
> their job."

Your job is to turn that vague description into a clear **in-scope / out-of-scope**
list. Fill in the table. (There is more than one defensible answer — justify
yours.)

### In-scope assets (systems/IPs/services you ARE allowed to test)

| # | Asset | Why it's in scope |
|---|-------|-------------------|
| 1 | _________________________ | _________________________________ |
| 2 | _________________________ | _________________________________ |
| 3 | _________________________ | _________________________________ |
| 4 | _________________________ | _________________________________ |

### Out-of-scope assets (systems you are NOT allowed to test)

| # | Asset | Why it's out of scope |
|---|-------|-----------------------|
| 1 | _________________________ | _________________________________ |
| 2 | _________________________ | _________________________________ |
| 3 | _________________________ | _________________________________ |

**Discussion prompts:**
- The customer portal and the public website — are they equally in scope, or
  should one come first?
- Globex Cloud is clearly out of scope, but what if you find a flaw in Acme's
  code that *exposes* Globex data? Whose permission do you need?
- The employee Wi-Fi and the corporate office network — would you treat a
  warehouse differently from headquarters? Why?
- "Production during business hours" is restricted. How would you phrase a
  precise testing-window rule in the RoE? (e.g., "Tests that could cause
  service interruption are permitted only between 22:00 and 05:00 local,
  Monday–Thursday.")

When you are happy with your lists, transfer them into
`rules-of-engagement-template.md` — that template is the *real* deliverable for
this week.

---

## Part 3: "What Would You Do?" Dilemma (5 minutes)

**Scenario:**

> You are three days into a two-week engagement with a client. While testing
> their web application you accidentally trigger a bug that takes the whole app
> offline for about 20 minutes — during the client's busiest sales hour. The
> app came back on its own, no one at the client has noticed yet, and you are
> pretty sure the bug was in *their* code, not anything you did wrong. Your RoE
> says to report "any material impact" within one hour.

What do you do, in what order? Circle all that apply, then put them in the right
sequence:

- A) Say nothing — it fixed itself, and admitting it might get you fired.
- B) Quietly add the outage-causing bug to your findings report at the end of
     the engagement.
- C) Call your emergency contact at the client *now* and explain exactly what
     happened, what you did, and that the app is back up.
- D) Try to reproduce the outage again to confirm it before reporting.
- E) Document the timestamp, the request you sent, and the app's recovery in
     your log.
- F) Stop all testing of that application until the client confirms it's okay
     to continue.

**Your sequence (e.g., C → E → F):** _________________

**Why did you order them that way?**

___________________________________________________________

___________________________________________________________

**What to notice:** Options C, E, and F reflect the duties in nearly every
professional code of ethics — *honesty*, *diligence*, and *not making things
worse*. Options A and B betray the trust the engagement is built on. Option D,
"reproduce it again," is the seductive one: confirming a finding is good
science, but doing it on a live production system you've just taken down is
reckless. The right answer is usually: **stop, notify, document, and let the
client decide whether to continue.**

---

## Part 4: Quick Quiz (5 minutes)

Circle the best answer.

**1. Under the U.S. Computer Fraud and Abuse Act (CFAA), the single most
important question about whether accessing a computer is legal is usually:**
- A) Whether you caused any damage
- B) Whether you had **authorization** to access it
- C) Whether you used a "hacking tool"
- D) Whether you intended to help the owner

**2. "Exceeding authorized access" means:**
- A) Logging in faster than the system allows
- B) Using a valid account or permission to reach data or systems you were
     *not* authorized for
- C) Forgetting your password
- D) Having too many browser tabs open

**3. Which of these is the BEST description of "scoping" in an engagement?**
- A) Deciding what tools you will run
- B) Writing the final report
- C) Agreeing with the client on exactly which assets, services, and time
     windows are in scope and out of scope
- D) Choosing how much to charge

**4. You finish a penetration test and discover you still have a copy of the
client's password database on your laptop. According to standard professional
ethics and the engagement lifecycle, you should:**
- A) Keep it as a "souvenir" in case you need it later
- B) Publish it to prove the vulnerability was real
- C) Securely delete it as part of closeout, and confirm deletion to the client
- D) Email it to yourself so you don't lose it

**5. Which statement best matches the shared spirit of the EC-Council,
(ISC)², and OWASP codes of ethics?**
- A) "Show off your skills whenever possible."
- B) "Protect the public, act honestly, and only do work you're authorized to
     do."
- C) "Find as many vulnerabilities as you can, by any means necessary."
- D) "Security research is above the law."

*(Answers are in the README's "Engagement lifecycle" and "Professional codes of
ethics" sections — check your reasoning there.)*

---

## Part 5: Ethics Reflection (5 minutes)

The (ISC)² Code of Ethics lists its canons in priority order, and the first
one is deliberately the hardest: **"Protect society, the common good,
necessary public trust and confidence, and the infrastructure."** Notice it
comes *before* the duty to your client or your employer.

**Your turn.** In one or two sentences each:

1. **Which duty do you personally rank first — to society, to your client, to
   the profession, or to the public — and why?**

   ___________________________________________________________

   ___________________________________________________________

2. **Describe one situation where "duty to society" and "duty to your client"
   might pull in opposite directions** (for example, your client wants a
   vulnerability kept secret, but the public is at risk). What would you do?

   ___________________________________________________________

   ___________________________________________________________

3. **Professional ethics are voluntary — there is no "ethics police."** So why
   bother following a code of ethics at all? Give two reasons.

   - ___________________________________________________________

   - ___________________________________________________________

---

## Summary

Today you learned:
✓ Why **authorization** is the cornerstone of legal and ethical hacking
✓ How the CFAA treats "without authorization" and "exceeding authorized access"
✓ The six phases of a professional engagement lifecycle
✓ How to draw an in-scope / out-of-scope boundary for a real client
✓ The shared duties in the EC-Council, (ISC)², and OWASP codes of ethics

**Remember:** The most important skill in ethical hacking is not running tools
— it is knowing when *not* to.

---

## Need Help?
- Confused about a case study? Talk it through with a peer — the
  disagreements are the point.
- Not sure about an answer? Re-read the matching section of `README.md`.
- Want to go deeper? Read the actual codes of ethics linked in the README.
