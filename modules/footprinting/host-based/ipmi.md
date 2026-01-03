# IPMI / BMC Assessment Checklist

## 1. Service Identification & Footprinting

### ☐ Detect IPMI Presence

* Scan for **UDP port 623**

```bash
nmap -sU -p 623 <target>
```

### ☐ Identify IPMI Version

```bash
nmap -sU --script ipmi-version -p 623 <target>
```

**Confirm:**

* IPMI version (1.5 vs 2.0)
* Authentication capabilities
* Vendor MAC (HP, Dell, Supermicro, etc.)

### ☐ Identify BMC Vendor

Common targets:

* Dell iDRAC
* HP iLO
* Supermicro IPMI

Look for:

* Web console (HTTP/HTTPS)
* SSH or Telnet exposure
* Serial-over-LAN capability

---

## 2. Initial Access Testing (Quick Wins)

### ☐ Test Default Credentials

| Vendor     | Username      | Password                 |
| ---------- | ------------- | ------------------------ |
| Dell iDRAC | root          | calvin                   |
| HP iLO     | Administrator | factory-set (randomized) |
| Supermicro | ADMIN         | ADMIN                    |

Attempt:

* Web console login
* SSH / Telnet login

**Impact:**
Successful authentication ≈ **physical access equivalent**

---

## 3. Authentication Weakness Testing (IPMI 2.0)

### ☐ Test for RAKP Hash Exposure (IPMI 2.0)

If IPMI 2.0 is detected, attempt hash extraction.

#### Metasploit – Version Check

```text
auxiliary/scanner/ipmi/ipmi_version
```

#### Metasploit – Dump Hashes

```text
auxiliary/scanner/ipmi/ipmi_dumphashes
```

Expected result:

* Salted SHA1 / MD5 password hash returned **before authentication**
* Works for **any valid user account**

---

## 4. Offline Password Attacks

### ☐ Save Hashes for Cracking

* Hashcat format
* John format (optional)

### ☐ Crack Hashes

```bash
hashcat -m 7300 ipmi.txt wordlist.txt
```

#### HP iLO Mask Attack (Factory Defaults)

```bash
hashcat -m 7300 ipmi.txt -a 3 ?1?1?1?1?1?1?1?1 -1 ?d?u
```

**Note:**
HP default passwords = 8 characters, uppercase letters + digits.

---

## 5. Post-Exploitation Actions

### ☐ Access BMC Interfaces

* Web console
* SSH / Telnet
* Serial-over-LAN

### ☐ Demonstrate Impact

* Power cycle host
* Mount remote ISO
* Reinstall operating system
* Capture console output
* Modify BIOS / firmware settings

### ☐ Check Credential Re-use

* SSH into production systems
* Authenticate to management portals
* Test same credentials across environment

---

## 6. Reporting Severity Guidance

### ☐ Risk Rating

* **Critical** if:

  * Default credentials work
  * Hashes can be dumped
  * BMC reachable from user networks

### ☐ Business Impact Summary

* Remote system takeover
* Complete data loss potential
* Service disruption
* Persistence outside OS controls

---

# Defender / Blue-Team Hardening Checklist

## ☐ Network Controls

* Place BMCs on **dedicated management VLAN**
* Block UDP 623 from user networks
* Restrict access via firewall rules

## ☐ Authentication Hardening

* Enforce **long, complex passwords**
* Avoid password re-use across systems
* Disable unused BMC accounts

## ☐ Service Reduction

* Disable:

  * Telnet
  * Legacy cipher suites
  * Unused IPMI features

## ☐ Monitoring & Detection

* Monitor for:

  * UDP 623 scanning
  * Failed IPMI authentication attempts
  * Unexpected BMC reboots or power events

## ☐ Lifecycle Management

* Rotate credentials during:

  * Server provisioning
  * Decommissioning
  * Incident response

---

# Key Takeaway (Executive-Friendly)

> IPMI exposure provides attackers with **hardware-level control** that bypasses operating system security entirely. Any reachable BMC should be treated as **equivalent to physical access** and segmented accordingly.

---

# Red-Team Attack Playbook: IPMI / BMC Compromise

## Objective

Obtain **hardware-level control** of target systems by exploiting exposed IPMI / BMC interfaces. Successful exploitation yields capabilities equivalent to **physical access**, bypassing host OS security controls entirely.

---

## Phase 0 — Preconditions & Assumptions

* Internal network access or VPN foothold
* UDP traffic allowed to target segments
* No requirement for host OS credentials
* Target environment likely includes enterprise servers (HP, Dell, Supermicro)

---

## Phase 1 — Discovery & Enumeration

