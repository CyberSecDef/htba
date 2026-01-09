# File Transfers

**Technical Report, Red Team Playbooks, and Blue Team Playbooks**

---

## 1. Technical Report: File Transfers in Adversarial and Defensive Contexts

---

## 1.1 Why File Transfers Matter in Security Assessments

File transfer capability is a **foundational requirement** in both offensive and defensive security operations. During penetration tests, red team engagements, and incident response activities, practitioners frequently need to:

* Introduce tools to a target system
* Exfiltrate data for analysis
* Move payloads between compromised hosts
* Transfer scripts, binaries, or configuration files

The inability to transfer files often **halts progress**, even after initial compromise has been achieved. As a result, understanding multiple transfer mechanisms—and their operational constraints—is critical.

---

## 1.2 Scenario Overview: Practical Constraints in Real Environments

The provided scenario illustrates a **realistic and layered defense environment**:

* Initial access achieved via **unrestricted file upload** on an IIS web server
* Web shell used to obtain **reverse shell access**
* PowerShell execution blocked via **Application Control Policy**
* Web-based downloads blocked by **content filtering**
* FTP blocked via **egress firewall rules**
* SMB (TCP 445) allowed outbound

Despite strong controls, the environment still allowed file transfer through a **less-monitored protocol**, enabling privilege escalation using a locally transferred binary.

This scenario demonstrates a key principle:

> **File transfer success is not about tools—it is about understanding host controls and network behavior.**

---

## 1.3 Host-Based Controls Affecting File Transfers

### Application Control & Whitelisting

Controls such as:

* AppLocker
* Windows Defender Application Control (WDAC)
* SELinux / AppArmor (Linux)

May block:

* PowerShell scripts (`.ps1`)
* Unsigned binaries
* Known offensive tooling

Attackers must pivot to:

* Allowed binaries
* Built-in OS utilities
* Signed or renamed executables

---

### Endpoint Protection (AV / EDR)

Modern EDR solutions may:

* Block known file transfer utilities
* Flag unusual network behavior
* Quarantine binaries post-transfer

This often forces attackers to:

* Use **living-off-the-land binaries (LOLBins)**
* Transfer custom-compiled or obfuscated payloads
* Choose protocols that blend into normal traffic

---

## 1.4 Network-Based Controls Affecting File Transfers

### Firewalls

Firewalls commonly restrict:

* Outbound traffic
* Non-standard ports
* Legacy protocols (FTP, Telnet)

In the scenario:

* FTP (TCP 21) was blocked
* HTTP/S access was content-filtered
* SMB (TCP 445) remained open

---

### IDS / IPS

Intrusion Detection and Prevention Systems may:

* Alert on file transfers
* Block protocol misuse
* Detect anomalous traffic patterns

As a result, **protocol selection matters** as much as the transfer tool itself.

---

## 1.5 File Transfer Methods: Core Concepts

File transfer mechanisms can be broadly categorized as:

* **Application-layer transfers**

  * HTTP/HTTPS
  * FTP
  * SMB
* **OS-native utilities**

  * Certutil
  * PowerShell
  * SCP / SFTP
* **Adversary-hosted services**

  * Temporary SMB shares
  * Custom servers
* **Protocol abuse**

  * Using allowed protocols for unintended purposes

No single method works universally; success depends on **environmental constraints**.

---

## 1.6 Key Takeaways from the Scenario

* Initial compromise does not guarantee operational freedom
* Strong controls force attackers into **creative pivots**
* Egress filtering is often incomplete or inconsistent
* SMB remains a common blind spot
* Understanding multiple transfer techniques is mandatory

---

## 1.7 Training and Skill Development

The module emphasizes **hands-on experimentation** using both Windows and Linux targets. This is critical because:

* Different OSes expose different transfer primitives
* Network behavior varies across environments
* Minor configuration changes drastically alter outcomes

Practitioners should:

* Practice each technique repeatedly
* Note failure modes
* Document which controls break which methods

---

## 1.8 Operational Takeaways

* File transfer is not a single technique—it is a strategy
* Host and network controls must be evaluated together
* Offensive success relies on adaptability
* Defensive success relies on visibility and consistency

---

# 2. Red Team Playbooks (Offensive File Transfer)

---

## Red Team Playbook 1: File Transfer Decision Tree

**Objective:**
Transfer required tooling despite host and network restrictions.

**Workflow:**

1. Enumerate allowed binaries and protocols
2. Identify blocked mechanisms (PowerShell, HTTP, FTP)
3. Test outbound connectivity by port
4. Pivot to allowed protocols (e.g., SMB)
5. Transfer minimal, purpose-built binaries

**Key Insight:**
Always test *what works*, not what should work.

---

## Red Team Playbook 2: Living-Off-the-Land Transfers

**Objective:**
Avoid detection by using native OS capabilities.

**Examples:**

* Certutil
* Built-in FTP client
* SMB copy commands
* WebDAV (if enabled)

**Why it Works:**
Native tools blend into legitimate administrative activity.

---

## Red Team Playbook 3: Protocol Pivoting

**Objective:**
Bypass egress filtering.

**Techniques:**

* Enumerate outbound firewall rules implicitly
* Host attacker-controlled services on allowed ports
* Abuse trusted protocols (SMB, HTTPS)

**Lesson:**
Egress filtering is often policy-based, not behavior-based.

---

## Red Team Playbook 4: Transfer for Privilege Escalation

**Objective:**
Move binaries necessary for local escalation.

**Example:**

* Identify `SeImpersonatePrivilege`
* Transfer PrintSpoofer or equivalent
* Escalate to SYSTEM or Administrator

File transfer is often the **bridge between access and control**.

---

# 3. Blue Team Playbooks (Defensive & Detection)

---

## Blue Team Playbook 1: Egress Control Hardening

**Objective:**
Prevent unauthorized outbound transfers.

**Controls:**

* Enforce strict outbound allowlists
* Block SMB outbound where not required
* Monitor uncommon outbound connections

---

## Blue Team Playbook 2: Host-Based Transfer Monitoring

**Objective:**
Detect suspicious file movement.

**Indicators:**

* Use of LOLBins for downloads
* File creation in web directories
* Executable writes by IIS or service accounts

File transfer is often the **earliest indicator of post-exploitation**.

---

## Blue Team Playbook 3: Application Control Validation

**Objective:**
Ensure controls actually stop real attackers.

**Actions:**

* Test PowerShell restrictions
* Validate WDAC/AppLocker rules
* Review allowed binaries for abuse potential

Controls that “look good” on paper often fail in practice.

---

## Blue Team Playbook 4: SMB Abuse Detection

**Objective:**
Close common blind spots.

**Indicators:**

* Outbound SMB connections from servers
* Unexpected file copies to `C:\Windows\Temp`
* SMB traffic to non-domain systems

Outbound SMB is frequently unnecessary—and dangerous.

---

## Summary

* File transfer capability is essential post-compromise
* Real environments block *expected* methods
* Attackers succeed by adapting to controls
* Defenders must monitor both host and network behavior
* SMB, LOLBins, and egress gaps are recurring themes
* Mastery comes from practicing multiple techniques
