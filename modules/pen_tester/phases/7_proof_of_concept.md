# Proof of Concept Phase

> **Phase 7 of 8** in the Penetration Testing Process

---

## What You'll Learn

By the end of this section, you'll understand:

- What a Proof of Concept (PoC) is and why it matters
- The three types of PoCs: documentation, scripts, and videos
- How to take professional screenshots that tell a story
- How to document attack chains from start to finish
- How to write PoC scripts that clients can safely reproduce
- How to integrate your PoCs into the final report
- Common mistakes that weaken your findings

---

## Key Terms

| Term | Definition |
|------|------------|
| **Proof of Concept (PoC)** | Evidence that demonstrates a vulnerability exists and can be exploited |
| **Attack Chain** | The sequence of steps from initial access to final objective |
| **Reproducibility** | The ability for someone else to follow your steps and get the same result |
| **Evidence** | Screenshots, logs, outputs, and recordings that prove your findings |
| **Finding** | A documented security issue with evidence, impact, and remediation |
| **Root Cause** | The underlying issue that made the vulnerability possible |

---

## Prerequisites

Before creating your PoCs, you should have:

- Completed exploitation and achieved your testing objectives
- Documented your activities during testing (notes, commands, outputs)
- Identified all vulnerabilities you want to include in your report
- Understood the client's reporting requirements from the RoE

---

## What Is a Proof of Concept?

Think of a PoC like evidence in a court case. You're not just claiming something is true—you're *proving* it with concrete evidence that others can verify.

A PoC answers three questions:
1. **Does this vulnerability exist?** (Evidence)
2. **Can it actually be exploited?** (Demonstration)
3. **What's the real-world impact?** (Business risk)

Without a good PoC, your finding is just an opinion. With a good PoC, it's undeniable proof that demands action.

---

## Why PoCs Matter

```
┌─────────────────────────────────────────────────────────────────┐
│                    THE POC SPECTRUM                              │
└─────────────────────────────────────────────────────────────────┘

 Weak PoC                                              Strong PoC
    │                                                      │
    ▼                                                      ▼
┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐
│ "I think   │  │ Scanner    │  │ Screenshot │  │ Full chain │
│ there's a  │  │ output     │  │ of exploit │  │ with video │
│ vuln here" │  │ showing    │  │ working    │  │ & script   │
│            │  │ potential  │  │            │  │            │
└────────────┘  └────────────┘  └────────────┘  └────────────┘
     │                │                │                │
     ▼                ▼                ▼                ▼
  Ignored         Questioned       Accepted        Prioritized
```

**Good PoCs get vulnerabilities fixed. Bad PoCs get findings disputed.**

---

## The Three Types of PoCs

### Type 1: Documentation-Based PoC

Written evidence with screenshots and command outputs.

**Best for:**
- Most findings in a penetration test report
- Vulnerabilities that are easy to understand visually
- Clients who prefer reading over watching

**Components:**
- Step-by-step instructions
- Screenshots at each critical step
- Command inputs and outputs
- Clear explanation of what's happening

### Type 2: Script-Based PoC

Automated code that demonstrates the vulnerability.

**Best for:**
- Complex vulnerabilities requiring many steps
- Findings that need to be reproducible by developers
- Technical audiences who want to test fixes

**Components:**
- Clean, commented code
- Usage instructions
- Safety considerations
- Expected output

### Type 3: Video-Based PoC

Screen recording showing the full exploitation.

**Best for:**
- Executive presentations
- Complex attack chains that are hard to follow in text
- Demonstrating timing-sensitive attacks
- Training materials

**Components:**
- Narration or text overlay explaining steps
- Clear screen capture showing all actions
- Reasonable pace (not too fast)
- Highlight important moments

---

## The PoC Creation Process

```
┌─────────────────────────────────────────────────────────────────┐
│                    POC CREATION WORKFLOW                         │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │   Identify   │  ← What are you proving?
    │   Finding    │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   Gather     │  ← Collect screenshots, logs, outputs
    │   Evidence   │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   Document   │  ← Write clear steps to reproduce
    │    Steps     │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   Verify     │  ← Can someone else follow your steps?
    │   Repro      │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   Package    │  ← Format for report integration
    │     PoC      │
    └──────────────┘
```

---

## Step 1: Take Professional Screenshots

Screenshots are your primary evidence. Bad screenshots undermine even valid findings.

### What Makes a Good Screenshot

