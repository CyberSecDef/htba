# The Penetration Testing Process

> **Your Roadmap for Every Engagement**

---

## What You'll Learn

By the end of this section, you'll understand:

- The 8-phase penetration testing methodology
- How each phase builds on the previous
- What you should accomplish in each phase
- How phases interconnect and iterate
- Time allocation guidelines
- Entry and exit criteria for each phase
- What to do when you get stuck
- How the process adapts to different engagement types

---

## Key Terms

| Term | Definition |
|------|------------|
| **Methodology** | A structured approach to conducting penetration tests |
| **Phase** | A distinct stage in the testing process with specific goals |
| **Iteration** | Returning to a previous phase with new information |
| **Scope Creep** | Uncontrolled expansion beyond the original boundaries |
| **Deliverable** | A tangible output produced during or after testing |
| **Entry Criteria** | What must be true before starting a phase |
| **Exit Criteria** | What must be complete before moving to the next phase |

---

## Why Process Matters

Imagine trying to build a house by randomly installing plumbing, then putting up walls, then pouring the foundation. It wouldn't work. The order matters.

Penetration testing is the same. You can't exploit vulnerabilities you haven't found. You can't find vulnerabilities in systems you haven't enumerated. You can't enumerate systems you don't have permission to test.

**The process provides:**
- **Structure** - Know what to do next
- **Completeness** - Don't miss important steps
- **Efficiency** - Don't waste time on the wrong things
- **Consistency** - Deliver reliable results every time
- **Communication** - Explain where you are to clients

---

## The 8-Phase Model

```
┌─────────────────────────────────────────────────────────────────┐
│              THE PENETRATION TESTING PROCESS                     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   ┌──────────────┐                                              │
│   │    PHASE 1   │                                              │
│   │     Pre-     │  Contracts, scope, authorization            │
│   │  Engagement  │                                              │
│   └──────┬───────┘                                              │
│          │                                                      │
│          ▼                                                      │
│   ┌──────────────┐                                              │
│   │    PHASE 2   │                                              │
│   │ Information  │  OSINT, scanning, enumeration               │
│   │  Gathering   │                                              │
│   └──────┬───────┘                                              │
│          │                                                      │
│          ▼                                                      │
│   ┌──────────────┐                                              │
│   │    PHASE 3   │                                              │
│   │Vulnerability │  Finding and validating weaknesses          │
│   │  Assessment  │                                              │
│   └──────┬───────┘                                              │
│          │                                                      │
│          ▼                                                      │
│   ┌──────────────┐                                              │
│   │    PHASE 4   │                                              │
│   │ Exploitation │  Gaining initial access                     │
│   │              │                                              │
│   └──────┬───────┘                                              │
│          │                                                      │
│          ▼                                                      │
│   ┌──────────────┐     ┌──────────────┐                        │
│   │    PHASE 5   │     │    PHASE 6   │                        │
│   │    Post-     │◄───►│   Lateral    │  These phases         │
│   │ Exploitation │     │   Movement   │  iterate together      │
│   └──────┬───────┘     └──────┬───────┘                        │
│          │                    │                                 │
│          └────────┬───────────┘                                 │
│                   │                                              │
│                   ▼                                              │
│   ┌──────────────┐                                              │
│   │    PHASE 7   │                                              │
│   │   Proof of   │  Documenting evidence                       │
│   │   Concept    │                                              │
│   └──────┬───────┘                                              │
│          │                                                      │
│          ▼                                                      │
│   ┌──────────────┐                                              │
│   │    PHASE 8   │                                              │
│   │    Post-     │  Reporting and closeout                     │
│   │  Engagement  │                                              │
│   └──────────────┘                                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase Overview Table

| Phase | Purpose | Key Activities | Typical Time |
|-------|---------|----------------|--------------|
| **1. Pre-Engagement** | Set the foundation | Contracts, scope, authorization | Before testing |
| **2. Information Gathering** | Know your target | OSINT, scanning, enumeration | 20-30% |
| **3. Vulnerability Assessment** | Find weaknesses | Scanning, analysis, validation | 15-20% |
| **4. Exploitation** | Get in | Exploit vulnerabilities, gain access | 15-20% |
| **5. Post-Exploitation** | Establish position | Privesc, persistence, looting | 10-15% |
| **6. Lateral Movement** | Spread access | Pivoting, credential reuse | 10-15% |
| **7. Proof of Concept** | Prove impact | Screenshots, scripts, evidence | Ongoing |
| **8. Post-Engagement** | Deliver value | Report, meeting, cleanup | After testing |

**Note:** Time allocations are rough guidelines. Actual time varies by engagement type and findings.

---

## Phase 1: Pre-Engagement

### What Happens

Before any testing begins, you establish the legal and technical foundation.

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRE-ENGAGEMENT                                │
└─────────────────────────────────────────────────────────────────┘

INPUTS                          OUTPUTS
────────                        ───────
• Client request               • Signed contract
• Initial discussions          • Statement of Work (SoW)
• Business requirements        • Rules of Engagement (RoE)
                               • Scope document
                               • NDA
                               • Authorization letter
                               • Emergency contacts
```

