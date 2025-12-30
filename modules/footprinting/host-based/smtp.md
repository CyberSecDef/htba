# Technical Report: Simple Mail Transfer Protocol (SMTP) Architecture, Enumeration, and Security Risks

## 1. Purpose and Role of SMTP

The **Simple Mail Transfer Protocol (SMTP)** is the standard protocol used to **send email** across IP networks. SMTP is responsible only for **mail submission and transfer**, not retrieval. For retrieving emails, it is commonly paired with:

* **POP3** (Post Office Protocol)
* **IMAP** (Internet Message Access Protocol)

SMTP operates in a **client–server model**, but servers frequently act as clients when relaying messages to other SMTP servers.

SMTP is a critical enterprise service and, as a result, a **high-value enumeration target** during penetration tests.

---

## 2. SMTP Ports and Transport Security

### 2.1 Common SMTP Ports

| Port    | Purpose                                                  |
| ------- | -------------------------------------------------------- |
| **25**  | Default SMTP (server-to-server, legacy, often plaintext) |
| **587** | Mail submission with authentication (STARTTLS)           |
| **465** | SMTPS (implicit TLS, deprecated but still used)          |

### 2.2 Encryption Behavior

* SMTP is **unencrypted by default**
* STARTTLS upgrades a plaintext session to TLS
* Without TLS, credentials and message content are transmitted in **cleartext**

Misconfigured or legacy servers often still allow plaintext authentication.

---

## 3. SMTP Components and Mail Flow

SMTP mail delivery involves multiple logical components:

| Component   | Role                                     |
| ----------- | ---------------------------------------- |
| **MUA**     | Mail User Agent (email client)           |
| **MSA**     | Mail Submission Agent (validates sender) |
| **MTA**     | Mail Transfer Agent (relays email)       |
| **MDA**     | Mail Delivery Agent (stores mail)        |
| **Mailbox** | Retrieved via IMAP/POP3                  |

Mail flow:

```
MUA → MSA → (Relay / MTA) → MDA → Mailbox
```

Misconfiguration at the **MSA or MTA level** often leads to severe vulnerabilities such as **open relay**.

---

## 4. Core SMTP Weaknesses

SMTP has two inherent weaknesses:

1. **Sender authenticity is not guaranteed**

   * Sender addresses are trivial to spoof
2. **Delivery confirmation is unreliable**

   * Failure messages are inconsistent and vague

These weaknesses make SMTP a prime vector for:

* Spam
* Phishing
* Social engineering
* Email spoofing

---

## 5. ESMTP and Security Extensions

Modern SMTP servers typically implement **Extended SMTP (ESMTP)**.

Key ESMTP features:

* `EHLO` command
* STARTTLS encryption
* AUTH mechanisms (e.g., AUTH PLAIN)
* Enhanced status codes

When practitioners refer to “SMTP” today, they almost always mean **ESMTP**.

---

## 6. Default SMTP Server Configuration (Postfix Example)

The provided Postfix configuration reveals several important aspects:

* Internal network trust (`mynetworks`)
* Hostname and domain masquerading
* TLS session caching
* IPv4-only operation
* HELO hostname restrictions

Of particular importance:

```ini
mynetworks = 127.0.0.0/8 10.129.0.0/16
```

This setting defines **which IP ranges are allowed to relay mail without authentication**. Misconfiguration here leads directly to open relay conditions.

---

## 7. SMTP Commands and Their Security Impact

| Command     | Purpose               | Risk                          |
| ----------- | --------------------- | ----------------------------- |
| HELO / EHLO | Initiates session     | Reveals capabilities          |
| AUTH        | Authenticates client  | Credential exposure if no TLS |
| MAIL FROM   | Declares sender       | Spoofable                     |
| RCPT TO     | Declares recipient    | User enumeration              |
| DATA        | Sends message body    | Content injection             |
| VRFY        | Verifies users        | Account enumeration           |
| EXPN        | Expands mailing lists | Information disclosure        |
| RSET        | Resets transaction    | Abuse for probing             |
| NOOP        | Keepalive             | Low risk                      |
| QUIT        | Ends session          | —                             |