| Good Screenshot | Bad Screenshot |
|-----------------|----------------|
| Shows full context (URL, timestamp) | Cropped so tight you can't tell what's happening |
| Highlights important elements | Busy screen with no focus |
| Includes command AND output | Shows only output without the command |
| Readable resolution | Blurry or pixelated |
| Annotated when helpful | Requires explanation to understand |

### Screenshot Best Practices

```
┌─────────────────────────────────────────────────────────────────┐
│              ANATOMY OF A GOOD SCREENSHOT                        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  Terminal - user@kali:~                                    [─][□][×]│
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─── Shows the full command                                   │
│  │                                                              │
│  ▼                                                              │
│  $ sqlmap -u "http://target/page.php?id=1" --dbs              │
│                                                                 │
│  [*] starting @ 14:32:15                                       │
│  [14:32:15] [INFO] testing connection to target URL           │
│  [14:32:16] [INFO] target URL is vulnerable                   │
│  ...                                                            │
│  available databases [3]:  ◄─── Key finding highlighted        │
│  [*] information_schema                                        │
│  [*] mysql                                                      │
│  [*] webapp_production   ◄─── This is what matters             │
│                                                                 │
│  $ _                                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
   ▲
   │
   └─── Visible prompt shows command completed
```

### Screenshot Checklist

Before taking a screenshot, verify:

- [ ] Command/action is visible (what you did)
- [ ] Output/result is visible (what happened)
- [ ] Context is clear (which system, which user)
- [ ] Timestamp visible if relevant
- [ ] Sensitive data redacted if needed (except for PoC systems)
- [ ] Resolution is readable when embedded in report

### Annotation Tips

Use annotations to guide the reader's eye:

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│    ┌──────────────────────────────────┐            │
│    │  Password: admin123              │◄─── Arrow  │
│    └──────────────────────────────────┘     points │
│              ▲                               to key│
│              │                               info  │
│         Box highlights                             │
│         important data                             │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Annotation tools:**
- Flameshot (Linux) - Best for pentesters
- Greenshot (Windows)
- macOS Screenshot with Markup
- GIMP/Paint for quick edits

---

## Step 2: Document Your Attack Chain

An attack chain shows how individual vulnerabilities combine to create significant impact.

### Why Attack Chains Matter

Single vulnerabilities often seem low-risk in isolation:

```
Individual Findings (seem minor):
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Information  │  │ Default      │  │ Misconfigured│
│ Disclosure   │  │ Credentials  │  │ Permissions  │
│ (Low)        │  │ (Medium)     │  │ (Medium)     │
└──────────────┘  └──────────────┘  └──────────────┘

Combined Attack Chain (critical impact):
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ Found admin  │────▶│ Logged in    │────▶│ Escalated to │
│ username in  │     │ with default │     │ Domain Admin │
│ HTML comment │     │ password     │     │ via service  │
└──────────────┘     └──────────────┘     └──────────────┘
                                                 │
                                                 ▼
                                          FULL DOMAIN
                                          COMPROMISE
```

The attack chain proves that "low" findings can lead to critical outcomes.

### Attack Chain Template

```markdown
## Attack Chain: [Name of Attack Path]

### Overview
Brief description of what this attack chain demonstrates.

### Impact
What an attacker could achieve by following this path.

### Prerequisites
- What access/information the attacker starts with
- Tools required

### Attack Path

#### Step 1: [First Action]
**Objective:** What you're trying to accomplish

**Command/Action:**
```
[exact command or action taken]
```

**Result:**
[Screenshot or output]

**Explanation:**
Why this works and what it reveals.

---

#### Step 2: [Second Action]
[Continue pattern...]

---

### Chain Summary

| Step | Action | Result |
|------|--------|--------|
| 1 | [action] | [outcome] |
| 2 | [action] | [outcome] |
| 3 | [action] | [outcome] |

### Root Cause Analysis
The underlying issues that made this attack possible:
1. [Root cause 1]
2. [Root cause 2]

### Remediation
Fixing these items would break the attack chain:
1. [Fix 1] - Breaks chain at step X
2. [Fix 2] - Breaks chain at step Y
```

### Attack Chain Diagram Example