### Entry Criteria
- Client has expressed interest in testing
- Initial contact established

### Exit Criteria
- [ ] Contract signed
- [ ] Scope clearly defined (in and out)
- [ ] Authorization letter signed
- [ ] Rules of Engagement documented
- [ ] Testing window confirmed
- [ ] Emergency contacts provided
- [ ] Payment terms agreed

### Common Pitfalls
| Pitfall | Consequence | Prevention |
|---------|-------------|------------|
| Vague scope | Scope creep, disputes | Be specific: IPs, URLs, apps |
| Missing authorization | Legal liability | Get signatures before testing |
| No emergency contact | Can't stop testing safely | Require 24/7 contact |
| Assumptions about access | Delays, blocked testing | Document exactly what's provided |

### Detailed Coverage
See: **[Phase 1: Pre-Engagement](../phases/1_pre-engagement.md)**

---

## Phase 2: Information Gathering

### What Happens

Collect as much information as possible about the target before looking for vulnerabilities.

```
┌─────────────────────────────────────────────────────────────────┐
│                 INFORMATION GATHERING                            │
└─────────────────────────────────────────────────────────────────┘

PASSIVE                              ACTIVE
(No direct contact)                  (Direct contact with target)
───────────────                      ──────────────────────────────
• OSINT research                     • Port scanning
• DNS records                        • Service enumeration
• WHOIS lookups                      • Banner grabbing
• Social media                       • Web spidering
• Job postings                       • Directory brute forcing
• Public documents                   • Technology fingerprinting
• Certificate transparency           • Virtual host discovery
• Wayback Machine                    • Network mapping
```

### Entry Criteria
- Pre-engagement complete
- Authorization in place
- Testing window has begun

### Exit Criteria
- [ ] Target IP addresses/domains identified
- [ ] Open ports and services enumerated
- [ ] Technologies/versions identified
- [ ] Potential attack surface mapped
- [ ] Findings documented
- [ ] Ready to assess for vulnerabilities

### The Enumeration Mantra

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│         "ENUMERATE HARDER"                                      │
│                                                                 │
│    When you think you're done enumerating, you're not.         │
│    Go back and enumerate more.                                  │
│                                                                 │
│    80% of a successful pentest is thorough enumeration.        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Common Pitfalls
| Pitfall | Consequence | Prevention |
|---------|-------------|------------|
| Rushing to exploit | Miss vulnerabilities | Spend adequate time enumerating |
| Only scanning common ports | Miss services on high ports | Scan all 65535 ports |
| Ignoring OSINT | Miss public information | Always do passive recon first |
| Poor documentation | Forget what you found | Document as you go |

### Detailed Coverage
See: **[Phase 2: Information Gathering](../phases/2_information_gathering.md)**

---

## Phase 3: Vulnerability Assessment

### What Happens

Analyze the information gathered to identify potential vulnerabilities.

```
┌─────────────────────────────────────────────────────────────────┐
│                VULNERABILITY ASSESSMENT                          │
└─────────────────────────────────────────────────────────────────┘

                    INFORMATION
                    GATHERED
                        │
                        ▼
         ┌──────────────────────────────┐
         │     Vulnerability Scanning    │
         │  (Nessus, OpenVAS, Nuclei)   │
         └──────────────┬───────────────┘
                        │
                        ▼
         ┌──────────────────────────────┐
         │      Manual Analysis          │
         │  (Research, testing, logic)  │
         └──────────────┬───────────────┘
                        │
                        ▼
         ┌──────────────────────────────┐
         │       Prioritization          │
         │  (CVSS, exploitability)      │
         └──────────────┬───────────────┘
                        │
                        ▼
                   POTENTIAL
                   VULNERABILITIES
```