### 1.1 Identify IPMI Exposure

**Scan for IPMI UDP port**

```bash
nmap -sU -p 623 <target-range>
```

**Indicators of interest**

* Port 623/udp open
* Service: `asf-rmcp`

---

### 1.2 Fingerprint IPMI Version

```bash
nmap -sU --script ipmi-version -p 623 <target>
```

**Capture:**

* IPMI version (1.5 or 2.0)
* Authentication methods supported
* Vendor MAC (HP, Dell, Supermicro)

---

### 1.3 Vendor Identification

Common BMC platforms:

* HP iLO
* Dell iDRAC
* Supermicro IPMI

**Actionable Outcome:**
Determine default credentials and exploit path.

---

## Phase 2 — Initial Access (Credential Attacks)

### 2.1 Test Default Credentials

| Vendor     | Username      | Password        |
| ---------- | ------------- | --------------- |
| Dell iDRAC | root          | calvin          |
| HP iLO     | Administrator | factory default |
| Supermicro | ADMIN         | ADMIN           |

**Targets**

* Web management interface
* SSH or Telnet access

**Success Condition**

* Authenticated BMC access → immediate critical finding

---

## Phase 3 — IPMI 2.0 Authentication Exploitation (RAKP)

### 3.1 Confirm IPMI 2.0

```text
auxiliary/scanner/ipmi/ipmi_version
```

**Required Condition**

* IPMI 2.0 with RAKP enabled

---

### 3.2 Dump Password Hashes

```text
auxiliary/scanner/ipmi/ipmi_dumphashes
```

**Outcome**

* Salted SHA1 / MD5 password hashes retrieved
* Works for **any valid BMC user**
* No authentication required

---

## Phase 4 — Offline Password Cracking

### 4.1 Prepare Hashes

* Export hashes in Hashcat format (mode 7300)

### 4.2 Crack Hashes

```bash
hashcat -m 7300 ipmi.txt wordlist.txt
```

#### HP iLO Default Mask Attack

```bash
hashcat -m 7300 ipmi.txt -a 3 ?1?1?1?1?1?1?1?1 -1 ?d?u
```

**Expected Success Rate**

* Extremely high against defaults or weak passwords

---

## Phase 5 — Post-Exploitation (Impact Demonstration)

### 5.1 Authenticate to BMC

* Web console
* SSH / Telnet
* Serial-over-LAN

---

### 5.2 Demonstrate Hardware Control

**High-impact actions**

* Power off / reboot host
* Mount remote ISO
* Reinstall OS
* Modify BIOS / firmware
* Capture console output
* Bypass disk encryption pre-boot

**Note:**
These actions are **OS-agnostic** and survive reimaging.

---

### 5.3 Credential Re-Use Attacks

If passwords are cracked:

* Attempt SSH access to production servers
* Attempt authentication to monitoring platforms
* Attempt reuse on other BMCs

---

## Phase 6 — Lateral Movement & Persistence

### 6.1 Lateral Opportunities

* Same credentials reused across:

  * Other BMCs
  * Root accounts
  * Admin portals

### 6.2 Persistence Techniques

* Create additional BMC users
* Modify BMC network configuration
* Implant malicious boot media

---

## Phase 7 — Cleanup (If Required)

* Remove test accounts
* Restore original power state
* Unmount ISO images
* Document all changes made

---

## Detection Avoidance Notes (Red-Team)

* IPMI traffic often unmonitored
* UDP 623 rarely logged
* Hash retrieval appears as legitimate auth traffic
* BMC activity often invisible to EDR/XDR

---

## Reporting Guidance

### Severity

**Critical**

### Risk Justification

* Hardware-level compromise
* Full system takeover
* OS security bypass
* Persistent access outside host controls

### Executive Impact Statement

> Compromise of IPMI grants attackers the same control as physical access to servers, enabling total system takeover, data loss, and service disruption without interacting with the operating system.

---

## Operator Summary (TL;DR)

1. Find UDP 623
2. Fingerprint IPMI 2.0
3. Dump hashes
4. Crack offline
5. Own the box — permanently

---

# Blue-Team Detection & Response Playbook

## Threat: IPMI / BMC Abuse

---

## Executive Summary

IPMI exploitation enables **hardware-level compromise** that bypasses operating system controls, endpoint detection, and disk encryption. Any confirmed IPMI abuse should be treated as **equivalent to physical access** to the affected system.

---

## Threat Overview

### Attack Characteristics

* Protocol: IPMI (UDP 623)
* Target: Baseboard Management Controllers (BMCs)
* Access Level: Out-of-band, OS-independent
* Persistence: Survives OS reinstallation

