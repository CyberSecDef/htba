# WHOIS

WHOIS is a widely used **query-and-response protocol** designed to retrieve information about registered internet resources. Most commonly, WHOIS is associated with **domain names**, but it can also provide details about **IP address ranges** and **autonomous systems (ASNs)**.

At a conceptual level, WHOIS functions like a **public directory for the internet**, allowing users to identify who owns or is responsible for a given online asset and how it is managed.

---

## Basic WHOIS Usage

WHOIS queries can be performed using command-line tools or web-based services. A typical query retrieves registration and administrative information for a domain.

Example:

```bash
whois inlanefreight.com
```

Sample output (abridged):

```text
Domain Name: inlanefreight.com
Registry Domain ID: 2420436757_DOMAIN_COM-VRSN
Registrar WHOIS Server: whois.registrar.amazon
Registrar URL: https://registrar.amazon.com
Updated Date: 2023-07-03T01:11:15Z
Creation Date: 2019-08-05T22:43:09Z
```

---

## Common WHOIS Record Fields

A WHOIS record typically contains the following information:

* **Domain Name**
  The registered domain name (e.g., `example.com`).

* **Registrar**
  The organization through which the domain was registered (e.g., Amazon Registrar, GoDaddy, Namecheap).

* **Registrant Contact**
  The individual or organization that owns the domain.

* **Administrative Contact**
  The party responsible for administrative decisions related to the domain.

* **Technical Contact**
  The individual or team responsible for technical operations such as DNS configuration.

* **Creation and Expiration Dates**
  Indicates when the domain was registered and when it is scheduled to expire.

* **Name Servers**
  DNS servers responsible for resolving the domain name to IP addresses.

It is worth noting that due to privacy regulations (such as GDPR), some registrant and contact details may be redacted or replaced with proxy information.

---

## Brief History of WHOIS

The origins of WHOIS date back to the early days of the internet and are closely tied to the work of **Elizabeth Feinler**, a computer scientist at the Stanford Research Institute.

In the 1970s, as ARPANET rapidly expanded, Feinler and her team at the Network Information Center (NIC) recognized the need for a centralized system to catalog network users, hostnames, and resources. The result was the WHOIS directory—an early, centralized database that allowed network operators to identify who was responsible for which systems.

Although the modern internet is far more decentralized, WHOIS remains a foundational service for transparency, accountability, and operational coordination.

---

## Why WHOIS Matters for Web Reconnaissance

WHOIS data plays a critical role during the **passive reconnaissance** phase of a web assessment. While it does not directly interact with the target infrastructure, it provides context that shapes subsequent reconnaissance and testing decisions.

### Identifying Key Personnel

WHOIS records may disclose:

* Names of administrators
* Email addresses
* Organizational affiliations

This information can help testers understand **who manages the domain** and may inform social engineering risk assessments or phishing simulations.

---

### Discovering Infrastructure Relationships

Details such as:

* Name servers
* Registrars
* Hosting providers

can reveal:

* Third-party dependencies
* Cloud service usage
* Shared infrastructure between multiple domains

These insights help map the broader digital ecosystem surrounding the target.

---

### Historical Analysis

By reviewing historical WHOIS records through third-party services, testers can identify:

* Changes in ownership
* Domain transfers
* Infrastructure migrations
* Rebranding or mergers

Such changes may correlate with legacy systems, forgotten assets, or inconsistent security practices.

---

## Reconnaissance Considerations

* WHOIS is **entirely passive** and does not touch the target’s systems.
* Queries are unlikely to trigger detection or alerting.
* Information accuracy depends on registrar policies and privacy protections.
* WHOIS data should always be correlated with DNS, certificate transparency logs, and other reconnaissance sources for validation.

---

## Key Takeaway

WHOIS provides **foundational context**, not vulnerabilities. Its value lies in helping testers understand **who owns an asset, how it is managed, and where it fits within a larger infrastructure**. When used early and thoughtfully, WHOIS sets the stage for efficient, targeted reconnaissance throughout the remainder of an assessment.

---

# Red Team Playbook: WHOIS Reconnaissance

## Mission Objective

Use WHOIS data to establish **organizational context, infrastructure relationships, and operational patterns** for a target without directly interacting with its systems. WHOIS reconnaissance answers a critical early question:

**“Who owns this asset, how is it managed, and what does that imply about the environment behind it?”**

---

## Phase 0 — Scope Confirmation

Before running WHOIS queries, confirm:

* Authorized domains and TLDs
* Parent organizations in scope
* Whether third-party infrastructure is included
* Whether historical analysis is permitted

WHOIS is passive, but **misinterpreting scope can still lead to incorrect conclusions**.

---

## Phase 1 — Initial WHOIS Enumeration

### 1.1 Primary Domain Lookup

Perform a WHOIS query against the primary target domain.

**Objectives:**

* Identify registrar
* Capture creation and expiration dates
* Identify name servers
* Determine registrant organization (if visible)