### Entry Criteria
- Information gathering substantially complete
- Services and versions identified
- Attack surface understood

### Exit Criteria
- [ ] Automated scans completed
- [ ] Manual analysis performed
- [ ] Potential vulnerabilities identified
- [ ] Vulnerabilities prioritized for exploitation
- [ ] False positives filtered where possible
- [ ] Ready to attempt exploitation

### Types of Vulnerabilities You're Looking For

| Category | Examples |
|----------|----------|
| **Misconfigurations** | Default credentials, open shares, verbose errors |
| **Missing Patches** | Known CVEs, outdated software |
| **Weak Credentials** | Guessable passwords, password reuse |
| **Design Flaws** | Insecure authentication, broken access control |
| **Injection Flaws** | SQLi, command injection, XSS |
| **Cryptographic Issues** | Weak encryption, exposed keys |

### Common Pitfalls
| Pitfall | Consequence | Prevention |
|---------|-------------|------------|
| Trusting scanner output blindly | False positives waste time | Always validate findings |
| Ignoring "low" severity issues | Miss attack chains | Low + Low can = Critical |
| Not researching versions | Miss known CVEs | Search for CVEs manually |
| Only checking common vulns | Miss unusual issues | Think creatively |

### Detailed Coverage
See: **[Phase 3: Vulnerability Assessment](../phases/3_vulnerability_assessment.md)**

---

## Phase 4: Exploitation

### What Happens

Attempt to exploit identified vulnerabilities to gain access.

```
┌─────────────────────────────────────────────────────────────────┐
│                      EXPLOITATION                                │
└─────────────────────────────────────────────────────────────────┘

VULNERABILITY              EXPLOITATION                INITIAL
  IDENTIFIED                  ATTEMPT                   ACCESS
      │                         │                         │
      ▼                         ▼                         ▼
┌───────────┐            ┌───────────┐            ┌───────────┐
│ Research  │───────────▶│  Prepare  │───────────▶│  Execute  │
│ exploit   │            │  payload  │            │  exploit  │
│ options   │            │  & tools  │            │           │
└───────────┘            └───────────┘            └─────┬─────┘
                                                        │
                    ┌───────────────────────────────────┤
                    │                                   │
                    ▼                                   ▼
             ┌───────────┐                       ┌───────────┐
             │  SUCCESS  │                       │  FAILURE  │
             │  Initial  │                       │  Try next │
             │  access!  │                       │  vuln     │
             └───────────┘                       └───────────┘
```

### Entry Criteria
- Vulnerabilities identified and prioritized
- Exploitation approach planned
- Tools and payloads prepared

### Exit Criteria
- [ ] Attempted exploitation of viable vulnerabilities
- [ ] Initial access obtained (or documented why not possible)
- [ ] Access type documented (shell, GUI, API, etc.)
- [ ] Access level documented (user, service, limited shell)
- [ ] Evidence captured
- [ ] Ready for post-exploitation

### Exploitation Priority Order

Test in this order for efficiency:

```
1. QUICK WINS (try these first)
   ├── Default credentials
   ├── Known exploits with public PoC
   ├── Simple misconfigurations
   └── Password spraying

2. MODERATE EFFORT
   ├── Exploits requiring customization
   ├── Chained vulnerabilities
   ├── Application-specific flaws
   └── Credential attacks (cracking)

3. COMPLEX (if time permits)
   ├── Custom exploit development
   ├── Logic flaws requiring deep analysis
   ├── Race conditions
   └── Memory corruption
```

### Common Pitfalls
| Pitfall | Consequence | Prevention |
|---------|-------------|------------|
| Trying hardest exploits first | Waste time | Start with quick wins |
| Using "destructive" exploits | Crash systems, get fired | Test carefully, have backups |
| Not capturing evidence | Can't prove it in report | Screenshot everything |
| Giving up too early | Miss working exploits | Try multiple approaches |

### Detailed Coverage
See: **[Phase 4: Exploitation](../phases/4_exploitation.md)**