---

## 8. Manual SMTP Interaction via Telnet

Using `telnet` to port 25 allows:

* Banner grabbing
* Capability discovery
* User enumeration
* Mail submission testing

The EHLO response reveals:

* Supported extensions
* Message size limits
* Encoding support

This information helps tailor further enumeration.

---

## 9. User Enumeration via VRFY

The `VRFY` command is designed to verify mailbox existence.

However:

* Many servers return **252** regardless of validity
* This behavior prevents enumeration but also produces **false positives**

Conclusion:

> VRFY results must **never be trusted blindly**, especially from automated tools.

---

## 10. SMTP Over Proxies

SMTP enumeration can be performed through HTTP proxies using:

```
CONNECT <ip>:25 HTTP/1.0
```

This technique is useful when:

* Direct outbound SMTP is blocked
* Web proxy access is available

---

## 11. Sending Emails via SMTP CLI

SMTP allows full email creation via command line:

* Custom headers
* Subject, CC, BCC
* Message body

This capability enables:

* Spoofing tests
* Social engineering simulation
* Relay validation

---

## 12. Email Headers as an Intelligence Source

Email headers contain:

* Sender and recipient metadata
* Timestamps
* Relay path
* Mail server hostnames
* IP addresses

Headers are defined by **RFC 5322** and are often rich in infrastructure intelligence.

---

## 13. Dangerous SMTP Misconfigurations

### 13.1 Open Relay

A catastrophic configuration example:

```ini
mynetworks = 0.0.0.0/0
```

This allows **any host** to send email through the server.

Consequences:

* Spam campaigns
* Blacklisting
* Legal and reputational damage
* Phishing facilitation

---

## 14. SMTP Service Footprinting with Nmap

### 14.1 Capability Enumeration

The `smtp-commands` NSE script:

* Uses EHLO
* Enumerates supported commands

### 14.2 Open Relay Detection

The `smtp-open-relay` NSE script:

* Performs 16 different relay tests
* Validates multiple address formats
* Produces high-confidence results

A result of **16/16 successful tests** confirms an **open relay**.

---

## 15. Security Impact of an Open Relay

An open SMTP relay enables:

* Anonymous mail sending
* Identity spoofing
* Phishing at scale
* Malware delivery
* Reputation destruction

From a penetration testing perspective, it represents:

* A **high-impact, low-complexity finding**
* A gateway to broader social engineering attacks

---

## 16. Defensive Takeaways

Defensive controls implied by the document include:

* Strict `mynetworks` definitions
* Mandatory SMTP authentication
* TLS enforcement
* Disabling VRFY/EXPN
* Continuous relay testing
* DNS-based protections (SPF, DKIM, DMARC)

---

## 17. Conclusion

SMTP is deceptively simple but operationally complex. Its legacy design, trust assumptions, and historical misconfigurations make it a **frequent source of critical security findings**.

Enumeration of SMTP services can reveal:

* User accounts
* Infrastructure details
* Relay weaknesses
* Social engineering opportunities

Improperly secured SMTP servers—especially open relays—remain one of the **fastest paths from misconfiguration to abuse** in modern enterprise environments .

---


Below is a **red team–focused SMTP attack playbook** written for **authorized security testing only**. It is intentionally framed as a **decision-driven, objective-oriented guide** rather than a click-by-click exploit manual. The emphasis is on **strategy, signals, impact validation, and documentation**, not abuse.

---

# SMTP Red Team Attack Playbook

**(Authorized Security Testing Only)**

## Purpose

Use SMTP to:

* Assess **email infrastructure exposure**
* Identify **trust boundary failures**
* Validate **social-engineering and abuse risk**
* Demonstrate **business impact** without operational harm

