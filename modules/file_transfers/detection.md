# Detection of Malicious File Transfers

**Technical Report, Red Team Playbooks, and Blue Team Playbooks**

---

## Executive Summary

Detection of malicious file transfers is fundamentally a **behavioral problem**, not a signature problem. Simple approaches—such as command-line blacklisting—are trivial to bypass using case changes, argument rearrangement, or native tooling. This section emphasizes **robust detection strategies**, particularly:

* Command-line **whitelisting**
* Behavioral baselining
* **User-Agent analysis** in HTTP traffic
* Correlation of endpoint activity with network telemetry

The material highlights how file transfer tools—especially **Living off the Land binaries (LOLBins)**—leave detectable traces at the protocol and metadata level, even when payloads are encrypted.

---

## Command-Line Detection: Blacklisting vs Whitelisting

### Blacklisting (Weak Control)

**Characteristics**

* Matches known bad commands or substrings
* Easily bypassed via:

  * Case obfuscation
  * Alternate binaries
  * Argument reshuffling
  * Indirection (PowerShell, COM objects, scripts)

**Example Failure**

```text
certutil
CeRtUtIl
```

Both execute identically, one bypasses naïve detection.

Blacklisting is:

* Reactive
* Incomplete
* Fragile

Useful only as a **supplement**, never as a primary control.

---

### Whitelisting (Strong Control)

**Characteristics**

* Define what *normal* looks like
* Alert on deviations
* Requires upfront investment
* Scales extremely well once deployed

Whitelisting advantages:

* Immediate anomaly detection
* Detects new tools automatically
* Effective against LOTL techniques
* Resistant to obfuscation

This model aligns with:

* Zero Trust principles
* Mature SOC operations
* Threat hunting workflows

---

## HTTP/S Detection Fundamentals

### Client–Server Negotiation

Most client-server protocols—including HTTP—require negotiation before data exchange. This negotiation reveals metadata that defenders can leverage.

Key example:

* **User-Agent strings**

User-Agents exist to:

* Identify client capabilities
* Enable interoperability
* Customize server responses

Attackers cannot avoid this metadata—they can only **spoof it**.

---

## User-Agent Strings as a Detection Surface

### What Is a User-Agent?

A User-Agent identifies:

* Software type
* Version
* OS details
* Runtime environment

Examples:

* Browsers (Chrome, Firefox)
* OS services (Windows Update)
* Automation tools (PowerShell, curl)
* Security tools (Nmap, sqlmap)

Any HTTP client **must** declare a User-Agent.

---

## Enterprise User-Agent Baselines

Organizations can significantly improve detection by building:

* A whitelist of known browser UAs
* OS-native service UAs
* Update service UAs
* Antivirus update UAs

These baselines allow SIEM platforms to:

* Filter legitimate traffic
* Highlight anomalies
* Enable targeted threat hunting

Once baselined, **anything unusual becomes loud**.

---

## User-Agent Signatures of Common File Transfer Techniques

The provided examples demonstrate that **different LOTL file transfer methods produce distinct and highly recognizable User-Agents**.

### PowerShell Invoke-WebRequest / Invoke-RestMethod

**User-Agent Characteristics**

* Explicitly references `WindowsPowerShell`
* Includes OS version
* Rarely used for legitimate browsing

High-confidence indicator when seen downloading executables.

---

### WinHttpRequest COM Object

**User-Agent Characteristics**

* `WinHttp.WinHttpRequest`
* Legacy-style UA
* Rare in modern enterprise traffic

Common in malware and red-team tradecraft.

---

### MSXML2.XMLHTTP

**User-Agent Characteristics**

* Imitates Internet Explorer
* Includes Trident engine references
* Often misleadingly “browser-like”

This technique intentionally blends in—but still stands out in modern environments.

---

### Certutil

**User-Agent Characteristics**

* `Microsoft-CryptoAPI`
* No browser markers
* Strong indicator of LOTL abuse

Certutil downloading executables is almost always suspicious.

---

### BITS (Background Intelligent Transfer Service)

**User-Agent Characteristics**

* `Microsoft BITS/x.x`
* Uses `HEAD` requests before download
* Very distinctive traffic pattern

BITS traffic outside patch/update workflows is a **major red flag**.

---

## Detection Philosophy

The key takeaway:

> **Payload encryption does not hide behavior.**

Even when:

* HTTPS is used
* Files are encrypted
* Native tools are abused

Metadata remains visible:

* User-Agents
* HTTP verbs
* Timing
* File types
* Destination patterns

This is where mature defenders win.

---

# Red Team Playbooks

---

## Playbook 1: Evading Command-Line Detection

**Objective**
Avoid triggering naïve command-line rules.

**Techniques**

* Alternate binaries (LOLBins)
* COM objects instead of cmdlets
* Indirect execution (PowerShell reflection)
* Argument obfuscation

**Reality Check**
This works against immature detection only.

---

## Playbook 2: User-Agent Spoofing

**Objective**
Blend HTTP traffic into baseline noise.

**Techniques**

* Override User-Agent headers
* Mimic common browsers
* Match OS-appropriate versions

**Limitations**

* Still detectable via timing and behavior
* SOCs correlate beyond headers

Spoofing buys time—not invisibility.

---

## Playbook 3: Distributed Transfer Techniques

**Objective**
Avoid single-tool dependency.

**Execution**

* Rotate between PowerShell, BITS, Certutil
* Vary destination hosts
* Avoid repeated patterns

This increases defender workload and slows correlation.

---

# Blue Team Playbooks

---

## Detection Playbook 1: User-Agent Anomaly Hunting

**Indicators**

* PowerShell UAs downloading binaries
* Certutil UAs accessing HTTP endpoints
* BITS UAs outside patch cycles

**Data Sources**

* Proxy logs
* Web gateway logs
* IDS/IPS
* EDR network telemetry

---

## Detection Playbook 2: Command-Line Whitelisting

**Approach**

1. Baseline legitimate command lines
2. Alert on deviations
3. Tune false positives
4. Expand coverage gradually

This approach:

* Stops unknown tradecraft
* Survives obfuscation
* Enables fast triage

---

## Detection Playbook 3: Correlation Rules

**High-Confidence Signals**

* Encryption → HTTP transfer
* Script execution → file download
* Native tool → executable payload

Correlating weak signals creates strong detections.

---

## Prevention & Hardening

* Restrict LOLBins via AppLocker / WDAC
* Limit PowerShell language modes
* Monitor COM object abuse
* Enforce egress filtering
* Inspect HTTP metadata—not just payloads

---

## Incident Response Guidance

1. Identify transfer method
2. Inspect User-Agent and headers
3. Review originating process
4. Determine intent and scope
5. Contain and eradicate

---

## Final Notes

Attackers hide in **normal tools**.
Defenders win by knowing what *normal actually looks like*.

If your SOC ignores User-Agents, attackers will happily keep using PowerShell as a browser.

And yes—if your alert says *“PowerShell downloaded nc.exe”*, that’s not advanced analytics. That’s the system politely screaming for attention.
