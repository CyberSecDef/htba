# Introduction to Penetration Testing

> **Welcome to the World of Ethical Hacking**

---

## What You'll Learn

By the end of this section, you'll understand:

- What penetration testing actually is (and isn't)
- Why organizations pay people to hack them
- The different types of penetration tests
- How pentesting differs from other security work
- What a day in the life of a pentester looks like
- The skills you'll need to develop
- Career paths and certifications
- The 8-phase methodology you'll follow

---

## Key Terms

| Term | Definition |
|------|------------|
| **Penetration Test (Pentest)** | An authorized, simulated attack on a system to find vulnerabilities |
| **Vulnerability** | A weakness that could be exploited by an attacker |
| **Exploit** | Code or technique used to take advantage of a vulnerability |
| **Scope** | The defined boundaries of what you're allowed to test |
| **CIA Triad** | Confidentiality, Integrity, Availability - the core security principles |
| **Attack Surface** | All the points where an attacker could try to enter a system |
| **Threat Actor** | Anyone who might attack a system (hackers, insiders, nation-states) |
| **Red Team** | Offensive security team simulating real attackers |
| **Blue Team** | Defensive security team protecting systems |

---

## What Is Penetration Testing?

Imagine you're a homeowner who wants to know if your house is secure. You could:

1. **Look at the locks yourself** (self-assessment - often misses things)
2. **Hire a security consultant to inspect** (vulnerability assessment - finds theoretical weaknesses)
3. **Hire someone to actually try to break in** (penetration test - finds real, exploitable weaknesses)

A penetration test is option 3. You're hiring a professional to think like a burglar, try every window and door, test the alarm system, and report back on how they got in (or didn't).

