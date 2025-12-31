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

---

# Red Team Playbook

## SNMP Exploitation (v1 / v2c / v3)

---

## 1. Objectives

Primary red-team objectives when targeting SNMP:

* Identify **unauthenticated or weakly authenticated SNMP services**
* Extract **high-fidelity system intelligence**
* Abuse **read-write SNMP access** where present
* Enable **lateral movement, privilege escalation, or persistence**
* Minimize noise while maximizing information gain

SNMP is rarely the final exploit—but it is one of the **most powerful reconnaissance accelerators** available to an attacker.

---

## 2. Threat Model Overview

### Why SNMP Is High Value

* Often enabled by default
* Frequently overlooked by defenders
* Legacy versions still widely deployed
* Exposes **authoritative system data**
* Operates over UDP (low visibility, low friction)

### Common Red-Team Wins

* Full OS and patch enumeration
* Installed software inventories
* Usernames and email addresses
* Network topology insights
* Writable configuration abuse

---

## 3. Phase 1 – Discovery & Footprinting

### 3.1 Port Identification

**Targets:**

* UDP 161 – SNMP queries
* UDP 162 – SNMP traps

Actions:

* Scan for open or filtered UDP 161
* Treat “filtered” as potentially accessible (UDP lies)
* Check both IPv4 and IPv6 exposure

Key indicators:

* SNMP banners
* Response timing differences
* ICMP unreachable behavior

---

### 3.2 Version Identification

Determine:

* SNMPv1
* SNMPv2c
* SNMPv3

Operational value:

* v1/v2c = plaintext, community-based
* v3 = auth/encryption, higher complexity

If v1 or v2c is present, **assume intelligence leakage is likely**.

---

## 4. Phase 2 – Community String Acquisition

### 4.1 Default Community Testing

Test immediately:

* `public`
* `private`
* `community`
* `snmp`
* Organization or hostname-based guesses

This step alone succeeds more often than defenders expect.

---

### 4.2 Community String Brute Forcing

Use wordlists targeting:

* Default values
* Hostnames
* Environment names
* Role-based naming patterns

Operational guidance:

* SNMP does not rate-limit well
* UDP makes detection harder
* Large environments tend to reuse patterns

Success condition:

* Any valid read-only or read-write community string

---

## 5. Phase 3 – Read-Only Enumeration (Primary Value)

### 5.1 System Identification

Enumerate:

* OS name and version
* Kernel build
* Architecture
* Hostname
* System uptime
* Boot parameters

Why this matters:

* Precise exploit selection
* Patch-level accuracy
* Zero guesswork

---

### 5.2 User & Identity Intelligence

Extract:

* Contact emails
* Usernames embedded in system metadata
* Naming conventions

These often correlate directly with:

* Mail accounts
* VPN users
* Active Directory identities

---

### 5.3 Software & Package Enumeration

Query OIDs revealing:

* Installed packages
* Running services
* Version numbers
* Third-party software

This supports:

* Vulnerability mapping
* Exploit chaining
* Privilege escalation planning

SNMP frequently reveals **more than authenticated shell access would**.

---

### 5.4 Network Intelligence

Enumerate:

* Interfaces
* IP addresses
* Routing information
* Listening services
* Open ports (indirectly)

Use this to:

* Map internal networks
* Identify pivot points
* Select lateral movement targets

---

## 6. Phase 4 – Write Access Exploitation (High Impact)

### 6.1 Detect Read-Write Access

Check for:

* `rwcommunity`
* `rwuser noauth`
* Overly permissive views

If write access exists, SNMP becomes **remote administration**.

---

### 6.2 Configuration Abuse

Potential actions:

* Modify service parameters
* Disable security controls
* Change logging behavior
* Trigger service restarts
* Alter network settings

These actions can:

* Cause denial of service
* Enable persistence
* Mask attacker activity

---

### 6.3 Persistence via SNMP

Possible persistence mechanisms:

* Modify startup configurations
* Alter monitored scripts
* Change trap destinations
* Enable additional management interfaces

SNMP persistence is subtle and often ignored during IR.

---

## 7. Phase 5 – Trap Abuse & Evasion

### 7.1 Trap Intelligence

If traps are enabled:

* Identify trap destinations
* Infer monitoring infrastructure
* Learn what events defenders care about

This informs:

* Evasion timing
* Noise reduction strategies

---

### 7.2 Trap Manipulation (Advanced)

In misconfigured environments:

* Redirect traps to attacker-controlled hosts
* Suppress alerts
* Generate false signals

This is rare—but devastating when possible.

---

## 8. Phase 6 – Chaining & Lateral Movement

### 8.1 Exploit Correlation

Use SNMP-derived data to:

* Match CVEs precisely
* Target unpatched services
* Identify weak configurations

SNMP turns blind exploitation into **surgical strikes**.

---

### 8.2 Credential Discovery

SNMP data often reveals:

* Usernames
* Email formats
* Service accounts
* Role identifiers

These directly feed:

* Password spraying
* Phishing
* Kerberos attacks
* VPN compromise

---

## 9. Phase 7 – Operational Security (OPSEC)

### 9.1 Noise Management

Best practices:

* Prefer read-only enumeration
* Avoid write operations unless required
* Limit OID breadth
* Avoid repeated brute forcing

SNMP is stealthy—don’t ruin it.

---

### 9.2 Indicators to Avoid Triggering

Avoid:

* Massive OID sweeps during business hours
* Write operations on production systems
* Trap flooding
* Repeated invalid community attempts from same IP

---

## 10. Reporting & Evidence

Document:

* SNMP versions exposed
* Community strings discovered
* OIDs accessed
* Sensitive data retrieved
* Business impact
* Exploitation potential (even if not executed)

SNMP findings often justify **high-severity risk ratings**.

---

## 11. Red-Team Success Criteria

* Valid community string obtained
* Full system inventory enumerated
* Network intelligence extracted
* Vulnerability exploitation accelerated
* Minimal detection footprint

---

## 12. Common Defender Failures (Observed)

* Leaving SNMPv1/v2c enabled
* Using default community strings
* Assuming “internal only” is safe
* Ignoring SNMP in monitoring
* Treating read-only as harmless

SNMP failures are **quiet, persistent, and systemic**.

---

## 13. Final Takeaway

SNMP is one of the **most underappreciated attack surfaces** in enterprise environments. When exposed, it offers attackers something rare: **truth**—accurate, structured, and complete system intelligence with minimal effort.

A disciplined red team treats SNMP as a **first-stop reconnaissance oracle** and a potential **configuration-level exploit path**, not an afterthought.

---

# Blue Team Guide

## SNMP Detection, Hardening, and Incident Response

*(SNMPv1 / v2c / v3)*

---

## 1. Defensive Objectives

Blue-team priorities for SNMP:

* **Detect unauthorized SNMP access early**
* **Eliminate legacy SNMP exposure**
* **Prevent information disclosure via OIDs**
* **Block write-level SNMP abuse**
* **Reduce attacker reconnaissance capabilities**
* **Ensure SNMP does not become a stealth intel oracle**

SNMP should be treated as a **privileged management interface**, not a background service.

---

## 2. Threat Model Summary

### Why SNMP Is Dangerous When Misconfigured

* Uses UDP (low visibility)
* Legacy versions transmit secrets in plaintext
* Community strings act as reusable passwords
* “Read-only” access still leaks critical system intelligence
* Rarely monitored by default

### Common Attacker Goals

* Enumerate OS, kernel, and packages
* Identify users and email formats
* Map internal networks
* Accelerate exploit selection
* Abuse read-write access for persistence or sabotage

---

## 3. Detection Strategy

### 3.1 Network-Level Detection (Highest Value)

#### Monitor UDP Traffic on:

* **161** – SNMP queries
* **162** – SNMP traps

#### Alert On:

* SNMP requests from non-management networks
* External SNMP traffic (always suspicious)
* High-frequency SNMP queries
* SNMP access outside maintenance windows
* SNMP queries spanning large OID ranges

**Key Insight:**
Legitimate SNMP traffic is **predictable**. Anything novel is suspect.

---

### 3.2 SNMP Authentication & Access Logs

Enable and centralize logs for:

* Successful SNMP queries
* Failed community string attempts
* Version negotiation (v1/v2c/v3)
* Write operations (`SET` requests)

#### High-Risk Indicators

* Multiple community strings tested
* Sudden success after failures
* Read-write operations on production systems
* Queries originating from user workstations

---

### 3.3 OID Behavior Monitoring

Track access to:

* System OIDs (`.1.3.6.1.2.1.1`)
* Host resources (`.1.3.6.1.2.1.25`)
* Software inventory OIDs
* Network interface OIDs

**Red-team pattern:**
Broad OID walks (`snmpwalk`) rather than narrow polling.

