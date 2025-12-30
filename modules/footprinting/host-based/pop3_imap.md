# Penetration Testing Report

## IMAP and POP3 Services – Enumeration, Misconfiguration Risks, and Exploitation

---

## 1. Executive Overview

This document focuses on **email retrieval protocols—IMAP and POP3—from a penetration tester’s perspective**. It covers protocol behavior, authentication mechanisms, common server configurations, enumeration techniques, dangerous misconfigurations, and hands-on interaction using common offensive tools.

From an attacker’s standpoint, mail servers are **high-value targets** due to the sensitive nature of stored communications, credential reuse risks, password reset workflows, and potential internal intelligence gathering.

---

## 2. Protocol Fundamentals

### 2.1 Internet Message Access Protocol (IMAP)

IMAP is a **client-server, text-based protocol** designed for **online mailbox management**. Unlike POP3, IMAP treats the mailbox as a **server-resident data store**, allowing:

* Persistent storage of emails on the server
* Folder hierarchies and custom mailboxes
* Multi-client synchronization
* Simultaneous access by multiple users
* Server-side searching and message state tracking (read, unread, deleted)

IMAP effectively behaves like a **networked filesystem for email**, making it more complex—and more interesting—from an attack perspective.

**Key operational traits:**

* Requires an active connection for management
* Supports offline caching with later synchronization
* Emails remain server-side until explicitly deleted

---

### 2.2 Post Office Protocol v3 (POP3)

POP3 is significantly simpler and more limited. It supports only:

* Listing messages
* Retrieving messages
* Deleting messages

POP3 does **not** natively support folder structures, multi-mailbox access, or rich synchronization. Messages are typically downloaded and removed from the server, reducing long-term exposure—but also reducing administrative oversight.

From a penetration testing angle, POP3’s simplicity often means **fewer features, but also fewer guardrails**.

---

## 3. Transport, Authentication, and Encryption

### 3.1 Default Ports

| Protocol | Plaintext | Encrypted (SSL/TLS) |
| -------- | --------- | ------------------- |
| POP3     | 110       | 995                 |
| IMAP     | 143       | 993                 |

* Ports **110 and 143** transmit credentials and data in **cleartext** unless STARTTLS is enforced.
* Ports **993 and 995** provide implicit TLS encryption.

Failure to enforce encryption is a **critical security weakness**, especially on internal networks.

---

### 3.2 Authentication Workflow

For IMAP:

1. Client connects to server
2. Server presents banner and capabilities
3. Client authenticates using username/password (or SASL)
4. Only after authentication can mailboxes be accessed

IMAP supports **pipelining**, meaning multiple commands can be sent without waiting for responses—useful for performance, but also for **brute-force optimization** if not rate-limited.

---

## 4. Core Command Sets

### 4.1 IMAP Command Capabilities

IMAP provides extensive mailbox manipulation functionality:

| Command           | Purpose                  |
| ----------------- | ------------------------ |
| LOGIN             | Authenticate user        |
| LIST              | Enumerate mailboxes      |
| CREATE / DELETE   | Manage folders           |
| RENAME            | Rename mailboxes         |
| SELECT / UNSELECT | Access mailbox contents  |
| FETCH             | Retrieve message data    |
| CLOSE             | Expunge deleted messages |
| LOGOUT            | Terminate session        |

**Pentesting relevance:**

* `LIST` and `LSUB` can leak mailbox structure
* `FETCH` enables full message extraction post-authentication
* Folder names often reveal business processes (“HR”, “Finance”, “Legal”)

---

### 4.2 POP3 Command Capabilities

POP3 commands are minimal:

| Command     | Purpose             |
| ----------- | ------------------- |
| USER / PASS | Authentication      |
| STAT / LIST | Message enumeration |
| RETR        | Message retrieval   |
| DELE        | Message deletion    |
| CAPA        | Server capabilities |
| QUIT        | Session termination |

The `CAPA` command is particularly useful for **fingerprinting server features and authentication methods**.

---

## 5. Default Configuration and Testing Environment

The document recommends deploying **Dovecot IMAP/POP3** locally for experimentation. This is operationally sound advice:

* Enables controlled testing of authentication behavior
* Allows safe experimentation with misconfigurations
* Helps understand server-side logging and protocol flows