**Penetration testing is:**
- Authorized (you have permission)
- Simulated (you're not a real attacker)
- Goal-oriented (you're trying to prove something)
- Documented (you're writing a report)
- Helpful (you're improving security)

**Penetration testing is NOT:**
- Hacking without permission (that's a crime)
- Running a scanner and handing over the output (that's a vulnerability assessment)
- Breaking things for fun (that's destructive)
- Showing off (that's ego)

---

## Why Do Organizations Pay People to Hack Them?

```
┌─────────────────────────────────────────────────────────────────┐
│                    THE SECURITY DILEMMA                          │
└─────────────────────────────────────────────────────────────────┘

Every organization faces this reality:

    "We think we're secure..."

              │
              ▼

    ┌─────────────────┐         ┌─────────────────┐
    │ Option A:       │         │ Option B:       │
    │ Wait for a real │         │ Pay someone to  │
    │ attacker to     │         │ find weaknesses │
    │ prove us wrong  │         │ BEFORE attackers│
    └────────┬────────┘         └────────┬────────┘
             │                           │
             ▼                           ▼
    ┌─────────────────┐         ┌─────────────────┐
    │ Data breach     │         │ Controlled test │
    │ Lawsuits        │         │ Detailed report │
    │ Fines           │         │ Time to fix     │
    │ Reputation loss │         │ No real damage  │
    │ Customer exodus │         │ Improved security│
    └─────────────────┘         └─────────────────┘

    Average data breach cost: $4.45 million (2023)
    Average pentest cost: $10,000 - $100,000

    The math is obvious.
```

### Real-World Impact

Organizations hire pentesters because real attacks have real consequences:

| Incident | What Happened | Cost |
|----------|---------------|------|
| Equifax (2017) | Unpatched vulnerability led to 147M records stolen | $1.4 billion |
| Colonial Pipeline (2021) | Compromised VPN led to ransomware | $4.4 million ransom + shutdown |
| SolarWinds (2020) | Supply chain attack affected 18,000 organizations | Billions in damages |
| Target (2013) | HVAC vendor compromised led to 40M cards stolen | $162 million |

A penetration test might have found each of these vulnerabilities before the attackers did.

---

## The CIA Triad: What You're Protecting

Every security assessment evaluates impact against three core principles:

```
┌─────────────────────────────────────────────────────────────────┐
│                      THE CIA TRIAD                               │
└─────────────────────────────────────────────────────────────────┘

                    CONFIDENTIALITY
                          ▲
                         /│\
                        / │ \
                       /  │  \
                      /   │   \
                     /    │    \
                    /     │     \
                   /      │      \
                  /       │       \
                 ▼        │        ▼
          INTEGRITY ◄─────┴─────► AVAILABILITY


CONFIDENTIALITY: Only authorized people can access the data
├── Breached by: Data theft, unauthorized access, eavesdropping
├── Example: Attacker steals customer database
└── Impact: Privacy violations, regulatory fines, reputation damage

INTEGRITY: Data hasn't been tampered with
├── Breached by: Unauthorized modification, data corruption
├── Example: Attacker changes financial records
└── Impact: Incorrect decisions, fraud, loss of trust

AVAILABILITY: Systems are accessible when needed
├── Breached by: DDoS attacks, ransomware, system destruction
├── Example: Attacker encrypts all files with ransomware
└── Impact: Business disruption, lost revenue, operational failure
```

When you find a vulnerability, you assess: "If exploited, does this affect Confidentiality, Integrity, Availability, or some combination?"

---

## Types of Penetration Tests

### By Knowledge Level

How much information do you start with?

```
┌─────────────────────────────────────────────────────────────────┐
│                    TESTING APPROACHES                            │
└─────────────────────────────────────────────────────────────────┘

BLACK BOX                  GRAY BOX                   WHITE BOX
(Zero Knowledge)           (Partial Knowledge)        (Full Knowledge)
     │                          │                          │
     ▼                          ▼                          ▼
┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│ You know:    │          │ You know:    │          │ You know:    │
│ - Company    │          │ - IP ranges  │          │ - Everything │
│   name       │          │ - Some creds │          │ - Source code│
│ - That's it  │          │ - App URLs   │          │ - Architecture│
│              │          │ - User roles │          │ - Credentials │
└──────────────┘          └──────────────┘          └──────────────┘
     │                          │                          │
     ▼                          ▼                          ▼
Most realistic            Balanced                   Most thorough
Most time-consuming       Most common                Most efficient
Simulates outsider        Simulates insider          Finds most bugs
                          with some access
```

| Type | Best For | Typical Duration |
|------|----------|------------------|
| **Black Box** | Simulating external attacker, testing detection | 2-4 weeks |
| **Gray Box** | Most enterprise pentests, good coverage | 1-2 weeks |
| **White Box** | Application security, code review, deep analysis | 1-3 weeks |

### By Perspective

Where are you attacking from?

```
┌─────────────────────────────────────────────────────────────────┐
│              EXTERNAL vs INTERNAL TESTING                        │
└─────────────────────────────────────────────────────────────────┘

                         INTERNET
                             │
                             ▼
                    ┌────────────────┐
                    │    FIREWALL    │
         EXTERNAL   │                │
         PENTEST    │  You start     │
         ─────────► │  HERE          │
                    └───────┬────────┘
                            │
                            ▼
              ┌─────────────────────────────┐
              │      INTERNAL NETWORK        │
              │                              │
              │    INTERNAL    ┌──────────┐ │
              │    PENTEST     │ Servers  │ │
              │    ─────────►  │ Databases│ │
              │    You start   │ Users    │ │
              │    HERE        └──────────┘ │
              │                              │
              └─────────────────────────────┘
```

**External Pentest:**
- Simulates attacker on the internet
- Tests perimeter defenses
- Can you get in from outside?

**Internal Pentest:**
- Simulates attacker already inside (employee, contractor, compromised workstation)
- Tests internal segmentation and controls
- How far can an insider go?

**Assumed Breach:**
- Starts with the assumption you're already compromised
- "You have a foothold—now what?"
- Tests detection and lateral movement

### By Target

What are you testing?

| Target Type | What You're Testing | Common Findings |
|-------------|---------------------|-----------------|
| **Network** | Infrastructure, servers, protocols | Misconfigurations, unpatched systems |
| **Web Application** | Websites, web apps, APIs | SQLi, XSS, authentication flaws |
| **Mobile Application** | iOS/Android apps | Insecure storage, API issues |
| **Wireless** | WiFi networks | Weak encryption, rogue access points |
| **Social Engineering** | People (phishing, vishing, physical) | Credential theft, policy violations |
| **Physical** | Buildings, access controls | Tailgating, badge cloning |
| **Cloud** | AWS, Azure, GCP environments | Misconfigurations, excessive permissions |

---

## Pentest vs. Other Security Activities

Don't confuse penetration testing with related activities:

```
┌─────────────────────────────────────────────────────────────────┐
│              SECURITY ASSESSMENT SPECTRUM                        │
└─────────────────────────────────────────────────────────────────┘

AUTOMATED ◄─────────────────────────────────────────► MANUAL
LOW SKILL ◄─────────────────────────────────────────► HIGH SKILL
FAST      ◄─────────────────────────────────────────► TIME-INTENSIVE
SHALLOW   ◄─────────────────────────────────────────► DEEP

│
│  Vulnerability    Security        Penetration      Red Team
│  Scan             Assessment      Test             Assessment
│    │                 │                │                │
│    ▼                 ▼                ▼                ▼
│  ┌─────┐          ┌─────┐          ┌─────┐          ┌─────┐
│  │Nessus│         │Manual│         │Manual│         │Full  │
│  │runs  │         │review│         │exploit│        │attack│
│  │auto  │         │of    │         │attempt│        │simul-│
│  │scan  │         │scan  │         │with   │        │ation │
│  │      │         │result│         │report │        │      │
│  └─────┘          └─────┘          └─────┘          └─────┘
│    │                 │                │                │
│    ▼                 ▼                ▼                ▼
│  "Here are         "Here's what     "Here's what     "Here's how
│   potential         is actually      we actually      APT actors
│   issues"           a risk"          exploited"       would attack"
```

### Comparison Table

| Activity | Automation | Exploitation | Goal | Output |
|----------|------------|--------------|------|--------|
| **Vulnerability Scan** | Fully automated | None | Find potential issues | List of CVEs |
| **Vulnerability Assessment** | Mostly automated | None | Prioritize issues | Rated findings |
| **Penetration Test** | Tools + manual | Yes, controlled | Prove exploitability | Detailed report |
| **Red Team** | Minimal, manual | Yes, realistic | Test detection/response | Attack narrative |
| **Purple Team** | Collaborative | Controlled | Improve defenses together | Joint improvements |

### Key Difference: Pentest vs Red Team

| Aspect | Penetration Test | Red Team |
|--------|------------------|----------|
| **Goal** | Find all vulnerabilities | Achieve specific objective |
| **Scope** | Defined target list | Whole organization |
| **Stealth** | Optional | Required |
| **Duration** | Days to weeks | Weeks to months |
| **Findings** | All vulnerabilities | Only what's needed for objective |
| **Blue Team Aware?** | Usually | Never |

---

## A Day in the Life of a Pentester

What does this job actually look like?

### Typical Week: Web Application Pentest

```
MONDAY - Kickoff and Recon
├── 9:00 AM  - Client kickoff call
├── 10:00 AM - Review scope, get credentials
├── 11:00 AM - Set up testing environment
├── 1:00 PM  - Passive reconnaissance
├── 3:00 PM  - Map the application
└── 5:00 PM  - Document initial findings

TUESDAY - Active Testing
├── 9:00 AM  - Authentication testing
├── 11:00 AM - Input validation testing
├── 2:00 PM  - Found SQL injection! Exploit and document
├── 4:00 PM  - Continue testing other areas
└── 6:00 PM  - Update notes

WEDNESDAY - Deep Dive
├── 9:00 AM  - Authorization testing
├── 11:00 AM - Business logic testing
├── 2:00 PM  - API testing
├── 4:00 PM  - Found IDOR! Exploit and document
└── 5:00 PM  - Client check-in call

THURSDAY - Finishing Testing
├── 9:00 AM  - Test remaining functionality
├── 11:00 AM - Retest findings to confirm
├── 2:00 PM  - Begin report writing
├── 5:00 PM  - Report drafting continues
└── Evening  - Catch up on notes

FRIDAY - Reporting
├── 9:00 AM  - Finish report writing
├── 12:00 PM - Peer review
├── 2:00 PM  - Incorporate feedback
├── 4:00 PM  - Deliver draft report
└── 5:00 PM  - Week complete!
```

### The Reality

**What pentesters actually do:**
- 40% - Documentation and report writing
- 30% - Active testing and exploitation
- 15% - Reconnaissance and enumeration
- 10% - Meetings and client communication
- 5% - Tool maintenance and learning

**Common misconceptions:**
- "It's like the movies" → Mostly typing and reading documentation
- "You're always finding 0-days" → Most findings are misconfigurations
- "It's all exploitation" → Enumeration is 80% of the work
- "You work alone" → Usually team-based, lots of communication

---

## Skills You'll Need

### Technical Skills Roadmap

```
┌─────────────────────────────────────────────────────────────────┐
│                    PENTESTER SKILL TREE                          │
└─────────────────────────────────────────────────────────────────┘

FOUNDATIONAL (Learn First)
├── Networking (TCP/IP, DNS, HTTP, etc.)
├── Linux command line
├── Windows basics
├── Basic programming (Python, Bash)
└── How the web works

INTERMEDIATE (Build On Foundation)
├── Web application security
├── Common vulnerabilities (OWASP Top 10)
├── Exploitation basics
├── Active Directory fundamentals
├── Network protocols deep dive
└── Scripting and automation

ADVANCED (Specialize)
├── Advanced exploitation
├── Reverse engineering
├── Malware analysis
├── Cloud security (AWS, Azure, GCP)
├── Mobile application security
├── Red team operations
└── Custom tool development
```

### Soft Skills (Often Overlooked)

| Skill | Why It Matters |
|-------|----------------|
| **Written Communication** | Reports are your deliverable |
| **Verbal Communication** | Explaining findings to non-technical executives |
| **Time Management** | Engagements have deadlines |
| **Attention to Detail** | Missing one finding could matter |
| **Curiosity** | "What if I try this?" drives discovery |
| **Persistence** | Many things won't work the first time |
| **Ethics** | You have access to sensitive data |

---

## Career Path

### How to Get Started

```
┌─────────────────────────────────────────────────────────────────┐
│                    CAREER PROGRESSION                            │
└─────────────────────────────────────────────────────────────────┘

LEARNING PHASE (0-2 years)
│
├── Self-study (courses, books, videos)
├── Home lab practice
├── CTF competitions
├── Bug bounty programs
├── Certifications (optional but helpful)
│
▼
ENTRY LEVEL (0-3 years experience)
│
├── Junior Penetration Tester
├── Security Analyst
├── SOC Analyst (blue team path)
├── IT Support → Security transition
│
▼
MID LEVEL (3-7 years experience)
│
├── Penetration Tester
├── Security Consultant
├── Application Security Engineer
├── Red Team Operator
│
▼
SENIOR LEVEL (7+ years experience)
│
├── Senior Penetration Tester
├── Red Team Lead
├── Principal Consultant
├── Security Architect
│
▼
LEADERSHIP (10+ years)
│
├── Practice Manager
├── CISO
├── Director of Security
└── Start your own firm
```

### Certifications

Certifications can help, especially early in your career:

| Certification | Focus | Difficulty | Value |
|---------------|-------|------------|-------|
| **CompTIA Security+** | General security fundamentals | Entry | Good foundation |
| **CEH** | Ethical hacking concepts | Entry-Mid | HR checkbox |
| **eJPT** | Practical pentesting basics | Entry | Good starter |
| **PNPT** | Practical network pentesting | Mid | Highly practical |
| **OSCP** | Hands-on exploitation | Mid-Hard | Industry gold standard |
| **OSWE** | Web application exploitation | Hard | Web app specialty |
| **OSEP** | Advanced evasion | Hard | Red team specialty |
| **GPEN/GWAPT** | SANS certifications | Mid-Hard | Enterprise recognized |

**Note:** Certifications open doors, but skills and experience keep you employed. Don't cert-collect without actually learning.

### Salary Expectations (US, 2024)

| Level | Typical Range |
|-------|---------------|
| Entry Level | $60,000 - $85,000 |
| Mid Level | $90,000 - $130,000 |
| Senior | $130,000 - $180,000 |
| Lead/Principal | $160,000 - $220,000+ |
| Consulting/Contract | $150 - $400/hour |

*Varies significantly by location, company size, and specialization*

---

## The Penetration Testing Methodology

This course follows an 8-phase methodology:

```
┌─────────────────────────────────────────────────────────────────┐
│              THE 8-PHASE PENTEST PROCESS                         │
└─────────────────────────────────────────────────────────────────┘

Phase 1: PRE-ENGAGEMENT
│         Contracts, scope, legal authorization
│
▼
Phase 2: INFORMATION GATHERING
│         OSINT, reconnaissance, enumeration
│
▼
Phase 3: VULNERABILITY ASSESSMENT
│         Identifying and validating weaknesses
│
▼
Phase 4: EXPLOITATION
│         Gaining initial access
│
▼
Phase 5: POST-EXPLOITATION
│         Privilege escalation, persistence
│
▼
Phase 6: LATERAL MOVEMENT
│         Moving through the network
│
▼
Phase 7: PROOF OF CONCEPT
│         Documenting evidence
│
▼
Phase 8: POST-ENGAGEMENT
│         Reporting, cleanup, closeout
│
└─────────────────────────────────────────────────────────────────┘
```

### Phase Overview

| Phase | Purpose | Key Activities |
|-------|---------|----------------|
| **1. Pre-Engagement** | Set the foundation | Contracts, scope, authorization |
| **2. Information Gathering** | Know your target | OSINT, scanning, enumeration |
| **3. Vulnerability Assessment** | Find weaknesses | Scanning, manual testing, analysis |
| **4. Exploitation** | Get in | Exploiting vulnerabilities, gaining access |
| **5. Post-Exploitation** | Establish position | Privilege escalation, persistence, loot |
| **6. Lateral Movement** | Spread access | Pivoting, credential reuse, AD attacks |
| **7. Proof of Concept** | Prove impact | Screenshots, scripts, documentation |
| **8. Post-Engagement** | Deliver value | Report, meeting, cleanup, closeout |

Each phase is covered in detail in the following sections.

---

## Ethics and Professionalism

### The Ethical Foundation

Penetration testing exists in a legal gray area that only authorization makes legal. Your ethics are what separate you from criminals.

```
┌─────────────────────────────────────────────────────────────────┐
│                    ETHICAL PRINCIPLES                            │
└─────────────────────────────────────────────────────────────────┘

1. AUTHORIZATION IS MANDATORY
   └── No exceptions. Ever. For any reason.

2. STAY IN SCOPE
   └── Finding something interesting doesn't authorize exploring it

3. DO NO HARM
   └── Minimize impact, avoid disruption, protect data

4. MAINTAIN CONFIDENTIALITY
   └── Client data, vulnerabilities, and methods stay private

5. REPORT HONESTLY
   └── Don't oversell, don't undersell, don't hide findings

6. ACT PROFESSIONALLY
   └── You represent the security community
```

### Things That Will End Your Career

| Action | Consequence |
|--------|-------------|
| Testing without authorization | Criminal charges |
| Exceeding scope without permission | Criminal charges, lawsuit |
| Keeping client data | Contract breach, potential charges |
| Publicly disclosing without permission | Lawsuit, industry blacklist |
| Planting actual backdoors | Criminal charges |
| Accessing systems for personal gain | Criminal charges, prison |
| Lying in reports | Lawsuit, career destruction |

---

## Tools of the Trade

You'll use many tools throughout your career. Here's a preview:

### Essential Tool Categories

| Category | Example Tools | Purpose |
|----------|---------------|---------|
| **Scanning** | Nmap, Masscan | Network discovery |
| **Web Testing** | Burp Suite, OWASP ZAP | Web app assessment |
| **Exploitation** | Metasploit, manual scripts | Gaining access |
| **Password Attacks** | Hashcat, John the Ripper | Credential cracking |
| **Post-Exploitation** | Mimikatz, BloodHound | Privilege escalation |
| **Pivoting** | Chisel, Ligolo-ng, SSH | Network tunneling |
| **Reporting** | Markdown, Word, Dradis | Documentation |

### The Pentester's Operating System

Most pentesters use **Kali Linux** or **Parrot OS** - specialized Linux distributions with security tools pre-installed.

```bash
# Kali Linux comes with:
# - 600+ security tools
# - Regular updates
# - Community support
# - VM and bare metal options

# Getting started is as simple as:
# 1. Download Kali from kali.org
# 2. Run in a VM (VirtualBox, VMware)
# 3. Start learning!
```

---

## Practice Resources

### Where to Practice Legally

| Resource | Type | Cost | Best For |
|----------|------|------|----------|
| **HackTheBox** | Online labs | Free/Paid | Realistic machines |
| **TryHackMe** | Guided learning | Free/Paid | Beginners |
| **PortSwigger Academy** | Web security | Free | Web app testing |
| **PentesterLab** | Exercises | Free/Paid | Web vulnerabilities |
| **VulnHub** | Downloadable VMs | Free | Offline practice |
| **DVWA** | Vulnerable web app | Free | Web basics |
| **HackTheBox Academy** | Courses | Paid | Structured learning |

### Building a Home Lab

```
BASIC HOME LAB SETUP

Your Computer
     │
     ▼
Virtualization Software (VirtualBox/VMware)
     │
     ├──► Kali Linux (Attack machine)
     │
     ├──► Windows VM (Target)
     │
     ├──► Linux VM (Target)
     │
     └──► Vulnerable VMs (Metasploitable, DVWA, etc.)

Estimated Cost: $0 (using free tools and VMs)
Requirements: 16GB RAM recommended, SSD helpful
```

---

## Common Mistakes Beginners Make

| Mistake | Why It's a Problem | What to Do Instead |
|---------|-------------------|-------------------|
| Jumping to exploitation | Miss vulnerabilities, waste time | Enumerate thoroughly first |
| Tool dependence | Can't adapt when tools fail | Understand concepts, not just buttons |
| Skipping documentation | Can't write reports, forget findings | Document as you go |
| Ignoring fundamentals | Advanced techniques require basics | Master networking, Linux, web first |
| Cert collecting | Certifications without skills | Learn, then certify |
| Working in isolation | Miss community knowledge | Join Discord, forums, Twitter/X |
| Testing without permission | Criminal charges | Only test authorized systems |
| Giving up too quickly | Miss findings that require persistence | Enumerate harder |

---

## Summary

Penetration testing is a career where you get paid to think like an attacker and help organizations defend themselves. It requires:

1. **Technical skills** - Networking, systems, programming, security concepts
2. **Soft skills** - Communication, documentation, professionalism
3. **Ethics** - Authorization, scope adherence, confidentiality
4. **Continuous learning** - The field changes constantly

**Key Takeaways:**

- Authorization is what separates you from a criminal
- Enumeration is 80% of the work
- Reports are your actual deliverable
- The 8-phase methodology provides structure
- Practice legally and continuously
- Ethics are non-negotiable

Welcome to the field. Now let's start learning the methodology.

---

## Next Steps

Continue to the following sections:

1. **[Laws and Regulations](laws_and_regs.md)** - Understand the legal landscape
2. **[Phase 1: Pre-Engagement](../phases/1_pre-engagement.md)** - Start the methodology

---

## Additional Resources

### Books
- "The Web Application Hacker's Handbook" - Stuttard & Pinto
- "Penetration Testing" - Georgia Weidman
- "Red Team Field Manual" - Ben Clark
- "The Hacker Playbook" series - Peter Kim

### Online Learning
- HackTheBox Academy
- TryHackMe
- PortSwigger Web Security Academy
- SANS Cyber Aces (free)

### Communities
- r/netsec (Reddit)
- HackTheBox Discord
- InfoSec Twitter/X
- Local DEF CON groups