SMTP findings are rarely “just email issues”—they often enable **credential theft, lateral access, reputational damage, and fraud**.

---

## Engagement Preconditions (Non-Negotiable)

* Explicit written authorization
* Defined scope (domains, IPs, tenants)
* Rules of engagement covering:

  * Email sending limits
  * Recipient restrictions
  * Header manipulation permissions
* Client-approved test accounts and inboxes
* Legal review if testing spoofing or relay behavior

---

## Phase 1: Target Qualification & Prioritization

### Objectives

Determine whether SMTP is **worth attacking** and **how far** to go.

### Signals SMTP Is High-Value

* Externally reachable mail servers
* Hybrid cloud/on-prem email
* Legacy SMTP ports exposed
* Weak email security posture (SPF/DKIM/DMARC gaps)
* History of phishing incidents
* Large non-technical user base

### Decision Gate

If SMTP is internal-only, tightly authenticated, and policy-enforced → deprioritize.
If externally reachable or misconfigured → proceed.

---

## Phase 2: Passive Reconnaissance

### Objectives

Understand the email ecosystem **without touching the server**.

### Intelligence Sources

* DNS records (MX, TXT)
* Public breach/phishing reports
* Email headers from client-provided samples
* Cloud provider fingerprints
* Security policy disclosures

### What You’re Mapping

* Mail hosting model (cloud vs on-prem)
* Relay boundaries
* Trust assumptions
* Sender validation strategy

---

## Phase 3: Capability Discovery (Low Noise)

### Objectives

Identify what the SMTP service **claims** to support.

### What to Observe

* Banner information
* Protocol extensions
* Authentication requirements
* Encryption posture
* Message size limits

### Risk Indicators

* Plaintext capability exposure
* Legacy authentication methods
* Overly permissive behavior
* Inconsistent responses between servers

---

## Phase 4: User & Trust Enumeration (Controlled)

### Objectives

Determine whether the server **leaks identity or trust signals**.

### Enumeration Vectors

* Recipient validation behavior
* Response code differences
* Timing discrepancies
* Error verbosity

### Constraints

* Use **approved test identities only**
* Avoid bulk probing
* Stop immediately if enumeration is unreliable

### Decision Gate

If user discovery is blocked or normalized → pivot.
If identity leakage exists → document, do not exploit at scale.

---

## Phase 5: Relay & Abuse Validation

### Objectives

Determine whether the server can be abused as a **mail relay**.

### What You Are Testing

* Trust boundary enforcement
* Sender/recipient relationship checks
* Authentication bypass conditions

### Impact Scenarios

* External-to-external mail acceptance
* Internal domain spoofing
* Third-party relay misuse

### Validation Standard

* Single, controlled test
* Approved recipient
* Immediate cleanup and reporting

---

## Phase 6: Spoofing & Impersonation Assessment

### Objectives

Measure **brand and identity protection**, not deceive users.

### What to Validate

* Sender address enforcement
* Header trust assumptions
* SPF/DKIM/DMARC effectiveness
* Client-side trust indicators

### Safe Demonstrations

* Delivery to test mailboxes
* Visual similarity analysis
* Header analysis only
* No real user targeting

### Business Impact Mapping

* Executive impersonation risk
* Finance / HR fraud exposure
* External trust degradation

---

## Phase 7: Message Integrity & Transport Security

### Objectives

Assess confidentiality and integrity of email in transit.

### What to Evaluate

* Encryption enforcement
* Downgrade behavior
* Authentication protection
* Credential exposure risk

### Risk Signals

* Optional encryption
* Inconsistent TLS enforcement
* Legacy cipher support

---

## Phase 8: Chaining & Escalation (If Approved)

### Objectives

Demonstrate how SMTP weaknesses **enable broader compromise**.

### Common Chains

* SMTP → Phishing → Credential access
* SMTP → Internal trust abuse → App access
* SMTP → Reputation damage → Operational impact

### Guardrails