Understanding server configuration is critical to recognizing **what attackers exploit versus what defenders misconfigure**.

---

## 6. Dangerous Configuration Settings

Misconfigured authentication logging presents severe risk. The following settings are explicitly dangerous:

| Setting                 | Risk                                   |
| ----------------------- | -------------------------------------- |
| auth_debug              | Logs detailed authentication internals |
| auth_debug_passwords    | Logs plaintext passwords               |
| auth_verbose            | Logs failed auth attempts              |
| auth_verbose_passwords  | Logs passwords (possibly truncated)    |
| auth_anonymous_username | Enables anonymous access               |

**Impact:**

* Credential exposure via log files
* Lateral movement via harvested credentials
* Anonymous mailbox access in worst-case scenarios

These misconfigurations effectively **turn the mail server into a credential collection system—for the attacker**.

---

## 7. Service Footprinting and Enumeration

### 7.1 Nmap Service Discovery

Using Nmap with service detection and default scripts allows:

* Protocol identification
* Software/version discovery
* Capability enumeration
* TLS certificate inspection

The example scan reveals:

* Dovecot IMAP/POP3 services
* TLS-enabled endpoints
* Certificate metadata including organization, CN, and location

**Certificate analysis alone can reveal:**

* Internal hostnames
* Organizational structure
* Email address formats
* Geographic data

This is valuable for **phishing, OSINT correlation, and internal mapping**.

---

## 8. Authenticated Interaction Techniques

### 8.1 cURL for IMAP

cURL can directly interact with IMAPS endpoints:

* Lists mailboxes
* Displays server banners
* Reveals TLS parameters
* Confirms credential validity

Verbose mode exposes:

* TLS version and cipher suite
* Certificate chain details
* Authentication methods
* Server software banners

This is an efficient way to **validate credentials without a mail client**.

---

### 8.2 OpenSSL and ncat

Using `openssl s_client` enables:

* Manual protocol interaction
* TLS handshake inspection
* Certificate validation analysis
* Banner grabbing post-encryption

This technique is especially useful when:

* STARTTLS behavior must be validated
* Certificates are self-signed
* Legacy TLS configurations are suspected

---

## 9. Post-Authentication Impact

Once valid credentials are obtained:

* Full read access to inbox and folders
* Access to sent mail (often overlooked)
* Ability to send emails as the user (SMTP coupling)
* Potential password reset interception
* Internal reconnaissance via email content

In the provided scenario, credential reuse (`robin:robin`) demonstrates a **classic real-world failure mode**: weak password hygiene leading directly to mailbox compromise.

---

## 10. Attacker Takeaways

From a red-team perspective:

* Mail servers are intelligence goldmines
* TLS does not equal security if auth is weak
* Logs can be more dangerous than traffic
* Capability banners matter
* Credential reuse remains devastatingly common

From a methodology standpoint:

* Enumerate first
* Inspect certificates
* Identify auth methods
* Validate encryption enforcement
* Test credentials cautiously but thoroughly

---

## 11. Defender Implications (Contextual)

While not the primary focus, the material implicitly highlights defensive failures:

* Lack of TLS enforcement
* Excessive logging verbosity
* Poor password policies
* Self-signed certificates in production
* Insufficient monitoring of mail access

---

## 12. Conclusion

This document provides a **complete, realistic view of IMAP and POP3 from an offensive security lens**. It emphasizes that mail services are not just infrastructure—they are **repositories of trust, identity, and institutional memory**. Poor configuration turns them into low-effort, high-impact compromise vectors.

Proper understanding of protocol mechanics, combined with disciplined enumeration, enables attackers to extract maximum value with minimal noise—exactly why mail servers deserve careful attention during penetration tests.

---

Below is a **professional red-team playbook for mail server compromise**, written to be **engagement-ready**, exam-aligned, and usable as a **repeatable operational checklist**. It assumes legal authorization and an internal or external penetration test context.

---

# Red Team Playbook

## Mail Server Compromise (IMAP / POP3 / SMTP)

---

## 1. Objectives

Primary red-team objectives when targeting mail infrastructure:

* Obtain **valid mailbox access**
* Extract **sensitive communications**
* Identify **credential reuse**
* Abuse **email trust relationships**
* Enable **lateral movement**, **privilege escalation**, or **social engineering**
* Maintain **low-noise persistence**

