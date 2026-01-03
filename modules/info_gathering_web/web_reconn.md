# Web Reconnaissance – Introduction

Web reconnaissance is the foundation of any thorough security assessment. It is the systematic process of collecting information about a target website or web application before deeper analysis or exploitation begins. Within the Penetration Testing Process, reconnaissance sits squarely in the **Information Gathering** phase and directly influences the success of every phase that follows.

A typical penetration testing lifecycle includes:

**Pre-Engagement → Information Gathering → Vulnerability Assessment → Exploitation → Post-Exploitation → Lateral Movement → Proof-of-Concept → Post-Engagement**

Reconnaissance establishes situational awareness. Without it, subsequent testing is unfocused, inefficient, and prone to missing critical attack paths.

---

## Objectives of Web Reconnaissance

The primary goals of web reconnaissance are as follows:

### Identifying Assets

Reconnaissance seeks to enumerate all publicly accessible components of the target environment. This includes domains, subdomains, IP addresses, web applications, APIs, and underlying technologies. A complete asset inventory provides visibility into the true scope of the target’s online footprint.

### Discovering Exposed or Hidden Information

Misconfigurations and operational oversights frequently lead to unintended data exposure. Reconnaissance aims to identify backup files, configuration files, staging environments, development artifacts, and internal documentation that may be accessible from the internet. These artifacts often reveal sensitive details such as credentials, internal paths, or architectural decisions.

### Analysing the Attack Surface

By understanding which services, frameworks, and technologies are in use, testers can evaluate the size and complexity of the attack surface. This enables targeted testing against known weakness classes, insecure defaults, and historically vulnerable components.

### Gathering Intelligence

Reconnaissance also supports intelligence collection that may be useful beyond purely technical exploitation. Information about organisational structure, employee roles, naming conventions, and behavioural patterns can inform social engineering or credential-based attacks.

From an attacker’s perspective, reconnaissance enables precision. From a defender’s perspective, it highlights exposure before it is abused. In both cases, reconnaissance is the decisive factor that separates opportunistic attacks from deliberate, effective ones.

---

## Types of Web Reconnaissance

Web reconnaissance is generally divided into two complementary methodologies: **active reconnaissance** and **passive reconnaissance**. Each has distinct advantages, limitations, and detection risks.

---

## Active Reconnaissance

Active reconnaissance involves **direct interaction** with the target system. The tester sends requests, probes services, and observes responses in order to gather information.

Because these actions generate traffic that reaches the target infrastructure, they carry an inherent risk of detection.

### Common Active Reconnaissance Techniques

| Technique              | Description                                            | Example                                   | Tools                         | Detection Risk |
| ---------------------- | ------------------------------------------------------ | ----------------------------------------- | ----------------------------- | -------------- |
| Port Scanning          | Identifies open ports and listening services           | Scanning ports 80 and 443 on a web server | Nmap, Masscan, Unicornscan    | High           |
| Vulnerability Scanning | Probes for known vulnerabilities and misconfigurations | Scanning for XSS or SQL injection         | Nessus, OpenVAS, Nikto        | High           |
| Network Mapping        | Identifies network paths and topology                  | Tracing hops to a target server           | traceroute, Nmap              | Medium–High    |
| Banner Grabbing        | Extracts service information from response headers     | Inspecting HTTP server headers            | Netcat, curl                  | Low            |
| OS Fingerprinting      | Determines the underlying operating system             | Using Nmap OS detection                   | Nmap, Xprobe2                 | Low            |
| Service Enumeration    | Identifies service versions                            | Detecting Apache or Nginx versions        | Nmap (-sV)                    | Low            |
| Web Spidering          | Crawls web applications for content discovery          | Mapping site structure                    | Burp Suite, OWASP ZAP, Scrapy | Low–Medium     |

Active reconnaissance typically yields **more accurate and comprehensive results**, but excessive or poorly tuned scanning can trigger intrusion detection systems, web application firewalls, or rate-limiting controls.

---

## Passive Reconnaissance

Passive reconnaissance gathers information **without direct interaction** with the target system. It relies on publicly available data sources and third-party services.

Because no traffic is sent directly to the target, passive reconnaissance is significantly stealthier.

### Common Passive Reconnaissance Techniques

