# Utilising WHOIS

WHOIS data becomes truly valuable when it is **interpreted in context**, rather than viewed as a static record. While WHOIS does not expose vulnerabilities directly, it provides **timing, ownership, infrastructure, and governance signals** that help analysts rapidly assess legitimacy, risk, and intent.

The following scenarios illustrate how WHOIS is used in practical security operations.

---

## Scenario 1: Phishing Investigation

An email security gateway flags a suspicious message sent to multiple employees. The email claims to originate from the company’s bank and urges recipients to click a link to “verify” account details.

A security analyst begins the investigation by performing a WHOIS lookup on the domain embedded in the email.

### WHOIS Findings

* **Registration Date:** The domain was registered only days ago.
* **Registrant:** Registrant information is hidden behind a privacy service.
* **Name Servers:** The name servers belong to a hosting provider frequently associated with malicious or abusive activity.

### Analysis

Individually, none of these findings are definitive. Combined, they are highly indicative of phishing activity:

* Newly registered domains are commonly used in short-lived campaigns.
* Privacy shielding is typical for both legitimate and malicious use, but increases risk when paired with other indicators.
* Bulletproof or abuse-tolerant hosting strongly suggests malicious intent.

### Outcome

The analyst:

* Blocks the domain at email and web gateways.
* Issues an internal warning to employees.
* Expands the investigation to related domains and IP infrastructure using the same hosting provider.

WHOIS enables **rapid triage**, allowing defenders to act before users interact with the malicious content.

---

## Scenario 2: Malware Analysis

A malware sample is observed communicating with a remote command-and-control (C2) domain. A security researcher performs a WHOIS lookup on the domain to understand the attacker’s infrastructure.

### WHOIS Findings

* **Registrant:** Registered to an individual using a free, anonymous email service.
* **Registrant Location:** Address associated with a region known for high cybercrime activity.
* **Registrar:** Registrar with a documented history of weak abuse enforcement.

### Analysis

These attributes suggest the domain is:

* Not part of legitimate infrastructure.
* Likely hosted on compromised or intentionally abuse-tolerant systems.
* Unlikely to respond to takedown requests quickly.

### Outcome

The researcher:

* Classifies the domain as high-confidence malicious infrastructure.
* Notifies the hosting provider and registrar.
* Uses the WHOIS data to pivot into additional infrastructure associated with the same registrant or registrar.

In this scenario, WHOIS supports **attribution and infrastructure analysis**, not just blocking decisions.

---

## Scenario 3: Threat Intelligence Reporting

A cybersecurity firm tracks a threat actor group targeting financial institutions. Analysts collect WHOIS data for domains used across multiple campaigns.

### WHOIS Patterns Identified

* **Registration Timing:** Domains registered in clusters shortly before major attacks.
* **Registrant Data:** Reused aliases and fabricated identities.
* **Name Servers:** Repeated use of the same DNS infrastructure.
* **Takedown History:** Domains frequently disabled after campaigns, indicating prior intervention.

### Analysis

By correlating WHOIS data across campaigns, analysts identify consistent operational patterns that reveal:

* Infrastructure reuse
* Planning timelines
* Operational maturity

### Outcome

The firm produces a threat intelligence report that includes:

* WHOIS-derived indicators of compromise (IOCs)
* Predictive indicators for future campaigns
* Infrastructure characteristics other organizations can monitor proactively

Here, WHOIS contributes to **strategic threat intelligence**, not just incident response.

---

## Using WHOIS in Practice

### Installing the WHOIS Utility (Linux)

Before performing WHOIS queries, ensure the utility is installed:

```bash
sudo apt update
sudo apt install whois -y
```

---

### Basic WHOIS Query Example

```bash
whois facebook.com
```

Sample output (abridged):

```text
Domain Name: FACEBOOK.COM
Registrar: RegistrarSafe, LLC
Creation Date: 1997-03-29
Registry Expiry Date: 2033-03-30
Registrant Organization: Meta Platforms, Inc.
Name Server: A.NS.FACEBOOK.COM
Name Server: B.NS.FACEBOOK.COM
```

---

## Interpreting WHOIS Output: A Legitimate Domain Example

The WHOIS record for `facebook.com` demonstrates characteristics commonly associated with well-governed, legitimate domains:

### Domain Registration

* **Registrar:** RegistrarSafe, LLC
* **Creation Date:** 1997
* **Expiry Date:** 2033

Long registration history and extended renewal periods indicate a stable, long-term asset.

---

### Domain Ownership

* **Organization:** Meta Platforms, Inc.
* **Contact Role:** Domain Admin

Large organizations typically use role-based contacts rather than individual employees, reducing exposure.

---

### Domain Status Protections

Statuses such as:

* `clientTransferProhibited`
* `serverUpdateProhibited`
* `clientDeleteProhibited`

indicate strong safeguards against unauthorized changes or hijacking.

---

### DNS Infrastructure

Name servers within the `facebook.com` domain suggest internally managed DNS infrastructure, common for large enterprises seeking control, resilience, and security.

---

## Reconnaissance Considerations

* WHOIS data alone rarely identifies vulnerabilities.
* Its value lies in **context**, **correlation**, and **pattern recognition**.
* Privacy protection does not equal malicious intent—but patterns matter.
* WHOIS should always be combined with DNS analysis, certificate transparency logs, and web reconnaissance for full situational awareness.

---

## Key Takeaway

WHOIS is a **context amplifier**. It helps analysts determine:

* Whether a domain is likely legitimate or suspicious
* How infrastructure is governed
* How attackers provision and reuse resources
* Where to pivot next in an investigation

Used correctly, WHOIS accelerates decision-making and reduces uncertainty during both offensive and defensive security operations.

---

# Red Team Playbook: Utilising WHOIS

## Mission Objective

Leverage WHOIS data to gain **contextual intelligence** about target domains that enables:

* Asset expansion
* Infrastructure inference
* Campaign timing analysis
* Social engineering preparation
* Threat infrastructure profiling

WHOIS is not about finding vulnerabilities directly.
It is about **reducing uncertainty** and **increasing precision** in every phase that follows.

---

## Phase 0 — Scope & Assumptions

Before performing WHOIS reconnaissance, confirm:

* Authorized domains and TLDs
* Whether third-party and look-alike domains are in scope
* Whether historical WHOIS analysis is permitted
* Intended use (phishing simulation, infrastructure mapping, threat emulation)

WHOIS is passive, but conclusions drawn from it must still respect scope.

---

## Phase 1 — Initial Domain Profiling

### 1.1 Primary WHOIS Lookup

Perform a WHOIS lookup on the target domain.

**Objectives:**

* Identify registrar
* Capture registration, update, and expiration dates
* Identify registrant organization (if visible)
* Extract name servers
* Review domain status flags

**Key Questions:**

* Is the domain long-lived or newly registered?
* Is it centrally governed or loosely managed?
* Are protections against transfer and deletion enabled?

---

### 1.2 Legitimacy Baseline Assessment

Use WHOIS data to establish a **baseline legitimacy profile**.

Indicators of maturity:

* Long registration history
* Enterprise registrar
* Locked domain status
* Role-based contacts
* Internally managed DNS

Indicators of risk:

* Very recent registration
* Short expiration window
* Weak or unknown registrar
* Bulletproof or abuse-tolerant hosting
* Reused or anonymous contact patterns

This baseline informs **confidence scoring**, not attribution.

---

## Phase 2 — Infrastructure Intelligence

### 2.1 Name Server Analysis

Extract name server details and assess:

* Internal vs third-party DNS
* Cloud provider patterns
* Environment naming leaks (`dev`, `test`, `stage`)
* Reuse across unrelated domains

**Operational Insight:**
Shared name servers often indicate:

* Shared hosting environments
* Centralized DNS management
* Infrastructure reuse across campaigns

---

### 2.2 Registrar & Hosting Signal Analysis

Profile the registrar and hosting provider:

* Abuse response reputation
* Typical customer base
* Known association with malicious activity
* Jurisdiction and enforcement maturity

This helps determine whether:

* Infrastructure is likely disposable
* Takedown requests will be ignored
* Campaigns are short-lived or persistent

---

## Phase 3 — Campaign Timing & Lifecycle Analysis

### 3.1 Registration Timing Correlation

Compare domain registration dates to:

* Phishing campaigns
* Malware delivery timelines
* Infrastructure spin-up patterns

**Red Team Insight:**
Many adversaries register domains:

* Days or hours before campaign launch
* In small clusters
* Using consistent time windows

This pattern can be mimicked or detected depending on engagement goals.

---

### 3.2 Expiration & Churn Patterns

Analyze:

* Short-lived registrations
* Rapid domain turnover
* Frequent registrar hopping

These behaviors often indicate:

* Evasion tactics
* Commodity phishing operations
* Disposable infrastructure strategies

---

## Phase 4 — Identity & Attribution Signals

### 4.1 Registrant & Contact Analysis

If visible, extract:

* Organization names
* Email domains
* Naming conventions
* Geographic indicators

**Use Cases:**

* Email format inference
* Social engineering realism
* Infrastructure clustering

**Note:**
Privacy protection is not neutral—its presence or absence is itself a signal.

---

### 4.2 Alias & Pattern Reuse

Across multiple WHOIS records, look for:

* Reused contact emails
* Similar registrant names
* Identical phone numbers
* Consistent formatting quirks

These patterns often persist even when identities are falsified.

---

## Phase 5 — Pivoting & Expansion

WHOIS is a **pivot engine**, not an endpoint.

Use extracted data to:

* Identify related domains
* Expand target scope intelligently
* Correlate with DNS enumeration
* Cross-reference certificate transparency logs
* Identify campaign infrastructure clusters

The goal is **asset universe expansion**, not just domain validation.

---

## Phase 6 — Operational Use Cases

### Phishing Campaign Recon

WHOIS helps determine:

* Domain believability
* Registration realism
* Hosting plausibility
* Timing alignment

### Malware & C2 Infrastructure Analysis

WHOIS reveals:

* Infrastructure governance
* Hosting durability
* Likelihood of takedown resistance

### Threat Emulation

WHOIS patterns enable:

* Accurate replication of adversary behavior
* Campaign timing realism
* Infrastructure reuse modeling

---

## OPSEC Considerations

* WHOIS queries are passive and low-noise
* Prefer local CLI tools over third-party web services
* Log all findings with timestamps
* Avoid overconfidence in redacted fields
* Always corroborate with additional recon sources

---

## Common Red Team Errors

* Treating WHOIS as purely administrative data
* Ignoring name server intelligence
* Failing to analyze timing patterns
* Overinterpreting privacy shielding
* Not correlating WHOIS across multiple domains

---

## Success Criteria

WHOIS reconnaissance is successful when you can confidently answer:

* Who likely controls this domain?
* How mature is its governance?
* What infrastructure relationships exist?
* How disposable is the asset?
* What does its lifecycle suggest about intent?

---

## Operator Summary (TL;DR)

1. Query the domain
2. Establish legitimacy baseline
3. Extract infrastructure signals
4. Analyze timing and lifecycle
5. Pivot and expand intelligently

---

Below is a **Blue Team Playbook: Utilising WHOIS**, written as an **operational defense runbook** for SOC analysts, incident responders, threat intelligence teams, and security architects. It focuses on **how defenders should systematically use WHOIS data** to detect threats, assess exposure, and reduce attacker reconnaissance value.

---

# Blue Team Playbook: Utilising WHOIS

## Mission Objective

Use WHOIS data to **detect malicious infrastructure early**, **assess domain legitimacy**, **support investigations**, and **reduce intelligence leakage** that adversaries can exploit.

WHOIS is not a vulnerability scanner.
It is a **context and risk amplifier** that improves speed, confidence, and prioritization in defensive decision-making.

---

## Phase 0 — Governance & Readiness

Before operational use, ensure:

* Domain inventory is accurate and complete
* Registrar accounts are centrally managed
* WHOIS privacy policy is defined
* Monitoring for WHOIS changes is in place
* Analysts understand normal vs abnormal WHOIS patterns

WHOIS is most effective when defenders understand **what “normal” looks like for their organization**.

---

## Phase 1 — Defensive WHOIS Baseline

### 1.1 Establish Organizational WHOIS Baseline

For all owned domains, document:

* Registrar(s) in use
* Typical registration duration
* Renewal cadence
* WHOIS privacy usage
* Name server patterns
* Domain status flags