### Common Platforms

* HP iLO
* Dell iDRAC
* Supermicro IPMI

---

## Phase 1 — Detection

### 1.1 Network-Based Indicators

#### ☐ Monitor for IPMI Traffic

* UDP port **623**
* Unusual internal scanning behavior
* IPMI traffic originating from user VLANs

**Telemetry Sources**

* Firewall logs
* NetFlow
* IDS/IPS
* NDR platforms

**High-Risk Indicators**

* Broad UDP 623 scanning
* IPMI traffic outside management networks
* Repeated authentication attempts

---

### 1.2 Authentication Indicators

#### ☐ Detect RAKP Abuse Patterns

* IPMI authentication attempts without follow-on login
* Multiple username probes
* Short-lived IPMI sessions

**Note:**
Hash dumping via RAKP appears as **legitimate authentication traffic**.

---

### 1.3 BMC Event Log Monitoring

#### ☐ Review BMC Logs For:

* Failed authentication attempts
* Unexpected user enumeration
* Power state changes
* Console access events
* Firmware configuration changes

**Important:**
Many organizations do **not forward BMC logs** to SIEM by default.

---

## Phase 2 — Triage & Validation

### 2.1 Confirm Exposure

#### ☐ Identify Affected Hosts

* Enumerate systems with BMCs
* Identify reachable BMC IPs
* Validate network segmentation

#### ☐ Validate Access Scope

* Determine if default credentials were used
* Identify if hashes were dumped
* Check if cracked credentials exist elsewhere

---

### 2.2 Impact Assessment

#### ☐ Determine If Attacker Could:

* Reboot or power off systems
* Mount remote media
* Access console output
* Modify BIOS/firmware

**Assume compromise if exposure confirmed.**

---

## Phase 3 — Containment

### 3.1 Immediate Network Controls

#### ☐ Block IPMI Traffic

* Block UDP 623 at network boundaries
* Restrict access to dedicated management VLAN
* Enforce jump-host-only access

---

### 3.2 Credential Containment

#### ☐ Rotate All BMC Credentials

* All affected systems
* All accounts (including disabled ones)
* Avoid password reuse across systems

**Do not reuse cracked credentials anywhere.**

---

### 3.3 Account Control

#### ☐ Audit BMC User Accounts

* Remove unauthorized accounts
* Disable unused accounts
* Enforce least privilege

---

## Phase 4 — Eradication

### 4.1 BMC Hardening

#### ☐ Disable Unnecessary Services

* Telnet
* Legacy cipher suites
* Unused IPMI features

#### ☐ Enforce Strong Authentication

* Long, complex passwords
* Vendor-supported MFA (if available)
* Lockout policies

---

### 4.2 Firmware Integrity

#### ☐ Verify Firmware State

* Validate BMC firmware version
* Reflash firmware if integrity is uncertain
* Validate BIOS configuration

**Treat firmware compromise as a rebuild event.**

---

## Phase 5 — Recovery

### 5.1 System Validation

#### ☐ Validate Host Integrity

* OS reinstall if needed
* Validate boot configuration
* Verify disk encryption state

---

### 5.2 Restore Services

* Controlled power-up
* Monitor console access
* Confirm no unexpected reboots

---

## Phase 6 — Lessons Learned & Prevention

### 6.1 Architectural Controls

#### ☐ Network Segmentation

* Isolate BMCs on management-only networks
* No direct user or server access

#### ☐ Zero Trust Principles

* Explicit allow rules
* No implicit trust for management interfaces

---

### 6.2 Monitoring Improvements

#### ☐ Logging Enhancements

* Forward BMC logs to SIEM
* Alert on:

  * Authentication failures
  * Power events
  * Console access

---

### 6.3 Governance & Policy

#### ☐ Policy Updates

* Mandatory BMC password rotation
* Credential uniqueness enforcement
* Decommissioning checklist includes BMC reset

---

## Severity & Risk Rating

| Category      | Rating                   |
| ------------- | ------------------------ |
| Impact        | Critical                 |
| Likelihood    | High (internal networks) |
| Detectability | Low                      |
| Persistence   | High                     |

---

## Executive Risk Statement

> Exposure of IPMI interfaces enables attackers to bypass all host-based security controls, achieve persistent access, and disrupt operations at will. IPMI compromise should be treated with the same urgency as physical server compromise.

---

## SOC Analyst Quick Reference (TL;DR)

* UDP 623 traffic = suspicious
* IPMI logs ≠ OS logs
* Hash dumping looks legitimate
* If exposed, **assume full compromise**
* Containment requires **network + credential action**
