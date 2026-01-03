# Blue-Team Detection & Response Playbook

## Threat Class: Windows Remote Management Protocol Abuse

---

## Executive Summary

Windows remote management protocols (RDP, WinRM, and WMI) provide **direct administrative control** of Windows systems. When exposed, misconfigured, or abused with stolen credentials, they enable **full system compromise, lateral movement, and persistence**, often with minimal malware and reduced EDR visibility.

---

## Threat Overview

### Protocols in Scope

| Protocol | Ports               | Risk Profile                                    |
| -------- | ------------------- | ----------------------------------------------- |
| RDP      | TCP/UDP 3389        | Critical (interactive access, credential abuse) |
| WinRM    | TCP 5985/5986       | High (remote command execution)                 |
| WMI      | TCP 135 + ephemeral | Critical (stealthy lateral movement)            |

---

## Phase 1 — Detection

### 1.1 RDP Detection & Monitoring

#### ☐ Monitor RDP Access

**Log Sources**

* Windows Security Event Log
* Event IDs:

  * **4624** – Successful logon (Logon Type 10)
  * **4625** – Failed logon
  * **4778 / 4779** – RDP session reconnect/disconnect
  * **1149** – RDP authentication success

**High-Risk Indicators**

* Repeated failed RDP logins
* RDP access from user workstations or non-admin subnets
* Logins outside business hours
* Use of local administrator accounts

---

### 1.2 RDP Configuration Weakness Detection

#### ☐ Detect Weak RDP Security

Indicators of risk:

* NLA disabled
* Non-TLS RDP security allowed
* Self-signed certificates (default behavior)

**Telemetry Sources**

* Group Policy audits
* Registry monitoring
* Vulnerability scanners

---

### 1.3 RDP Enumeration Activity

#### ☐ Detect RDP Fingerprinting

Attackers can enumerate:

* Hostname
* OS version
* Domain name
* NLA support

**Indicators**

* Nmap RDP scripts
* Abnormal connection handshakes
* Repeated short-lived TCP 3389 connections

---

## Phase 2 — WinRM Detection

### 2.1 WinRM Network Monitoring

#### ☐ Monitor WinRM Ports

* TCP **5985** (HTTP – high risk)
* TCP **5986** (HTTPS – preferred)

**High-Risk Indicators**

* WinRM exposed over HTTP
* WinRM accessible from non-admin networks
* WinRM connections without TLS

---

### 2.2 WinRM Authentication Monitoring

#### ☐ Log Sources

* Event ID **4624** (Logon Type 3)
* PowerShell logs:

  * **4104** – Script block execution
  * **4688** – Process creation

**Suspicious Patterns**

* Encoded PowerShell
* Remote command execution without interactive login
* Use of uncommon tooling (e.g., Evil-WinRM behavior)

---

## Phase 3 — WMI Detection

### 3.1 WMI Activity Monitoring

#### ☐ Monitor WMI Events

**Log Sources**

* Event ID **4688** (Process creation)
* Event ID **5861** (WMI event)
* Event ID **5857 / 5858 / 5859**

**High-Risk Indicators**

* WMI execution across hosts
* Lateral movement using valid credentials
* No interactive login associated with execution

---

### 3.2 Network Indicators

* TCP **135** followed by random high ports
* DCOM traffic between workstations and servers
* SMB + WMI execution pattern

---

## Phase 4 — Triage & Validation

### 4.1 Validate Scope of Exposure

#### ☐ Identify:

* Systems with RDP enabled
* WinRM listeners
* WMI remote access permissions

#### ☐ Confirm:

* Which accounts were used
* Whether access was interactive or non-interactive
* Credential reuse across systems

---

### 4.2 Impact Assessment

Assume **full system compromise** if:

* RDP access was successful
* WinRM commands executed
* WMI lateral movement observed

---

## Phase 5 — Containment

### 5.1 Immediate Network Controls

#### ☐ Restrict Access

* Limit RDP to jump hosts
* Block WinRM externally
* Restrict WMI to admin workstations only

---

### 5.2 Credential Actions

#### ☐ Rotate Credentials

* All affected user accounts
* Local administrator passwords
* Service accounts used for remote access

---

### 5.3 Session Termination

#### ☐ Kill Active Sessions

* Terminate RDP sessions
* Disable WinRM temporarily if abused
* Revoke Kerberos tickets (where applicable)

---

## Phase 6 — Eradication

### 6.1 RDP Hardening

#### ☐ Recommended Controls

* Enforce NLA
* Require TLS
* Disable RDP on systems that do not require it
* Replace self-signed certificates with trusted CA

---

### 6.2 WinRM Hardening

#### ☐ Best Practices

* Disable HTTP (5985)
* Enforce HTTPS (5986)
* Require Kerberos or certificate auth
* Restrict WinRM via GPO

---

### 6.3 WMI Hardening

#### ☐ Controls

* Restrict remote WMI permissions
* Monitor and alert on cross-host WMI usage
* Disable unnecessary DCOM exposure

---

## Phase 7 — Recovery

### 7.1 System Integrity Validation

#### ☐ Validate:

* No unauthorized local admin accounts
* No malicious services or scheduled tasks
* No startup persistence

---

### 7.2 Monitoring Enhancement

* Increase alerting sensitivity post-incident
* Monitor for credential reuse
* Watch for delayed lateral movement

---

## Phase 8 — Lessons Learned & Prevention

### 8.1 Architectural Controls

* Zero Trust for remote admin
* Dedicated admin workstations
* Just-In-Time (JIT) access

---

### 8.2 Governance

* RDP access approval workflows
* Mandatory MFA for RDP
* WinRM and WMI audits during system provisioning

---

## Severity Matrix

| Protocol | Severity |
| -------- | -------- |
| RDP      | Critical |
| WinRM    | High     |
| WMI      | Critical |

---

## Executive Risk Statement

> Abuse of Windows remote management protocols allows attackers to operate with legitimate administrative tooling, bypass traditional malware detection, and achieve full domain compromise through lateral movement and credential reuse.

---

## SOC Quick-Reference (TL;DR)

* RDP = interactive takeover
* WinRM = remote command execution
* WMI = stealth lateral movement
* Valid credentials ≠ benign activity
* Restrict, monitor, and log **everything**

---