**Outcome:**
A reference profile used to quickly identify anomalies.

---

### 1.2 Approved Registrar & Provider Profile

Maintain an allowlist of:

* Approved registrars
* Approved DNS providers
* Approved hosting providers

Any domain outside these norms should be flagged for review.

---

## Phase 2 — Threat Detection & Triage

### 2.1 Phishing & Fraud Domain Analysis

When a suspicious domain is identified (email, web proxy, EDR):

Review WHOIS for:

* Very recent registration
* Short registration periods
* Privacy-shielded registrants
* Abuse-tolerant registrars
* Bulletproof or suspicious name servers

**Decision Guidance:**

* Multiple high-risk indicators → immediate block
* Mixed indicators → escalate for enrichment
* Legitimate patterns → continue investigation

---

### 2.2 Malware & C2 Infrastructure Assessment

For domains contacted by malware:

Analyze:

* Registrar reputation
* Registrant email type (free vs corporate)
* Jurisdiction and abuse history
* Name server reuse across known malicious domains

**Outcome:**
Confidence scoring for malicious infrastructure classification.

---

## Phase 3 — Investigation Support

### 3.1 Incident Response Pivoting

Use WHOIS to:

* Identify related domains
* Discover infrastructure clusters
* Track campaign expansion
* Correlate domains across incidents

WHOIS often reveals **campaign-scale infrastructure reuse** invisible at the single-domain level.

---

### 3.2 Threat Intelligence Correlation

Correlate WHOIS data with:

* DNS telemetry
* Certificate transparency logs
* Passive DNS
* Historical takedown data

This enables defenders to move from **reactive blocking** to **proactive detection**.

---

## Phase 4 — Exposure Reduction (Defensive Hardening)

### 4.1 WHOIS Data Minimization

Ensure:

* WHOIS privacy enabled where allowed
* Role-based contacts used (not individuals)
* No internal naming conventions exposed
* No personal phone numbers listed

**Goal:**
Reduce attacker intelligence without breaking operational requirements.

---

### 4.2 Domain Lifecycle Management

* Auto-renew enabled on all domains
* Expiration alerts monitored
* Ownership documented
* Decommissioned domains retired securely

Domain expiration is one of the **most preventable causes of compromise**.

---

## Phase 5 — Monitoring & Alerting

### 5.1 WHOIS Change Monitoring

Alert on:

* Registrar changes
* Registrant changes
* Name server updates
* Removal of domain locks
* Privacy setting changes

Unexpected WHOIS changes should be treated as **potential account compromise**.

---

### 5.2 SOC Integration

Incorporate WHOIS checks into:

* Phishing triage workflows
* Malware investigation playbooks
* Threat intel enrichment pipelines

WHOIS should be **automatic enrichment**, not an afterthought.

---

## Phase 6 — Decision Framework

### High-Risk WHOIS Indicators

* Domain registered < 30 days ago
* Registrar with poor abuse response
* Short registration term
* Reused infrastructure across known threats
* No domain locks enabled

### Low-Risk WHOIS Indicators

* Long-lived domain
* Enterprise registrar
* Locked status flags
* Consistent historical ownership
* Internal DNS management

WHOIS does not prove maliciousness—it **accelerates confidence**.

---

## Phase 7 — Lessons Learned & Continuous Improvement

After incidents:

* Update baseline patterns
* Document new registrar abuse trends
* Feed findings into detection logic
* Review internal WHOIS exposure posture

Attackers evolve their infrastructure strategies—defenders must evolve faster.

---

## Common Blue Team Mistakes

* Treating WHOIS as purely administrative data
* Ignoring name server intelligence
* Over-trusting privacy shielding
* Not monitoring WHOIS changes
* Failing to correlate across incidents

---

## Success Criteria

WHOIS usage is effective when the team can:

* Rapidly distinguish legitimate vs suspicious domains
* Identify malicious infrastructure early
* Reduce false positives in phishing response
* Detect domain hijacking quickly
* Minimize attacker intelligence gathering

---

## Blue Team Summary (TL;DR)

* WHOIS reveals intent, not exploits
* Patterns matter more than fields
* New domains are risky by default
* Infrastructure reuse is a giveaway
* Monitor WHOIS like authentication logs