Mail servers are force multipliers. One compromised inbox can unlock entire environments.

---

## 2. Target Identification & Scoping

### 2.1 Identify Mail Infrastructure

* External MX records
* Internal mail hosts (Exchange, Dovecot, Postfix, Sendmail)
* Cloud vs on-prem (O365, Google Workspace vs self-hosted)

### 2.2 Common Services in Scope

* IMAP / IMAPS (143 / 993)
* POP3 / POP3S (110 / 995)
* SMTP / Submission (25 / 587 / 465)
* Webmail (OWA, Roundcube, RainLoop)

---

## 3. Phase 1 – Reconnaissance & Enumeration

### 3.1 Port & Service Discovery

**Goal:** Identify mail services, versions, and encryption posture.

Actions:

* Scan known mail ports
* Identify plaintext vs TLS-enforced services
* Extract banners and certificates

Key findings to document:

* Software (Dovecot, Exchange, Courier)
* Version numbers
* STARTTLS support
* Weak or self-signed certificates
* Authentication mechanisms (PLAIN, LOGIN, NTLM, OAuth)

---

### 3.2 Certificate & Metadata Analysis

**Goal:** Extract organizational intelligence.

From TLS certificates:

* Internal hostnames
* Organizational units
* Email address formats
* Geographic data
* Validity anomalies (excessive lifetimes)

Operational value:

* Username format prediction
* Phishing pretexting
* Internal domain discovery

---

### 3.3 Capability Enumeration

**Goal:** Understand what the server allows.

Enumerate:

* IMAP CAPABILITY output
* POP3 CAPA response
* AUTH mechanisms
* IDLE / PIPELINING support

Red-team relevance:

* Pipelining = faster brute forcing
* AUTH=PLAIN over TLS = password reuse exposure
* Anonymous or legacy auth = immediate escalation path

---

## 4. Phase 2 – Credential Acquisition

### 4.1 OSINT & Username Harvesting

Sources:

* Email headers
* Public documents
* LinkedIn
* Git repos
* Company website
* Certificate SAN fields

Expected outcomes:

* Valid usernames
* Department naming conventions
* Role-based accounts

---

### 4.2 Password Attacks

#### 4.2.1 Password Spraying

**Preferred over brute force**

Techniques:

* Seasonal passwords
* Company name variations
* Username-as-password
* Known breaches

Rules:

* Low frequency
* Spread across accounts
* Observe lockout thresholds

---

#### 4.2.2 Credential Reuse Testing

Test credentials obtained from:

* VPN
* SMB
* Web apps
* SMTP auth
* Prior breaches

Mail servers are **highly susceptible** to reuse.

---

### 4.3 Misconfiguration Exploitation

Check for:

* Anonymous authentication
* Debug authentication logging
* Weak SASL configurations
* Legacy protocols enabled

A single misconfigured auth setting can bypass all controls.

---

## 5. Phase 3 – Initial Access Validation

### 5.1 Authenticated Mailbox Access

**Goal:** Confirm compromise quietly.

Actions:

* Login via IMAP/IMAPS
* Enumerate folders
* Avoid message deletion
* Avoid sending mail initially

Red-team discipline:

* Read-only first
* Preserve timestamps
* Minimal footprint

---

### 5.2 Mailbox Enumeration

Targets:

* Inbox
* Sent Items
* Drafts
* Trash
* Custom folders (HR, Finance, Legal)

High-value content:

* Password reset emails
* VPN credentials
* MFA bypass links
* Internal URLs
* Attachments with credentials

---

## 6. Phase 4 – Post-Compromise Exploitation

### 6.1 Intelligence Collection

Extract:

* Internal network details
* Naming conventions
* Projects and tooling
* Vendor relationships
* Security alerts and warnings

Email is often the **most honest internal system**.

---

### 6.2 Lateral Movement Enablement

Use mailbox data to:

* Reset passwords elsewhere
* Access internal portals
* Harvest VPN details
* Identify privileged users
* Launch internal phishing

Mailbox compromise often precedes domain compromise.

---

### 6.3 SMTP Abuse (Optional, High Risk)

If permitted:

* Send internal emails as victim
* Deliver payloads or links
* Request sensitive actions

