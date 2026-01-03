# Blue-Team Detection & Response Playbook

## Threat Class: Linux Remote Management Protocol Abuse

---

## Executive Summary

Linux remote management services (SSH, Rsync, and legacy R-services) are **high-value attack surfaces** due to their ubiquity, privileged access, and frequent misconfiguration. Abuse often results in **direct shell access, credential harvesting, lateral movement, and data exfiltration**.

---

## Threat Overview

### Primary Protocols in Scope

| Protocol   | Default Port | Risk Profile                                |
| ---------- | ------------ | ------------------------------------------- |
| SSH        | TCP 22       | High (brute-force, weak auth, config abuse) |
| Rsync      | TCP 873      | Medium–High (unauthenticated data exposure) |
| R-services | TCP 512–514  | Critical (trust-based auth, plaintext)      |

---

## Phase 1 — Detection

### 1.1 SSH Detection & Monitoring

#### ☐ Monitor Authentication Events

**Log Sources**

* `/var/log/auth.log`
* `/var/log/secure`
* SIEM SSH parsers

**High-Risk Indicators**

* Repeated failed logins
* Authentication method switching (publickey → password)
* Login attempts to root or service accounts
* Logins outside normal time windows

---

### 1.2 SSH Configuration Drift Detection

#### ☐ Detect Dangerous SSH Settings

Monitor changes to:

* `PasswordAuthentication yes`
* `PermitRootLogin yes`
* `Protocol 1`
* `X11Forwarding yes`
* `AllowTcpForwarding yes`

**Recommended**

* File Integrity Monitoring (FIM) on:

  * `/etc/ssh/sshd_config`
  * `/etc/ssh/sshd_config.d/*`

---

### 1.3 SSH Banner & Version Exposure

#### ☐ Detect Version Leakage

* Banner reveals OpenSSH version
* Enables CVE targeting and downgrade attacks

**Telemetry**

* NDR / Zeek
* SSH handshake metadata

---

### 1.4 Rsync Detection

#### ☐ Monitor TCP 873

**Indicators**

* Rsync traffic from unexpected hosts
* Directory listing activity
* Anonymous share enumeration

**High-Risk Pattern**

* `rsync://` access without authentication

---

### 1.5 R-Services Detection (Critical)

#### ☐ Detect Legacy Protocols

Monitor:

* TCP 512 (rexec)
* TCP 513 (rlogin)
* TCP 514 (rsh)

**Any detection = Incident**

These services:

* Transmit credentials in plaintext
* Trust hostnames/IPs
* Bypass authentication via `.rhosts` and `hosts.equiv`

---

## Phase 2 — Triage & Validation

### 2.1 Service Exposure Validation

#### ☐ Identify Active Services

```bash
ss -tulpen
```

Confirm:

* Which services are listening
* On which interfaces
* From which networks

---

### 2.2 Credential Exposure Assessment

#### ☐ Determine If:

* Password authentication is enabled
* Root login is allowed
* SSH keys are improperly stored
* Rsync shares expose sensitive data
* `.rhosts` or `/etc/hosts.equiv` exist

---

## Phase 3 — Containment

### 3.1 Network Controls

#### ☐ Restrict Access

* SSH only from management networks
* Block Rsync and R-services externally
* Enforce jump-host architecture

---

### 3.2 Account Controls

#### ☐ Credential Actions

* Rotate affected credentials
* Disable password authentication where possible
* Enforce SSH key-only access
* Remove unused accounts

---

### 3.3 Service Shutdown (If Required)

#### ☐ Disable Legacy Services

```bash
systemctl disable rsh rlogin rexec
```

R-services should **never** be running in modern environments.

---

## Phase 4 — Eradication

### 4.1 SSH Hardening

#### ☐ Recommended Baseline

```text
PasswordAuthentication no
PermitRootLogin no
Protocol 2
X11Forwarding no
AllowTcpForwarding no
MaxAuthTries 3
LoginGraceTime 30
```

---

### 4.2 Rsync Hardening

#### ☐ Controls

* Disable anonymous modules
* Require authentication
* Restrict module paths
* Audit permissions on shared directories

---

### 4.3 Trusted File Cleanup (R-Services)

#### ☐ Remove Trust Files

* `/etc/hosts.equiv`
* `~/.rhosts`

Any `+ +` entry = immediate compromise risk.

---

## Phase 5 — Recovery

### 5.1 System Validation

#### ☐ Validate:

* No unauthorized SSH keys present
* No persistence mechanisms added
* No cron jobs or backdoors created

---

### 5.2 Restore Normal Operations

* Restart hardened services
* Monitor login activity closely
* Confirm expected access paths only

---

## Phase 6 — Lessons Learned & Prevention

### 6.1 Architectural Controls

#### ☐ Enforce Zero Trust

* No implicit trust between hosts
* No password-based remote admin
* No legacy protocols

---

### 6.2 Monitoring Enhancements

#### ☐ SIEM Alerts

* SSH brute-force thresholds
* Root login attempts
* Rsync enumeration
* Any R-services traffic

---

### 6.3 Governance

#### ☐ Policy Requirements

* SSH key management standards
* Credential rotation schedules
* Mandatory removal of legacy services
* Remote access audits during system provisioning

---

## Severity Matrix

| Protocol            | Severity |
| ------------------- | -------- |
| SSH (misconfigured) | High     |
| Rsync (open share)  | High     |
| R-services          | Critical |

---

## Executive Risk Statement

> Misconfigured Linux remote management services allow attackers to gain interactive access, exfiltrate sensitive data, and move laterally across the network with minimal detection. Legacy protocols and weak SSH configurations represent unacceptable enterprise risk.

---

## SOC Quick-Reference (TL;DR)

* SSH brute force ≠ noise, it’s recon
* Password auth = risk
* Rsync ≠ backup tool when open
* R-services = emergency
* Trust files = free shells