---

### 3.4 Trap Monitoring

Monitor:

* Trap destination changes
* Unexpected trap volume
* Traps sent to non-SIEM systems

Traps reveal:

* What defenders monitor
* What events attackers may try to suppress

---

## 4. Hardening Strategy (Authoritative)

### 4.1 Eliminate Legacy SNMP (Critical)

#### Disable Completely:

* SNMPv1
* SNMPv2c

If business constraints prevent removal:

* Isolate aggressively
* Restrict views
* Treat as temporary technical debt

Legacy SNMP is **indefensible** in modern threat models.

---

### 4.2 Enforce SNMPv3 Only

SNMPv3 must use:

* Authentication (`auth`)
* Encryption (`priv`)
* Unique user credentials
* Strong cryptographic algorithms

Reject:

* `noAuthNoPriv`
* Shared SNMPv3 users
* Default usernames

---

### 4.3 Community String Controls (If v2c Exists)

If SNMPv2c **cannot yet be removed**:

* Use **long, random community strings**
* Bind community strings to:

  * Specific IPs
  * Management VLANs
* Separate read-only and read-write strings
* Rotate community strings regularly
* Never reuse strings across environments

Community strings are **passwords**—treat them that way.

---

### 4.4 Restrict OID Views (Mandatory)

Limit exposed OIDs to:

* Only what monitoring actually needs

Explicitly deny:

* Software inventory
* User/contact metadata
* Network topology data
* Host resource details

If SNMP does not need it, **do not expose it**.

---

### 4.5 Disable Write Access Wherever Possible

Audit and remove:

* `rwcommunity`
* `rwcommunity6`
* `rwuser noauth`

Write-level SNMP access equals **unaudited remote administration**.

---

## 5. Network Architecture Controls

### 5.1 Segmentation

* Place SNMP agents behind management VLANs
* Block SNMP from user networks
* Restrict SNMP managers via firewall rules
* Explicitly deny SNMP at network borders

SNMP should never be “flat-network accessible.”

---

### 5.2 IPv6 Considerations

Explicitly audit:

* `rwcommunity6`
* IPv6 SNMP listeners
* Firewall parity between IPv4 and IPv6

IPv6 often re-introduces SNMP exposure accidentally.

---

## 6. Logging & SIEM Integration

### Required Log Fields

* Source IP
* SNMP version
* Community string (hashed, not plaintext)
* OID requested
* Read vs write operation
* Timestamp

### SIEM Use Cases

* Community brute-force detection
* SNMP access from new hosts
* Write operations outside maintenance
* OID enumeration patterns

SNMP logs are **high-signal when collected correctly**.

---

## 7. Incident Response Playbook (SNMP)

### 7.1 Triage

1. Identify SNMP source IPs
2. Confirm SNMP version and access level
3. Determine OIDs accessed
4. Identify whether write operations occurred

---

### 7.2 Containment

* Block SNMP traffic at firewall
* Rotate community strings or credentials
* Disable SNMP temporarily if needed
* Preserve logs for forensics

---

### 7.3 Eradication

* Remove legacy SNMP versions
* Restrict OID views
* Remove write permissions
* Audit all SNMP configurations enterprise-wide

---

### 7.4 Recovery

* Re-enable SNMP with hardened config
* Validate monitoring functionality
* Increase alerting sensitivity temporarily
* Document findings and lessons learned

---

## 8. Audit & Continuous Improvement

### Regular Audits Should Verify:

* No SNMPv1/v2c exposure
* No default community strings
* No write access in production
* OID views are minimal
* SNMP traffic sources are known

### Metrics to Track

* % of assets running SNMPv3
* Number of SNMP-exposed hosts
* Write-enabled SNMP instances
* SNMP detections per quarter

---

## 9. Common Blue-Team Failures

* Assuming “internal” equals safe
* Leaving SNMPv2c for “later”
* Treating read-only as harmless
* Forgetting IPv6
* Not logging SNMP activity

Attackers love SNMP because defenders forget it exists.

---

## 10. Executive Takeaway

SNMP is one of the **highest-impact low-effort reconnaissance vectors** available to attackers when misconfigured.

A mature blue team:

* Eliminates legacy SNMP
* Enforces SNMPv3 with least privilege
* Monitors SNMP like admin access
* Treats OIDs as sensitive data

If SNMP exists, it must be **deliberate, minimal, and monitored**.

---