**Key Questions:**

* Is the domain newly registered or long-lived?
* Is it managed internally or through a third party?
* Is registration centralized or fragmented?

---

### 1.2 Registrar & Provider Profiling

Analyze the registrar and hosting provider.

**Indicators of Interest:**

* Cloud-native registrars (AWS, GCP, Azure)
* Enterprise registrars (MarkMonitor, CSC)
* Consumer-grade registrars (potentially weaker governance)

**Operational Insight:**

* Enterprise registrars often indicate mature governance
* Consumer registrars may suggest decentralized control

---

## Phase 2 — Organizational Mapping

### 2.1 Registrant & Contact Analysis

If contact information is visible, extract:

* Organization names
* Email domains
* Naming conventions
* Geographic indicators

**Use Cases:**

* Email format discovery
* Organizational structure inference
* Social engineering context (if in scope)

**Note:**
Redacted data is still useful—privacy services themselves indicate maturity and security posture.

---

### 2.2 Domain Portfolio Expansion

Use WHOIS patterns to identify related domains.

Look for:

* Similar registrant names
* Matching name servers
* Common administrative contacts
* Shared registrar accounts

**Objective:**
Expand reconnaissance beyond the initially supplied domain list.

---

## Phase 3 — Infrastructure Intelligence

### 3.1 Name Server Analysis

Extract and analyze name servers.

**Questions to Answer:**

* Are name servers internal or third-party?
* Are they cloud-hosted?
* Are multiple environments sharing DNS infrastructure?

**Indicators:**

* `ns1.dev.example.com`
* `awsdns-*`
* Legacy on-prem DNS servers

These details often hint at **environment sprawl** or **hybrid architectures**.

---

### 3.2 ASN & IP Context (Indirect)

While WHOIS itself does not enumerate hosts, it provides clues for:

* IP ownership
* Autonomous system relationships
* Network provider dependencies

This information feeds directly into later DNS and network reconnaissance.

---

## Phase 4 — Temporal & Historical Analysis

### 4.1 Domain Age Assessment

* Newly registered domains may indicate:

  * Temporary infrastructure
  * Phishing or staging environments
  * Rapid deployments with weaker controls

* Long-lived domains may expose:

  * Legacy systems
  * Historical technical debt

---

### 4.2 Historical WHOIS Review

If permitted, review historical WHOIS records to identify:

* Ownership changes
* Registrar migrations
* Infrastructure shifts
* Rebranding events

**Operational Value:**
Changes often correlate with **forgotten systems**, **deprecated services**, or **inconsistent security practices**.

---

## Phase 5 — Correlation & Validation

WHOIS data should never be used in isolation.

Correlate findings with:

* DNS enumeration
* Certificate transparency logs
* Search engine indexing
* Public documentation

**Goal:**
Convert raw metadata into reliable intelligence.

---

## Phase 6 — Recon-to-Recon Handoff

Deliverables to subsequent reconnaissance phases:

* Confirmed domain ownership
* Registrar and provider profile
* Infrastructure management model
* Related domains for expansion
* Temporal risk indicators (new vs legacy)

WHOIS reconnaissance is complete when:

* Ownership and management context is clear
* Further queries yield redundant information
* DNS and web recon can proceed with precision

---

## OPSEC Considerations

* WHOIS queries are passive and low-risk
* Prefer command-line tools over third-party web services for repeatability
* Log all queries and results for reporting traceability
* Avoid over-interpreting redacted fields

---

## Common Red Team Pitfalls

* Treating WHOIS as purely administrative data
* Ignoring name server patterns
* Overlooking historical changes
* Failing to correlate with DNS and CT logs
* Assuming privacy redaction means “nothing to see”

---

## Success Criteria

WHOIS reconnaissance is successful when you can answer:

* Who controls this domain?
* How professionally is it managed?
* What infrastructure relationships exist?
* What other assets likely belong to the same organization?
* What does the domain’s history suggest about risk?

---

## Operator Summary (TL;DR)

1. Query the domain
2. Profile the registrar
3. Extract infrastructure clues
4. Expand the asset universe
5. Hand off clean intelligence

---

# Blue-Team WHOIS Exposure Checklist

## Purpose

To systematically assess WHOIS records for **information leakage, governance weaknesses, and indirect attack enablement**, and to reduce the intelligence value of WHOIS data to adversaries while maintaining operational requirements.

---

## Phase 1 — Domain Ownership & Governance

### ☐ Domain Inventory Accuracy

* ☐ All registered domains are documented
* ☐ Business ownership for each domain is defined
* ☐ No orphaned or forgotten domains exist
* ☐ Test, dev, and staging domains are tracked
* ☐ Domain purpose is clearly defined (prod, marketing, internal)

**Risk if unchecked:** Attackers discover unmanaged or abandoned assets.

---

### ☐ Registrar Selection & Centralization