| Technique                | Description                            | Example                        | Tools                        | Detection Risk |
| ------------------------ | -------------------------------------- | ------------------------------ | ---------------------------- | -------------- |
| Search Engine Queries    | Extracts publicly indexed information  | Searching for employee data    | Google, DuckDuckGo, Bing     | Very Low       |
| WHOIS Lookups            | Retrieves domain registration metadata | Identifying registrant details | whois, online WHOIS services | Very Low       |
| DNS Analysis             | Enumerates domains and infrastructure  | Discovering subdomains         | dig, dnsenum, dnsrecon       | Very Low       |
| Web Archive Analysis     | Reviews historical site versions       | Inspecting legacy pages        | Wayback Machine              | Very Low       |
| Social Media Analysis    | Gathers organisational intelligence    | Profiling employees            | LinkedIn, Twitter            | Very Low       |
| Code Repository Analysis | Identifies exposed code or secrets     | Searching public repositories  | GitHub, GitLab               | Very Low       |

Passive reconnaissance is ideal for early-stage intelligence gathering and stealth operations. However, it is limited to information that has already been exposed or indexed.

---

## Reconnaissance Strategy Considerations

Effective reconnaissance blends both approaches:

* **Passive reconnaissance** establishes baseline intelligence with minimal risk.
* **Active reconnaissance** validates findings and fills information gaps.
* Tool configuration, timing, and scope discipline determine whether recon is noisy or discreet.

A methodical approach ensures that reconnaissance informs exploitation rather than prematurely revealing intent.

---

## Module Focus

This module begins with **WHOIS analysis**, a core passive reconnaissance technique. Understanding WHOIS provides insight into domain ownership, registration history, and infrastructure relationships. These details often reveal organisational boundaries, third-party dependencies, and potential pivot points that influence later phases of testing.

As the module progresses, more advanced reconnaissance techniques will build upon this foundation.

---

# Red Team Playbook: Web Reconnaissance

## Mission Objective

Systematically identify and map a target’s **web-facing attack surface** in order to:

* Discover exposed assets and technologies
* Identify weak points and misconfigurations
* Generate actionable paths for exploitation
* Minimize noise and detection where possible

Reconnaissance is not about exploiting systems—it is about **understanding them well enough that exploitation becomes inevitable**.

---

## Phase 0 — Rules of Engagement Awareness

Before reconnaissance begins, confirm:

* Authorized scope (domains, IP ranges, cloud assets)
* Allowed techniques (active vs passive)
* Detection tolerance (stealth vs noisy)
* Time restrictions

**Failure to scope recon properly is an operational failure, not a technical one.**

---

## Phase 1 — Passive Reconnaissance (Baseline Intelligence)

**Goal:** Build an initial intelligence picture without touching the target infrastructure.

### 1.1 Domain & Ownership Intelligence

* Identify:

  * Registered domains
  * Parent organizations
  * Name servers
  * Third-party providers

**Outcome:**
Understanding organizational boundaries and external dependencies.

---

### 1.2 DNS Enumeration (Passive)

* Collect:

  * Known subdomains
  * Mail servers
  * CDN usage
  * Cloud hosting indicators

Focus on:

* `dev`, `test`, `staging`, `api`, `admin`, `vpn`
* Legacy or deprecated subdomains

**Outcome:**
Preliminary attack surface expansion.

---

### 1.3 Search Engine & Index Recon

Use search engines to identify:

* Publicly indexed files (PDF, DOCX, XLSX)
* Error messages
* Configuration leaks
* Forgotten endpoints

Examples of interest:

* Backup files
* Stack traces
* Directory listings
* Administrative portals

**Outcome:**
Discovery of exposed information without direct interaction.

---

### 1.4 Open-Source Intelligence (OSINT)

Collect:

* Employee names and roles
* Email formats
* Technology mentions
* Development workflows

Sources:

* LinkedIn
* GitHub / GitLab
* Job postings
* Technical blogs

**Outcome:**
Human and technical context that informs later exploitation and social engineering.

---

## Phase 2 — Passive Infrastructure Analysis

### 2.1 Historical Web Analysis

* Review archived versions of:

  * Websites
  * Login portals
  * APIs
  * Deprecated functionality

Look for:

* Removed authentication checks
* Hardcoded credentials
* Legacy endpoints

**Outcome:**
Identification of attack paths that no longer appear in the live application.

---

### 2.2 Public Code & Secrets Exposure

Search for:

* API keys
* Tokens
* Hardcoded credentials
* Configuration files

Pay attention to:

* `.env` files
* CI/CD pipelines
* Sample code

**Outcome:**
Potential direct authentication bypass or privilege escalation paths.

---

## Phase 3 — Transition to Active Reconnaissance

**Decision Point:**
Move to active recon **only when passive sources plateau**.

---

## Phase 4 — Active Reconnaissance (Controlled Interaction)

### 4.1 Asset Validation

Confirm:

* Live subdomains
* Responsive hosts
* Web services in scope

Avoid:

* Broad, high-speed scanning initially
* Unnecessary protocol probing

**Outcome:**
Verified list of live targets.

---

### 4.2 Service & Technology Fingerprinting

Identify:

* Web servers (Apache, Nginx, IIS)
* Frameworks (Django, Laravel, ASP.NET)
* CMS platforms
* Third-party services

Focus on:

* Version disclosure
* Misconfigured headers
* Debug endpoints

**Outcome:**
Technology stack mapping for vulnerability prioritization.

---

### 4.3 Directory & Endpoint Discovery

Enumerate:

* Hidden directories
* APIs
* Administrative paths

Prioritize:

* Authenticated vs unauthenticated endpoints
* Upload functionality
* Export/download features

**Outcome:**
Expanded attack surface with concrete entry points.

---

### 4.4 Application Mapping (Spidering)

Crawl:

* Pages
* Forms
* Parameters
* State transitions

Configure crawlers to:

* Respect session handling
* Avoid aggressive rate patterns
* Mimic legitimate browsers

**Outcome:**
Functional understanding of application logic.

---

## Phase 5 — Attack Surface Analysis

### 5.1 Input Vector Identification

Identify:

* User-controllable parameters
* File uploads
* API inputs
* Headers and cookies

Categorize:

* Authentication-dependent
* Publicly accessible
* Privileged-only

**Outcome:**
Clear list of candidate injection and logic flaw targets.

---

### 5.2 Trust Boundary Mapping

Determine:

* Where authentication begins
* Where authorization is enforced
* Where assumptions are made

Look for:

* IDOR potential
* Role confusion
* Inconsistent access control

**Outcome:**
Prioritized exploitation hypotheses.

---

## Phase 6 — Recon-to-Exploit Handoff

Deliverables to exploitation phase:

* Validated targets
* Confirmed technologies
* Known weak points
* Potential credential sources
* High-value endpoints

Recon is complete when:

* Further discovery yields diminishing returns
* Exploitation paths are clearly defined

---

## Operational Security (OPSEC) Notes

* Passive recon is preferred early
* Rotate IPs only if required
* Avoid signature-heavy tools early
* Blend in with legitimate traffic patterns
* Log every discovery with source attribution

---

## Common Red Team Mistakes

* Scanning too early
* Ignoring archived content
* Overlooking human intelligence
* Treating recon as a checklist instead of analysis
* Failing to correlate findings

---

## Success Criteria

Reconnaissance is successful when you can confidently answer:

* What exists?
* How does it work?
* Where does it trust input?
* Where is it weakest?
* How can access realistically be gained?

---

## Operator Summary (TL;DR)

1. Map the surface quietly
2. Expand scope intelligently
3. Validate only what matters
4. Stop when exploitation is obvious

---

Below is a **Blue-Team Web Exposure Assessment Checklist**, designed for **defensive security teams, SOC analysts, risk assessors, and auditors**. It is written as a **practical, repeatable checklist** that can be used during continuous monitoring, pre-engagement reviews, purple-team exercises, or compliance assessments.

This checklist mirrors real attacker reconnaissance behavior and answers one core question:

**“What can an attacker learn about us without logging in?”**

---

# Blue-Team Web Exposure Assessment Checklist

## Purpose

To systematically identify **externally visible exposure**, **information leakage**, and **attack surface risks** across web-facing assets before they are leveraged by adversaries.

---

## Phase 1 — Asset Inventory & Scope Validation

### ☐ Domain & Subdomain Awareness

* ☐ All registered domains documented
* ☐ All subdomains enumerated and reviewed
* ☐ Deprecated or legacy domains identified
* ☐ Typosquatting variants assessed
* ☐ Unused domains decommissioned or parked securely

**Risk if unchecked:** Shadow assets become unmonitored entry points.

---

### ☐ IP & Hosting Visibility

* ☐ Public IP ranges documented
* ☐ Cloud provider usage identified
* ☐ CDN usage confirmed and configured correctly
* ☐ Direct-to-origin access restricted (where applicable)

**Risk if unchecked:** Bypass of WAF/CDN protections.

---

## Phase 2 — DNS & Infrastructure Exposure

### ☐ DNS Configuration Review

* ☐ No unintended zone transfers allowed
* ☐ Internal hostnames not exposed externally
* ☐ Mail servers hardened and necessary only
* ☐ TXT records reviewed for sensitive data
* ☐ SPF/DKIM/DMARC configured correctly

**Risk if unchecked:** Infrastructure mapping and spoofing opportunities.