**Caution:** High detection probability.

---

## 7. Phase 5 – Persistence Techniques

### 7.1 Stealthy Persistence

Preferred methods:

* Server-side mail rules
* Forwarding rules
* Hidden folders
* Draft-based dead drops

Avoid:

* Password changes
* Visible configuration changes
* Account lockouts

---

### 7.2 Long-Term Access

Options:

* OAuth tokens (cloud environments)
* App passwords
* Delegated mailbox access
* Secondary mail clients

Persistence should survive password resets when possible.

---

## 8. Phase 6 – Cover Tracks & Exit

### 8.1 Noise Reduction

* Avoid message deletion
* Avoid bulk downloads
* Maintain normal access patterns
* Limit command volume

### 8.2 Evidence Handling

Document:

* Access timestamps
* Commands issued
* Data accessed
* Credentials validated

This supports reporting and client remediation.

---

## 9. Indicators of Success (Red Team KPIs)

* Valid mailbox access obtained
* Sensitive internal data recovered
* Credential reuse demonstrated
* Secondary system access achieved
* Minimal alerts triggered

---

## 10. Common Failure Modes (Lessons Learned)

* Over-aggressive brute forcing
* Sending emails too early
* Ignoring sent mail folders
* Missing draft folders
* Forgetting certificate intelligence

Mail servers reward patience and precision.

---

## 11. Reporting Guidance

Final report should include:

* Entry vector
* Credentials obtained
* Mailboxes accessed
* Business impact
* Potential blast radius
* Clear remediation steps

Mail compromise is rarely isolated—show the chain.


---

Below is a **Blue-Team Detection & Hardening Companion** designed to directly counter the red-team mail server playbook you requested earlier. This is written to be **operational**, **SOC-ready**, and suitable for **defensive architecture reviews, IR runbooks, and audit remediation plans**.

---

# Blue Team Companion

## Detection, Hardening, and Response for Mail Server Compromise

*(IMAP / POP3 / SMTP)*

---

## 1. Defensive Objectives

Primary blue-team goals for mail infrastructure:

* **Detect unauthorized mailbox access early**
* **Prevent credential abuse and reuse**
* **Protect message confidentiality and integrity**
* **Reduce attacker dwell time**
* **Limit blast radius of single mailbox compromise**
* **Preserve evidentiary integrity for IR**

Mail servers are identity systems, not just messaging platforms.

---

## 2. Threat Model Summary

### Common Mail-Based Attack Paths

* Password spraying against IMAP/POP3
* Credential reuse from VPN/web breaches
* Exploitation of weak TLS enforcement
* Abuse of legacy authentication
* Silent persistence via mail rules or forwarding
* Internal phishing from compromised inboxes

### Why Mail Is a Prime Target

* Contains credentials, reset links, and MFA flows
* Trusted internally and externally
* Often under-monitored compared to endpoints
* Historically permissive configurations

---

## 3. Detection Strategy

### 3.1 Authentication Monitoring (Critical)

**Monitor all authentication attempts to:**

* IMAP / IMAPS
* POP3 / POP3S
* SMTP AUTH
* Submission ports

#### High-Value Signals

* Authentication attempts outside business hours
* New source IPs or geographies
* Rapid sequential logins across accounts
* Successful login after multiple failures
* LOGIN / PLAIN usage where stronger methods exist

**Action:**
Forward mail authentication logs to SIEM with **high priority**.

---

### 3.2 Protocol-Level Anomaly Detection

#### IMAP-Specific Indicators

* Sudden `LIST "" *` usage on first login
* Access to Sent, Drafts, or Trash immediately
* Bulk `FETCH` activity
* Access to rarely used folders

#### POP3-Specific Indicators

* Large RETR operations
* Message deletion (`DELE`) shortly after retrieval
* CAPA enumeration followed by auth

These behaviors are **human-unlikely but attacker-common**.

---

### 3.3 TLS & Certificate Monitoring

Alert on:

* Plaintext IMAP/POP3 usage
* STARTTLS downgrade attempts
* Self-signed cert usage in production
* Excessively long certificate lifetimes
* TLS versions < 1.2

Mail servers should **never quietly accept weak crypto**.

---

### 3.4 Mailbox Configuration Change Detection