* No malware
* No live credential harvesting
* No production data access
* Proof-of-concept only

---

## Phase 9: Detection & Response Testing (Optional)

### Objectives

Assess **defender visibility** and response maturity.

### What to Observe

* Logging coverage
* Alerting latency
* SOC response
* Email security tooling effectiveness

### Metrics

* Time to detection
* Quality of alerts
* Response coordination

---

## Phase 10: Evidence Collection & Reporting

### Evidence to Capture

* Server responses (sanitized)
* Header samples
* Configuration observations
* Decision points
* Impact narratives

### Reporting Focus

* **Why this matters**, not just what happened
* Likelihood of abuse
* Realistic threat scenarios
* Clear remediation paths

Avoid:

* Tool dumps
* Raw transcripts without context
* Overly technical language for executives

---

## Risk Rating Guidance

| Finding                  | Typical Severity |
| ------------------------ | ---------------- |
| Open relay               | Critical         |
| Domain spoofing          | High             |
| User enumeration         | Medium           |
| Weak TLS enforcement     | Medium           |
| Excessive banner leakage | Low              |

---

## Professional Red Team Principles (SMTP)

* SMTP flaws are **force multipliers**, not endpoints
* One clean proof beats ten noisy tests
* Email issues are **business-risk issues**
* If it feels like spammer behavior—you’ve gone too far
* Always stop before abuse begins

---

## Final Note

SMTP attacks succeed because email is **trusted infrastructure**.
Your job as a red team is not to “send mail,” but to **prove where trust breaks**—clearly, safely, and defensibly.

---

# SMTP Defender Detection & Response Guide

## Purpose

Enable defenders to:

* Detect **SMTP abuse, misconfiguration, and exploitation**
* Respond quickly to **email-based attack paths**
* Reduce **blast radius and dwell time**
* Improve **email trust boundaries and monitoring maturity**

SMTP incidents are rarely isolated; they are often the **entry point to fraud, phishing, or credential compromise**.

---

## 1. Threat Model Overview

### Primary SMTP Abuse Scenarios

* Open relay exploitation
* Domain spoofing (internal/external)
* Phishing delivery
* Credential harvesting
* Business Email Compromise (BEC)
* Reputation poisoning / blacklisting
* Lateral trust abuse between mail systems

### Adversary Goals

* Send email anonymously
* Impersonate trusted identities
* Bypass security controls
* Deliver payloads or links
* Establish long-term abuse channels

---

## 2. Detection Strategy (High-Level)

SMTP detection must operate at **four layers simultaneously**:

1. **Network Layer** – Connection behavior and protocol misuse
2. **Mail Server Layer** – SMTP command flow and relay decisions
3. **Message Layer** – Headers, sender alignment, and content
4. **User Layer** – Clicks, replies, and credential entry

Failing to monitor any one layer creates blind spots.

---

## 3. Network-Level Detection

### Key Telemetry Sources

* Firewall logs
* Network IDS/IPS
* Flow data (NetFlow, IPFIX)
* Load balancer logs (if applicable)

### High-Risk Indicators

* External hosts connecting directly to TCP 25
* Repeated SMTP sessions from non-mail infrastructure
* SMTP connections bypassing expected gateways
* Unusual SMTP traffic volume spikes
* Connections without STARTTLS where expected

### Detection Rules

* Alert on **external → SMTP server** connections not originating from known mail relays
* Alert on **SMTP sessions without TLS negotiation**
* Alert on **sudden increases in RCPT TO attempts per session**

### Immediate Actions

* Rate-limit offending IPs
* Block unauthorized source ranges
* Escalate to mail team for configuration review

---

## 4. Mail Server–Level Detection

### Critical Logs to Enable

* SMTP transaction logs
* Authentication logs
* Relay decision logs
* TLS negotiation logs
* Rejected message logs

### High-Value Signals

* Successful mail delivery without authentication
* MAIL FROM domains not owned by the organization
* RCPT TO addresses outside expected domains
* Repeated 250 OK responses to invalid users
* SMTP AUTH attempts without TLS