---

### ☐ TLS & Certificate Hygiene

* ☐ Valid, trusted certificates in use
* ☐ No expired or self-signed certs on public assets
* ☐ Certificate SAN entries reviewed
* ☐ Weak ciphers disabled
* ☐ TLS versions enforced (TLS 1.2+)

**Risk if unchecked:** MITM opportunities and trust erosion.

---

## Phase 3 — Web Application Surface

### ☐ Technology Fingerprinting Exposure

* ☐ Server banners minimized or removed
* ☐ Framework versions not disclosed
* ☐ Debug headers disabled
* ☐ Stack traces suppressed in production

**Risk if unchecked:** Targeted exploitation via version-specific vulnerabilities.

---

### ☐ Directory & Endpoint Exposure

* ☐ No directory listings enabled
* ☐ No backup files accessible (.bak, .old, .zip)
* ☐ No configuration files exposed
* ☐ Admin panels restricted
* ☐ API endpoints inventoried and secured

**Risk if unchecked:** Direct access to sensitive functionality.

---

### ☐ Authentication Boundary Review

* ☐ Login pages identified and monitored
* ☐ MFA enforced where possible
* ☐ No alternate authentication paths exposed
* ☐ Error messages do not disclose auth logic
* ☐ Rate limiting enabled

**Risk if unchecked:** Credential attacks and authentication bypass.

---

## Phase 4 — Content & Data Exposure

### ☐ Public File Exposure

* ☐ PDFs and documents reviewed for metadata
* ☐ Internal usernames or paths scrubbed
* ☐ Source maps not publicly accessible
* ☐ Upload directories protected

**Risk if unchecked:** Intelligence leakage and lateral movement clues.

---

### ☐ Web Archive Review

* ☐ Historical versions reviewed
* ☐ Deprecated endpoints identified
* ☐ Legacy login pages disabled
* ☐ Old APIs decommissioned

**Risk if unchecked:** Attackers exploiting functionality you forgot existed.

---

## Phase 5 — Third-Party & Supply Chain Exposure

### ☐ External Dependencies

* ☐ Third-party scripts reviewed
* ☐ CDN libraries up to date
* ☐ External APIs scoped and secured
* ☐ OAuth integrations audited

**Risk if unchecked:** Indirect compromise via trusted services.

---

### ☐ Code Repository Exposure

* ☐ Public repos searched for secrets
* ☐ CI/CD configs reviewed
* ☐ Environment files never committed
* ☐ Access tokens rotated if exposed

**Risk if unchecked:** Credential theft without touching your infrastructure.

---

## Phase 6 — Logging, Monitoring & Detection

### ☐ Reconnaissance Detection

* ☐ Web access logs retained
* ☐ Alerting on:

  * Unusual crawling behavior
  * Directory brute-forcing
  * Parameter fuzzing
* ☐ User-agent anomalies flagged

**Risk if unchecked:** Silent mapping of your environment.

---

### ☐ WAF & Edge Protections

* ☐ WAF enabled and tuned
* ☐ Rate limits enforced
* ☐ Bot detection enabled
* ☐ False positives reviewed regularly

**Risk if unchecked:** Unimpeded reconnaissance and exploitation.

---

## Phase 7 — Governance & Continuous Improvement

### ☐ Ownership & Accountability

* ☐ Asset owners assigned
* ☐ Exposure reviews scheduled
* ☐ Findings tracked to remediation
* ☐ Risk accepted explicitly when applicable

**Risk if unchecked:** Known exposure becomes institutional blind spot.

---

### ☐ Testing & Validation

* ☐ Regular external attack surface scans
* ☐ Purple-team validation exercises
* ☐ Recon simulation performed quarterly
* ☐ Incident response plans tested

**Risk if unchecked:** Controls exist only on paper.

---

## Severity Guidance

| Finding Type        | Typical Severity |
| ------------------- | ---------------- |
| Forgotten subdomain | High             |
| Public backup files | Critical         |
| Version disclosure  | Medium           |
| Open admin panels   | Critical         |
| Metadata leakage    | Medium           |
| No recon detection  | High             |

---

## Executive Summary Statement (Reusable)

> External exposure is not defined by vulnerabilities alone, but by what an attacker can learn without authentication. Continuous exposure assessment is essential to reducing both attack success and dwell time.

---

## Blue-Team Quick Reference (TL;DR)

* If it’s public, it’s mapped
* If it’s forgotten, it’s targeted
* If it’s verbose, it’s weaponized
* If it’s unmonitored, it’s abused
* Recon is not hypothetical—it’s constant