Monitor:

* Creation of forwarding rules
* Hidden or auto-delete rules
* Delegated mailbox permissions
* App passwords / OAuth tokens
* Changes to spam or inbox rules

**Persistence almost always lives here.**

---

## 4. Hardening Strategy

### 4.1 Authentication Hardening (Top Priority)

#### Enforce:

* Strong password policies
* MFA for all mail access
* Unique credentials (no reuse)
* Account lockout thresholds
* Rate-limiting on auth attempts

#### Disable:

* Anonymous authentication
* Legacy auth (LOGIN, PLAIN without TLS)
* NTLM where unnecessary
* Shared mailboxes without MFA

If legacy auth exists, attackers will find it.

---

### 4.2 TLS Enforcement

**Required Controls:**

* Disable plaintext ports (110, 143)
* Enforce TLS 1.2+ only
* Use valid, short-lived certificates
* Require STARTTLS or implicit TLS
* Disable weak ciphers and renegotiation

TLS should be mandatory, not optional.

---

### 4.3 Logging Configuration (Defensive Use)

#### Enable:

* Authentication success/failure
* Source IP and user agent
* Mailbox access logs
* Rule and forwarding changes
* SMTP AUTH usage

#### Disable:

* Password logging
* auth_debug_passwords
* Excessive sensitive data logging

Logs must support detection **without becoming a breach artifact themselves**.

---

## 5. Mailbox-Level Protections

### 5.1 Rule and Forwarding Controls

* Alert on any new forwarding rule
* Block external forwarding by default
* Require admin approval for mailbox delegation
* Periodically audit inbox rules

Rules are attacker persistence with a UI.

---

### 5.2 Attachment & Link Protections

* Detonate attachments from internal senders
* Scan links even from trusted mailboxes
* Re-scan historical emails post-compromise

Trust is what attackers exploit.

---

## 6. Incident Response Playbook (Mail Compromise)

### 6.1 Initial Triage

1. Identify affected mailbox(es)
2. Confirm login timestamps and source IPs
3. Determine access method (IMAP, POP3, SMTP)
4. Identify data accessed (inbox, sent, drafts)

---

### 6.2 Containment

* Force password reset
* Revoke sessions and tokens
* Disable app passwords
* Remove suspicious rules and forwarding
* Block attacker IPs temporarily

Avoid alerting the attacker before access is revoked.

---

### 6.3 Eradication

* Review mailbox contents for staging emails
* Reset credentials on dependent systems
* Review VPN, SSO, and cloud logs
* Scan endpoints if credentials reused

Mail compromise is rarely isolated.

---

### 6.4 Recovery

* Restore clean mailbox state
* Reinstate legitimate rules
* Re-enable account with hardened settings
* Notify impacted users or departments

---

## 7. Strategic Controls & Architecture

### 7.1 Zero Trust Principles for Mail

* Treat mail as a privileged system
* Enforce conditional access
* Restrict access by device posture
* Monitor continuously, not periodically

---

### 7.2 Segmentation & Blast Radius Reduction

* Separate mail auth from AD where possible
* Limit mail server access from user networks
* Restrict admin interfaces to management VLANs

---

## 8. Mapping to ATT&CK (Contextual)

Mail compromise commonly aligns with:

* Credential Access
* Initial Access
* Persistence
* Lateral Movement
* Collection

Frameworks like **MITRE ATT&CK** are useful for mapping detections, but the priority is **actionable telemetry**, not taxonomy.

---

## 9. Blue Team KPIs

* Mean time to detect mailbox compromise
* Percentage of mail auth protected by MFA
* Legacy auth usage rate
* Number of forwarding rule alerts
* Credential reuse incidents originating from mail

What you measure is what attackers exploit.

---

## 10. Common Defensive Failures

* Treating mail as “just IT infrastructure”
* Leaving legacy auth enabled “temporarily”
* Logging too little—or logging passwords
* Not auditing mailbox rules
* Assuming TLS equals security

Mail security fails quietly and expensively.

---

## 11. Executive Takeaway

Mail servers sit at the intersection of **identity, trust, and data**.
A mature blue team treats them like **domain controllers with inboxes**.

Detection must be **behavioral**, hardening must be **opinionated**, and response must be **immediate and decisive**.

---