* ☐ Domains registered with approved registrars only
* ☐ Registrar accounts centrally managed
* ☐ MFA enabled on registrar accounts
* ☐ Registrar permissions restricted by role
* ☐ No individual-owned registrar accounts

**Risk if unchecked:** Domain hijacking and unauthorized DNS changes.

---

## Phase 2 — Registrant & Contact Information Exposure

### ☐ Registrant Data Review

* ☐ Organization name is accurate and consistent
* ☐ No internal system names disclosed
* ☐ No project or environment identifiers exposed
* ☐ No personal names unnecessarily disclosed

**Risk if unchecked:** Organizational mapping and targeting.

---

### ☐ Administrative & Technical Contacts

* ☐ No personal email addresses exposed
* ☐ Generic role-based emails used (e.g., dns@, admin@)
* ☐ Contact emails not reused for authentication elsewhere
* ☐ Phone numbers do not route to individuals directly

**Risk if unchecked:** Phishing, vishing, and identity-based attacks.

---

### ☐ Privacy & Proxy Services

* ☐ WHOIS privacy enabled where appropriate
* ☐ Proxy service verified as reputable
* ☐ Privacy coverage reviewed for all TLDs
* ☐ Exceptions documented where privacy cannot be used

**Risk if unchecked:** Direct leakage of sensitive administrative data.

---

## Phase 3 — Infrastructure & DNS Intelligence Leakage

### ☐ Name Server Exposure

* ☐ Name servers do not disclose internal naming schemes
* ☐ No environment indicators (dev, test, prod) exposed
* ☐ No legacy or decommissioned name servers listed
* ☐ Third-party DNS providers approved and documented

**Risk if unchecked:** Infrastructure mapping and environment inference.

---

### ☐ Hosting & Provider Attribution

* ☐ Registrar and DNS providers aligned with security policy
* ☐ Cloud provider usage intentionally disclosed
* ☐ No accidental exposure of internal hosting providers
* ☐ Infrastructure ownership clearly defined

**Risk if unchecked:** Targeted attacks based on provider-specific weaknesses.

---

## Phase 4 — Temporal & Lifecycle Exposure

### ☐ Domain Age & Registration Patterns

* ☐ Newly registered domains reviewed for security posture
* ☐ Short-lived domains flagged for review
* ☐ Registration dates align with business timelines
* ☐ Rapid domain churn investigated

**Risk if unchecked:** Abuse of hastily deployed or weakly governed assets.

---

### ☐ Expiration & Renewal Management

* ☐ Auto-renew enabled on all domains
* ☐ Expiration alerts monitored
* ☐ Renewal responsibility assigned
* ☐ No domains nearing expiration without owner approval

**Risk if unchecked:** Domain takeover and impersonation attacks.

---

## Phase 5 — Historical WHOIS Intelligence

### ☐ Historical WHOIS Review

* ☐ Ownership changes documented
* ☐ Registrar migrations reviewed
* ☐ DNS infrastructure changes tracked
* ☐ Rebranding or mergers reflected accurately

**Risk if unchecked:** Legacy exposure and forgotten infrastructure.

---

## Phase 6 — Correlation With Other Recon Sources

### ☐ Cross-Validation

* ☐ WHOIS data correlated with DNS records
* ☐ Certificate transparency logs reviewed
* ☐ Public documentation aligned with WHOIS
* ☐ Search engine results checked for inconsistencies

**Risk if unchecked:** Attackers correlating mismatches you missed.

---

## Phase 7 — Monitoring & Continuous Assurance

### ☐ WHOIS Change Monitoring

* ☐ Automated alerts for WHOIS changes enabled
* ☐ Registrar change notifications monitored
* ☐ Unexpected updates investigated immediately

**Risk if unchecked:** Silent domain takeover or configuration drift.

---

### ☐ Periodic Review Cadence

* ☐ WHOIS exposure reviewed quarterly
* ☐ Reviews triggered by:

  * New domain registrations
  * Mergers/acquisitions
  * Cloud migrations
* ☐ Findings tracked to remediation

**Risk if unchecked:** Exposure accumulates silently over time.

---

## Severity Guidance

| Finding                        | Typical Severity |
| ------------------------------ | ---------------- |
| Personal contact info exposed  | High             |
| Orphaned domain                | Critical         |
| Internal naming in NS records  | High             |
| No WHOIS privacy               | Medium           |
| Domain near expiration         | Critical         |
| Decentralized registrar access | High             |

---

## Executive Summary Statement (Reusable)

> WHOIS data does not expose vulnerabilities directly, but it provides attackers with organizational context, infrastructure clues, and human targets. Reducing WHOIS exposure limits attacker precision and increases the cost of reconnaissance.

---

## Blue-Team Quick Reference (TL;DR)

* WHOIS leaks context, not exploits
* Context enables precision
* Precision enables compromise
* Centralize ownership
* Minimize human exposure
* Monitor for changes