```
┌─────────────────────────────────────────────────────────────────┐
│           ATTACK CHAIN: INITIAL ACCESS TO DOMAIN ADMIN          │
└─────────────────────────────────────────────────────────────────┘

┌──────────────┐
│  INTERNET    │
└──────┬───────┘
       │
       ▼
┌──────────────┐    SQL Injection    ┌──────────────┐
│  Web App     │───────────────────▶│  Database    │
│  Port 443    │    CVE-2024-XXXX   │  Credentials │
└──────────────┘                     └──────┬───────┘
                                            │
                                     Password Reuse
                                            │
                                            ▼
┌──────────────┐    Pass-the-Hash    ┌──────────────┐
│   Domain     │◀───────────────────│ File Server  │
│  Controller  │    Admin creds     │  10.10.10.5  │
└──────┬───────┘    from LSASS      └──────────────┘
       │
       ▼
┌──────────────┐
│   DOMAIN     │
│   ADMIN      │
│   ACCESS     │
└──────────────┘

Time: Initial compromise to Domain Admin = 2 hours
```

---

## Step 3: Write PoC Scripts

Scripts allow clients to reproduce and verify your findings.

### Script Requirements

Good PoC scripts should be:

1. **Safe** - Won't cause damage when run
2. **Clear** - Well-commented and readable
3. **Minimal** - Only does what's needed to prove the point
4. **Portable** - Works without obscure dependencies

### Script Template

```python
#!/usr/bin/env python3
"""
Proof of Concept: [Vulnerability Name]
CVE: [CVE Number if applicable]
Target: [Application/System Name]

Description:
    [Brief description of what this script demonstrates]

Usage:
    python3 poc.py <target_ip> [options]

Example:
    python3 poc.py 192.168.1.100

Author: [Your Name]
Date: [Date]

DISCLAIMER: This script is for authorized security testing only.
            Unauthorized access to computer systems is illegal.
"""

import argparse
import sys

def check_vulnerability(target):
    """
    Check if the target is vulnerable.

    Returns:
        bool: True if vulnerable, False otherwise
    """
    print(f"[*] Checking {target} for vulnerability...")

    # Step 1: [Describe what this does]
    # [code]

    # Step 2: [Describe what this does]
    # [code]

    # Check result
    if vulnerable:
        print(f"[+] Target is VULNERABLE!")
        return True
    else:
        print(f"[-] Target is not vulnerable")
        return False

def demonstrate_impact(target):
    """
    Demonstrate the impact of the vulnerability.

    This function shows what an attacker could do,
    without causing actual damage.
    """
    print(f"[*] Demonstrating impact...")

    # Safe demonstration (e.g., read a specific file, show version)
    # [code]

    print(f"[+] Demonstration complete")
    print(f"[+] An attacker could: [describe impact]")

def main():
    parser = argparse.ArgumentParser(
        description='PoC for [Vulnerability Name]'
    )
    parser.add_argument('target', help='Target IP or hostname')
    parser.add_argument('-p', '--port', type=int, default=80,
                        help='Target port (default: 80)')
    parser.add_argument('--check-only', action='store_true',
                        help='Only check for vulnerability, no exploitation')

    args = parser.parse_args()

    print("[*] Starting PoC...")
    print(f"[*] Target: {args.target}:{args.port}")

    if check_vulnerability(args.target):
        if not args.check_only:
            demonstrate_impact(args.target)

    print("[*] PoC complete")

if __name__ == '__main__':
    main()
```

### Safe Demonstration Techniques

Instead of causing harm, prove impact safely:

| Vulnerability Type | Dangerous Demo | Safe Demo |
|-------------------|----------------|-----------|
| RCE | Install backdoor | Run `whoami`, `hostname`, `id` |
| File Read | Dump /etc/shadow | Read /etc/hostname or known safe file |
| SQL Injection | DROP TABLE | SELECT version(), database() |
| SSRF | Scan internal network | Request known internal hostname |
| File Upload | Upload webshell | Upload text file, prove execution |

### Common PoC Commands

```bash
# Prove code execution (safe)
whoami                    # Show current user
hostname                  # Show system name
id                        # Show user ID and groups
cat /etc/hostname         # Read safe system file
type C:\Windows\System32\drivers\etc\hosts  # Windows equivalent

# Prove file read
cat /etc/passwd           # World-readable file (safe)
type C:\Windows\win.ini   # Windows readable file (safe)

# Prove database access
SELECT version();         # Show DB version
SELECT current_user();    # Show DB user
SELECT database();        # Show current database

# Prove network access
ping -c 1 <your_ip>       # ICMP callback
curl http://<your_ip>     # HTTP callback
nslookup <your_domain>    # DNS callback
```