---

## Phase 5: Post-Exploitation

### What Happens

After gaining initial access, establish your position and gather valuable information.

```
┌─────────────────────────────────────────────────────────────────┐
│                    POST-EXPLOITATION                             │
└─────────────────────────────────────────────────────────────────┘

                    INITIAL ACCESS
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Situational │ │  Privilege   │ │  Credential  │
│  Awareness   │ │  Escalation  │ │  Harvesting  │
│              │ │              │ │              │
│ • Who am I?  │ │ • Local      │ │ • Memory     │
│ • Where am I?│ │   privesc    │ │ • Files      │
│ • What's here│ │ • Domain     │ │ • Databases  │
└──────────────┘ │   privesc    │ └──────────────┘
                 └──────────────┘
        │                │                │
        └────────────────┼────────────────┘
                         │
                         ▼
                ┌──────────────┐
                │  Persistence │
                │  (optional)  │
                └──────────────┘
```

### Entry Criteria
- Initial access obtained
- Shell or other access established
- Access is stable (won't die immediately)

### Exit Criteria
- [ ] Situational awareness complete
- [ ] Privilege escalation attempted
- [ ] Highest achievable privileges obtained
- [ ] Credentials harvested
- [ ] Sensitive data identified
- [ ] Ready for lateral movement (or testing complete)

### Post-Exploitation Checklist

```
SITUATIONAL AWARENESS
  [ ] Current user and privileges
  [ ] Hostname and IP address
  [ ] Operating system and version
  [ ] Running processes
  [ ] Network connections
  [ ] Other users logged in
  [ ] Installed software
  [ ] Scheduled tasks/cron jobs

PRIVILEGE ESCALATION
  [ ] Check sudo/admin rights
  [ ] Search for privilege escalation vectors
  [ ] Attempt escalation to root/SYSTEM
  [ ] Document escalation path

CREDENTIAL HARVESTING
  [ ] Dump memory for credentials
  [ ] Search files for passwords
  [ ] Extract browser credentials
  [ ] Check for SSH keys
  [ ] Dump local password hashes

DATA DISCOVERY
  [ ] Find sensitive files
  [ ] Identify databases
  [ ] Locate configuration files
  [ ] Document what's accessible
```

### Common Pitfalls
| Pitfall | Consequence | Prevention |
|---------|-------------|------------|
| Skipping situational awareness | Miss important context | Always enumerate the system |
| Noisy credential dumping | Detection and blocking | Use quieter techniques |
| Not documenting access | Can't reproduce in report | Document step-by-step |
| Losing access | Have to re-exploit | Establish persistence if allowed |

### Detailed Coverage
See: **[Phase 5: Post-Exploitation](../phases/5_post_exploitation.md)**

---

## Phase 6: Lateral Movement

### What Happens

Move from your initial foothold to other systems in the network.

```
┌─────────────────────────────────────────────────────────────────┐
│                    LATERAL MOVEMENT                              │
└─────────────────────────────────────────────────────────────────┘

              ┌──────────────┐
              │   Initial    │
              │   Foothold   │
              │   (Host A)   │
              └──────┬───────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
        ▼            ▼            ▼
   ┌─────────┐  ┌─────────┐  ┌─────────┐
   │ Host B  │  │ Host C  │  │ Host D  │
   │         │  │         │  │ (DC)    │
   └────┬────┘  └─────────┘  └────┬────┘
        │                         │
        ▼                         ▼
   ┌─────────┐              ┌─────────┐
   │ Host E  │              │ DOMAIN  │
   │         │              │ ADMIN   │
   └─────────┘              └─────────┘

   Movement methods:
   • Credential reuse (passwords, hashes)
   • Stolen tickets (Kerberos)
   • Exploitation of new vulnerabilities
   • Trust relationships
```

### Entry Criteria
- Post-exploitation complete on at least one host
- Credentials or access method for other systems
- Internal network reachable

### Exit Criteria
- [ ] Internal network enumerated
- [ ] Credential validity tested
- [ ] Additional systems compromised (if possible)
- [ ] Highest-value targets accessed (or documented why not)
- [ ] Attack path documented
- [ ] Ready to document findings

### The Lateral Movement Loop

Phases 5 and 6 often iterate together:

```
┌─────────────────────────────────────────────────────────────────┐
│              THE POST-EXPLOITATION LOOP                          │
└─────────────────────────────────────────────────────────────────┘

    ┌───────────────────────────────────────────────┐
    │                                               │
    │    Compromise      Post-         Move        │
    │    Host        ──► Exploitation ──► Laterally │
    │                    • Enumerate     to new     │
    │        ▲           • Escalate      host       │
    │        │           • Harvest                  │
    │        │           • Loot          │          │
    │        │                           │          │
    │        └───────────────────────────┘          │
    │                                               │
    │    Repeat until:                              │
    │    • Objective achieved                       │
    │    • Time exhausted                           │
    │    • No more movement possible                │
    │                                               │
    └───────────────────────────────────────────────┘
```

### Common Pitfalls
| Pitfall | Consequence | Prevention |
|---------|-------------|------------|
| Not testing credential reuse | Miss easy wins | Try creds everywhere |
| Moving too fast | Trigger alerts | Be methodical |
| Forgetting to document | Can't recreate path | Document each hop |
| Ignoring Linux hosts | Miss part of network | Check all OS types |

### Detailed Coverage
See: **[Phase 6: Lateral Movement](../phases/6_lateral_movement.md)**

---

## Phase 7: Proof of Concept

### What Happens

Document evidence throughout testing to prove your findings.

```
┌─────────────────────────────────────────────────────────────────┐
│                    PROOF OF CONCEPT                              │
└─────────────────────────────────────────────────────────────────┘

                DURING TESTING
                      │
    ┌─────────────────┼─────────────────┐
    │                 │                 │
    ▼                 ▼                 ▼
┌─────────┐     ┌─────────┐     ┌─────────┐
│ Screen- │     │ Command │     │ Scripts │
│ shots   │     │ Outputs │     │ & Logs  │
└────┬────┘     └────┬────┘     └────┬────┘
     │               │               │
     └───────────────┼───────────────┘
                     │
                     ▼
              ┌─────────────┐
              │  Organized  │
              │  Evidence   │
              │   Folder    │
              └──────┬──────┘
                     │
                     ▼
              ┌─────────────┐
              │   Report    │
              │ Integration │
              └─────────────┘
```

### Key Point: PoC Is Ongoing

**Proof of Concept is NOT a separate phase you do at the end.** It happens throughout testing:

- Take screenshots as you exploit
- Save command outputs immediately
- Document your steps in real-time
- Don't rely on memory

### PoC Documentation Checklist

```
FOR EACH FINDING:

  [ ] Command/action that triggered it
  [ ] Output showing the vulnerability
  [ ] Screenshot with context (hostname, timestamp)
  [ ] Steps to reproduce
  [ ] Impact demonstrated
  [ ] Evidence saved and organized
```

### Common Pitfalls
| Pitfall | Consequence | Prevention |
|---------|-------------|------------|
| "I'll screenshot later" | Forget or can't reproduce | Document immediately |
| Unclear screenshots | Can't tell what's shown | Include context in every shot |
| No command history | Can't reproduce steps | Log all commands |
| Scattered evidence | Hard to write report | Use organized folder structure |

### Detailed Coverage
See: **[Phase 7: Proof of Concept](../phases/7_proof_of_concept.md)**

---

## Phase 8: Post-Engagement

### What Happens

Conclude the engagement professionally with deliverables and cleanup.

```
┌─────────────────────────────────────────────────────────────────┐
│                    POST-ENGAGEMENT                               │
└─────────────────────────────────────────────────────────────────┘

TESTING                      POST-ENGAGEMENT
COMPLETE                     ACTIVITIES
    │                             │
    │     ┌───────────────────────┼───────────────────────┐
    │     │                       │                       │
    │     ▼                       ▼                       ▼
    │ ┌─────────┐           ┌─────────┐           ┌─────────┐
    │ │ Cleanup │           │ Report  │           │ Client  │
    │ │         │           │ Writing │           │ Debrief │
    │ │• Remove │           │         │           │         │
    │ │  tools  │           │• Exec   │           │• Walk   │
    │ │• Revert │           │  summary│           │  through│
    │ │  changes│           │• Details│           │• Answer │
    │ │• Delete │           │• PoCs   │           │  Qs     │
    │ │  data   │           │• Recs   │           │• Clarify│
    │ └─────────┘           └─────────┘           └─────────┘
    │     │                       │                       │
    │     └───────────────────────┼───────────────────────┘
    │                             │
    │                             ▼
    │                       ┌─────────┐
    │                       │Closeout │
    │                       │• Retest │
    │                       │• Archive│
    │                       │• Invoice│
    └──────────────────────►└─────────┘
```

### Entry Criteria
- Testing window complete
- All findings documented
- Evidence organized

### Exit Criteria
- [ ] Systems cleaned up
- [ ] Draft report delivered
- [ ] Report review meeting conducted
- [ ] Final report delivered
- [ ] Remediation retest complete (if applicable)
- [ ] Data securely archived
- [ ] Engagement formally closed

### Common Pitfalls
| Pitfall | Consequence | Prevention |
|---------|-------------|------------|
| Incomplete cleanup | Tools left behind | Use cleanup checklist |
| Rushed report | Poor quality, disputes | Allocate adequate time |
| Missing exec summary | Leadership doesn't read | Always include non-technical summary |
| No retest | Vulns may not be fixed | Include retest in scope |

### Detailed Coverage
See: **[Phase 8: Post-Engagement](../phases/8_post_engagement.md)**

---

## How Phases Connect

The process isn't strictly linear. Here's how phases actually interact:

```
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE INTERACTIONS                            │
└─────────────────────────────────────────────────────────────────┘

                Pre-Engagement
                      │
                      ▼
              Information Gathering ◄────────────┐
                      │                          │
                      ▼                          │
              Vulnerability Assessment           │
                      │                          │
                      ▼                          │
                 Exploitation                    │ Return to
                      │                          │ gather more
                      ▼                          │ info when
                Post-Exploitation ◄──────┐      │ stuck
                      │                  │      │
                      ▼                  │      │
                Lateral Movement ────────┘──────┘
                      │
                      ▼
                Proof of Concept ◄─── (Ongoing throughout)
                      │
                      ▼
                Post-Engagement
```

### When to Go Back

| Situation | Go Back To |
|-----------|-----------|
| Exploitation fails | Information Gathering (enumerate more) |
| Can't escalate privileges | Information Gathering (on current host) |
| Lateral movement blocked | Post-Exploitation (get more creds) |
| New network segment discovered | Information Gathering (on new segment) |
| Need more evidence | Proof of Concept (capture now!) |

---

## Process by Engagement Type

The same phases apply, but emphasis changes:

### External Network Pentest

```
Phase emphasis:
├── Information Gathering: HIGH (external recon critical)
├── Vulnerability Assessment: MEDIUM
├── Exploitation: HIGH (getting in is the challenge)
├── Post-Exploitation: MEDIUM (if you get in)
├── Lateral Movement: HIGH (if you get in)
└── Focus: Can an external attacker breach the perimeter?
```

### Internal Network Pentest

```
Phase emphasis:
├── Information Gathering: MEDIUM (internal scanning)
├── Vulnerability Assessment: MEDIUM
├── Exploitation: MEDIUM (often easier internally)
├── Post-Exploitation: HIGH (privesc is key)
├── Lateral Movement: HIGH (how far can you go?)
└── Focus: What can an insider or compromised system achieve?
```

### Web Application Pentest

```
Phase emphasis:
├── Information Gathering: HIGH (app mapping critical)
├── Vulnerability Assessment: HIGH (most time here)
├── Exploitation: MEDIUM (proving vulns)
├── Post-Exploitation: LOW (usually app-focused)
├── Lateral Movement: LOW (unless app leads to servers)
└── Focus: What vulnerabilities exist in the application?
```

### Red Team Engagement

```
Phase emphasis:
├── Information Gathering: VERY HIGH (extensive OSINT)
├── Vulnerability Assessment: MEDIUM (find any way in)
├── Exploitation: HIGH (initial access)
├── Post-Exploitation: VERY HIGH (stealth critical)
├── Lateral Movement: VERY HIGH (reach objectives)
└── Focus: Can you achieve the specific objective undetected?
```

---

## Time Allocation Guidelines

### Standard 1-Week Engagement

```
┌─────────────────────────────────────────────────────────────────┐
│                    TYPICAL WEEK                                  │
└─────────────────────────────────────────────────────────────────┘

MON         TUE         WED         THU         FRI
│           │           │           │           │
▼           ▼           ▼           ▼           ▼
┌─────┐   ┌─────┐     ┌─────┐     ┌─────┐     ┌─────┐
│Info │   │Vuln │     │Expl │     │Post │     │Report│
│Gath.│   │Assmt│     │oit  │     │Expl.│     │Write │
│     │   │     │     │     │     │Latrl│     │      │
│     │   │     │     │     │     │Move │     │      │
└─────┘   └─────┘     └─────┘     └─────┘     └─────┘

PoC documentation happens throughout
```

### When You're Stuck

If you're not making progress:

```
┌─────────────────────────────────────────────────────────────────┐
│                    STUCK? TRY THIS                               │
└─────────────────────────────────────────────────────────────────┘

1. ENUMERATE MORE
   └── "Enumerate harder" is almost always the answer

2. STEP BACK
   └── Review what you have, look for missed paths

3. RESEARCH
   └── Google the service versions you found

4. TRY DIFFERENT TOOLS
   └── One tool's output may differ from another

5. CHANGE APPROACH
   └── Web not working? Try network. Network not working? Try social.

6. ASK FOR HELP
   └── Team members, forums, Discord (without violating NDA)

7. DOCUMENT AND MOVE ON
   └── If truly blocked, document and try next target
```

---

## Deliverables by Phase

| Phase | Deliverables |
|-------|--------------|
| **Pre-Engagement** | Contract, SoW, RoE, Authorization, NDA |
| **Information Gathering** | Asset inventory, technology list, network map |
| **Vulnerability Assessment** | Vulnerability list, prioritized targets |
| **Exploitation** | Access evidence, shell screenshots |
| **Post-Exploitation** | Privilege proof, credential list, data samples |
| **Lateral Movement** | Attack path diagram, compromised systems list |
| **Proof of Concept** | Screenshots, scripts, step-by-step documentation |
| **Post-Engagement** | Report, executive summary, retest results |

---

## Common Mistakes by Phase

| Phase | Common Mistake | Impact |
|-------|---------------|--------|
| Pre-Engagement | Vague scope | Disputes, legal issues |
| Information Gathering | Insufficient enumeration | Miss attack vectors |
| Vulnerability Assessment | Trust scanners blindly | Chase false positives |
| Exploitation | Try complex exploits first | Waste time |
| Post-Exploitation | Skip situational awareness | Miss context |
| Lateral Movement | Don't test credential reuse | Miss easy wins |
| Proof of Concept | Document at the end | Forget details, can't reproduce |
| Post-Engagement | Rush the report | Poor deliverable quality |

---

## Summary

The penetration testing process provides structure without being a rigid checklist:

1. **Pre-Engagement** - Get authorization and define scope
2. **Information Gathering** - Know your target thoroughly
3. **Vulnerability Assessment** - Find the weaknesses
4. **Exploitation** - Prove the vulnerabilities are real
5. **Post-Exploitation** - Establish your position
6. **Lateral Movement** - Expand your access
7. **Proof of Concept** - Document everything (ongoing)
8. **Post-Engagement** - Deliver professional results

**Key Principles:**

- The phases build on each other
- You can (and should) iterate back when needed
- Documentation happens throughout, not at the end
- Each phase has clear entry and exit criteria
- Time allocation varies by engagement type
- When stuck, enumerate harder

The process is a framework, not a script. Every engagement is different, but the methodology provides consistent structure for delivering quality results.

---

## Next Steps

Now that you understand the process, dive into each phase:

1. **[Phase 1: Pre-Engagement](../phases/1_pre-engagement.md)**
2. **[Phase 2: Information Gathering](../phases/2_information_gathering.md)**
3. **[Phase 3: Vulnerability Assessment](../phases/3_vulnerability_assessment.md)**
4. **[Phase 4: Exploitation](../phases/4_exploitation.md)**
5. **[Phase 5: Post-Exploitation](../phases/5_post_exploitation.md)**
6. **[Phase 6: Lateral Movement](../phases/6_lateral_movement.md)**
7. **[Phase 7: Proof of Concept](../phases/7_proof_of_concept.md)**
8. **[Phase 8: Post-Engagement](../phases/8_post_engagement.md)**