### Open Relay Detection

* Messages sent **external → external** through your server
* Absence of authentication for relay traffic
* Mail queue growth without internal origin

### Immediate Actions

* Disable relay rules temporarily if abuse confirmed
* Restrict relay to authenticated users only
* Enforce TLS for all AUTH attempts

---

## 5. Message-Level Detection

### Header Analysis Signals

* Sender domain mismatch (From vs Return-Path)
* Missing or failing SPF/DKIM
* DMARC policy violations
* Suspicious Received header chains
* Abnormal HELO/EHLO hostnames

### High-Risk Message Traits

* Internal domain spoofing
* Executive impersonation
* External sender using internal display names
* Messages lacking authentication results headers

### Automated Controls

* Enforce **DMARC = reject**
* Quarantine SPF softfail + DKIM fail combinations
* Flag internal display name spoofing

---

## 6. User Behavior & Endpoint Detection

### Telemetry Sources

* Email security gateway logs
* Endpoint detection (EDR)
* Identity provider logs
* Browser telemetry

### Behavioral Indicators

* Credential submission after email receipt
* Unusual mailbox rule creation
* Outbound emails sent from compromised accounts
* Sudden MFA fatigue or bypass attempts

### Immediate Actions

* Lock affected accounts
* Invalidate sessions and tokens
* Force password resets
* Review mailbox rules and forwarding

---

## 7. Incident Response Playbooks

### Scenario 1: Open Relay Detected

**Containment**

* Disable relay immediately
* Block offending IPs
* Pause outbound mail if required

**Eradication**

* Fix `mynetworks` / relay rules
* Enforce authentication
* Require TLS

**Recovery**

* Remove blacklisting
* Notify stakeholders
* Monitor for recurrence

---

### Scenario 2: Domain Spoofing / Phishing

**Containment**

* Quarantine related messages
* Block sender patterns
* Alert users

**Eradication**

* Enforce DMARC reject
* Tighten SPF/DKIM alignment

**Recovery**

* User awareness notification
* SOC monitoring spike

---

### Scenario 3: Credential Compromise via Email

**Containment**

* Disable affected accounts
* Kill active sessions
* Reset credentials

**Eradication**

* Remove malicious mailbox rules
* Review OAuth grants

**Recovery**

* Audit access logs
* Monitor for lateral movement

---

## 8. Detection Engineering Recommendations

### Must-Have Alerts

* SMTP AUTH without TLS
* External-to-external mail relay
* Internal domain spoofing
* Repeated RCPT enumeration behavior
* Abnormal SMTP error normalization

### SIEM Correlation Ideas

* SMTP logs + identity provider auth logs
* Email delivery + endpoint process execution
* Mail gateway alerts + DNS logs

---

## 9. Metrics to Track

| Metric           | Why It Matters               |
| ---------------- | ---------------------------- |
| Time to detect   | Measures SOC effectiveness   |
| Time to contain  | Limits damage                |
| Abuse recurrence | Indicates configuration gaps |
| User click rate  | Measures phishing resilience |
| False positives  | Controls alert fatigue       |

---

## 10. Post-Incident Improvements

After every SMTP-related incident:

* Review relay and auth configurations
* Audit DNS email records
* Update detection rules
* Run tabletop exercises
* Conduct red team retesting

SMTP incidents should **never be treated as “just email issues.”**

---

## 11. Executive Communication Guidance

Frame SMTP incidents as:

* Trust boundary failures
* Brand risk
* Financial fraud enablers
* Identity security weaknesses

Avoid technical jargon when briefing leadership. Focus on **impact, likelihood, and prevention**.

---

## Final Takeaway

SMTP defense is about **protecting trust**.

Attackers do not need zero-days—only **misplaced assumptions**. Strong detection, fast response, and disciplined configuration management turn SMTP from a liability into a monitored, controlled service.