---

## Step 4: Create Video PoCs

Video PoCs are powerful for complex attacks and executive presentations.

### When to Use Video

- Attack chain has many steps
- Timing matters (race conditions)
- Visual walkthrough is clearer than text
- Executive briefing or presentation
- Training material

### Video Best Practices

1. **Plan your script** - Know exactly what you'll do before recording
2. **Clean your screen** - Close unnecessary windows, hide sensitive data
3. **Increase font size** - Terminal text should be readable at 720p
4. **Go slow** - Pause after important steps
5. **Add annotations** - Text overlays explaining what's happening
6. **Keep it short** - Under 5 minutes ideally, 10 max

### Recording Tools

| Tool | Platform | Notes |
|------|----------|-------|
| OBS Studio | All | Best free option, lots of features |
| asciinema | Linux/Mac | Terminal-only, text-based (can be replayed) |
| Kazam | Linux | Simple screen recorder |
| ShareX | Windows | Lightweight, good GIF support |

### Video Structure

```
0:00 - 0:15    Introduction
               - What you're demonstrating
               - Target system

0:15 - 0:45    Setup
               - Show starting point
               - Explain attacker perspective

0:45 - 3:00    Exploitation
               - Walk through each step
               - Pause and explain key moments

3:00 - 3:30    Impact
               - Show what access was achieved
               - Demonstrate potential damage

3:30 - 4:00    Summary
               - Recap the attack path
               - Note root causes
```

### Asciinema for Terminal PoCs

```bash
# Record terminal session
asciinema rec poc_demo.cast

# [Perform your PoC]

# Stop recording
exit

# Play back
asciinema play poc_demo.cast

# Upload (optional - creates shareable link)
asciinema upload poc_demo.cast

# Convert to GIF (requires agg)
agg poc_demo.cast poc_demo.gif
```

---

## Step 5: Integrate PoCs into Your Report

Your PoC must fit into the report structure.

### Finding Structure with PoC

```markdown
## Finding: [Vulnerability Title]

### Severity: [Critical/High/Medium/Low/Informational]

### CVSS Score: [X.X]

### Description
[What the vulnerability is in plain English]

### Affected Systems
- [IP/hostname]: [service/application]

### Proof of Concept

#### Prerequisites
- [What's needed to reproduce]

#### Steps to Reproduce

1. [First step]

   ```
   [command]
   ```

   [Screenshot: step1.png]

2. [Second step]

   ```
   [command]
   ```

   [Screenshot: step2.png]

3. [Continue...]

#### Result
[Screenshot showing successful exploitation]

[Explanation of what this proves]

### Impact
[Business impact if this vulnerability is exploited]

### Root Cause
[Why this vulnerability exists]

### Remediation
[How to fix this vulnerability]

### References
- [CVE link]
- [Vendor advisory]
- [Technical documentation]
```

### PoC Evidence Folder Structure

```
evidence/
├── findings/
│   ├── F01_sql_injection/
│   │   ├── screenshots/
│   │   │   ├── 01_initial_request.png
│   │   │   ├── 02_error_message.png
│   │   │   ├── 03_data_extracted.png
│   │   │   └── 04_impact.png
│   │   ├── poc_script.py
│   │   └── output.txt
│   ├── F02_weak_credentials/
│   │   ├── screenshots/
│   │   │   ├── 01_login_page.png
│   │   │   └── 02_admin_access.png
│   │   └── credentials_found.txt
│   └── F03_privilege_escalation/
│       ├── screenshots/
│       │   ├── 01_initial_access.png
│       │   ├── 02_privesc_vector.png
│       │   └── 03_root_access.png
│       └── poc_video.mp4
├── attack_chains/
│   ├── chain_01_external_to_domain_admin/
│   │   ├── chain_diagram.png
│   │   ├── walkthrough.md
│   │   └── full_demo.mp4
│   └── chain_02_data_exfiltration/
│       └── ...
└── scans/
    ├── nmap/
    ├── nessus/
    └── burp/
```

---

## Common Mistakes to Avoid

| Mistake | Problem | Solution |
|---------|---------|----------|
| No timestamps | Can't prove when testing occurred | Include timestamps in screenshots/logs |
| Screenshots too small | Evidence is unreadable | Capture at high resolution, crop thoughtfully |
| Missing commands | Can't reproduce the attack | Always show input AND output |
| Over-complicated scripts | Client can't understand or run them | Keep scripts simple and well-commented |
| Script-specific patches | Client patches script, not vulnerability | Emphasize root cause, not specific exploit |
| No context | "What system is this?" | Always show hostname/IP in evidence |
| Dangerous demos | Unnecessary destruction | Use safe demonstration techniques |
| Single path only | Client thinks one fix solves everything | Document alternative attack paths |
| No root cause | Fixing symptom, not disease | Always identify underlying issues |
| Missing impact | "So what?" | Always explain business impact |

---

## Root Cause vs. Specific Finding

This is critical: **Focus on root causes, not just symptoms.**

```
BAD PoC Conclusion:
"We compromised the server using admin:admin123"

GOOD PoC Conclusion:
"We compromised the server using default credentials.
The root causes are:
1. No password policy requiring complexity
2. No process to change default credentials after deployment
3. No monitoring for authentication failures

Even if 'admin123' is changed, the underlying issues remain.
Similar weaknesses likely exist elsewhere."
```

### Root Cause Analysis Questions

Ask yourself:
- Why did this vulnerability exist?
- What process failed to prevent it?
- Where else might similar issues exist?
- What systemic fix would prevent this class of vulnerability?

---

## Quick Reference: PoC Checklist

### Before Creating PoC

- [ ] Vulnerability is verified and reproducible
- [ ] You have all necessary screenshots/logs
- [ ] You understand the root cause
- [ ] You know the business impact

### Screenshot Checklist

- [ ] Command/action visible
- [ ] Output/result visible
- [ ] System context clear (hostname, IP)
- [ ] Readable resolution
- [ ] Sensitive data redacted if needed
- [ ] Annotations added where helpful

### Script Checklist

- [ ] Well-commented
- [ ] Safe to run (no destructive actions)
- [ ] Includes usage instructions
- [ ] Includes disclaimer
- [ ] Tested and working
- [ ] Minimal dependencies

### Attack Chain Checklist

- [ ] Clear starting point defined
- [ ] Each step documented with evidence
- [ ] Shows progression of access
- [ ] Identifies root causes
- [ ] Includes remediation for each link
- [ ] Diagram shows visual flow

### Report Integration Checklist

- [ ] Finding follows standard template
- [ ] Steps are numbered and clear
- [ ] Screenshots embedded properly
- [ ] Impact statement is business-focused
- [ ] Remediation is actionable
- [ ] References included

---

## Quick Reference: Evidence Commands

### Prove Code Execution

```bash
# Linux
whoami && hostname && id
cat /etc/hostname
uname -a

# Windows
whoami /all
hostname
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
```

### Prove File Access

```bash
# Linux - Safe files to read
cat /etc/passwd
cat /etc/hostname
cat /proc/version

# Windows - Safe files to read
type C:\Windows\System32\drivers\etc\hosts
type C:\Windows\win.ini
```

### Prove Database Access

```sql
-- MySQL/MariaDB
SELECT version();
SELECT user();
SELECT database();

-- PostgreSQL
SELECT version();
SELECT current_user;
SELECT current_database();

-- MSSQL
SELECT @@version;
SELECT SYSTEM_USER;
SELECT DB_NAME();
```

### Prove Network Access

```bash
# Callback to your server
curl http://YOUR_IP/poc
wget http://YOUR_IP/poc
ping -c 1 YOUR_IP
nslookup poc.YOUR_DOMAIN
```

---

## Summary

Proof of Concept is where you transform your testing activities into compelling evidence:

1. **Good PoCs get findings fixed** - Weak evidence leads to disputes
2. **Use the right format** - Documentation, scripts, or video depending on audience
3. **Screenshots tell a story** - Show command, output, and context
4. **Attack chains show real impact** - Individual vulnerabilities combine into major risks
5. **Scripts should be safe and simple** - Clients need to reproduce, not damage systems
6. **Focus on root causes** - Don't let clients patch the symptom while ignoring the disease
7. **Integrate into your report** - PoCs are part of your deliverable, not separate artifacts

Remember: You're not just proving a vulnerability exists—you're building an irrefutable case for why it must be fixed.

---

## Next Steps

With your Proof of Concepts documented, proceed to:

**[Phase 8: Post-Engagement](8_post_engagement.md)** - Deliver your report, conduct the client debrief, and properly close the engagement.
