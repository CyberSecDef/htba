# Technical Report: Web Application Fingerprinting

## 1. Executive Summary

Fingerprinting is a foundational web-reconnaissance discipline focused on identifying the **technologies, software versions, frameworks, and defensive controls** that underpin a web application. Much like a biological fingerprint, a technology stack leaves distinctive indicators—headers, banners, behaviors, and artifacts—that enable attackers to tailor exploits with precision.

Effective fingerprinting transforms blind probing into **targeted exploitation**, reduces noise, and dramatically increases success rates by aligning attacks with known vulnerabilities in identified technologies.

---

## 2. Why Fingerprinting Matters

Fingerprinting plays a central role in reconnaissance for four core reasons:

### 2.1 Targeted Attacks

Knowing exact technologies (e.g., Apache 2.4.41, WordPress) allows attackers to:

* Focus on relevant CVEs
* Skip incompatible exploit paths
* Optimize exploit chains

### 2.2 Identifying Misconfigurations

Fingerprinting often exposes:

* Outdated software
* Missing security headers
* Default configurations
* Information disclosure issues

### 2.3 Prioritisation of Targets

When multiple assets are discovered, fingerprinting helps rank them by:

* Age of software
* Known exploitability
* Defensive maturity

### 2.4 Building a Comprehensive Profile

Fingerprinting complements:

* DNS enumeration
* Subdomain discovery
* VHost discovery

Together, these techniques form a **holistic infrastructure profile**.

---

## 3. Fingerprinting Techniques

Fingerprinting relies on both **passive** and **active** methods.

### 3.1 Banner Grabbing

Banner grabbing inspects service responses for identifying information such as:

* Server software
* Version numbers
* Operating system indicators

Example technique:

* HTTP HEAD requests
* TLS handshake metadata

---

### 3.2 HTTP Header Analysis

HTTP response headers frequently reveal:

* `Server` → web server and OS
* `X-Powered-By` → application framework
* Redirect behaviors → backend logic
* Security headers → defensive posture

Headers are often overlooked yet highly revealing.

---

### 3.3 Probing for Specific Responses

Certain servers respond uniquely to:

* Invalid HTTP methods
* Malformed requests
* Special paths

These behaviors act as **behavioral fingerprints**.

---

### 3.4 Page Content Analysis

Page structure and content may disclose:

* CMS usage
* Framework signatures
* API endpoints
* Licensing files

Artifacts such as `/license.txt` or `/wp-json/` are strong indicators.

---

## 4. Automated Fingerprinting Tools

| Tool       | Primary Purpose      | Notable Capabilities         |
| ---------- | -------------------- | ---------------------------- |
| Wappalyzer | Technology profiling | CMS, frameworks, analytics   |
| BuiltWith  | Tech stack analysis  | Detailed historical data     |
| WhatWeb    | CLI fingerprinting   | Signature-based detection    |
| Nmap       | Network & service ID | NSE scripts, OS detection    |
| Netcraft   | Web profiling        | Hosting & security posture   |
| wafw00f    | WAF detection        | Identifies WAF type & vendor |

Each tool provides a different vantage point; using multiple tools reduces false assumptions.

---

## 5. Fingerprinting inlanefreight.com (Case Study)

### 5.1 Banner Grabbing with curl

#### Initial HTTP Headers

```bash
curl -I inlanefreight.com
```

Key findings:

* Apache/2.4.41
* Ubuntu OS
* HTTP → HTTPS redirection

---

#### HTTPS Redirection Analysis

```bash
curl -I https://inlanefreight.com
```

New indicator:

* `X-Redirect-By: WordPress`

This strongly suggests WordPress is controlling routing logic.

---

#### Final Destination Headers

```bash
curl -I https://www.inlanefreight.com
```

Notable indicators:

* `wp-json` API endpoint
* Multiple WordPress-specific headers
* Confirmed Apache backend

---

## 6. Web Application Firewall Detection (wafw00f)

### Purpose

Detecting a WAF early is critical, as it:

* Alters attack feasibility
* Impacts scanning reliability
* Requires evasion techniques

---

### Installation

```bash
pip3 install git+https://github.com/EnableSecurity/wafw00f
```

---

### Detection Result

```bash
wafw00f inlanefreight.com
```

Finding:

* **Wordfence (Defiant) WAF detected**

Implication:

* Aggressive probing may be blocked
* Payloads may require obfuscation
* Rate limiting is likely enforced

---

## 7. Advanced Fingerprinting with Nikto

### Purpose

Nikto provides:

* Software identification
* Header analysis
* Configuration issues
* CMS detection

---

### Running Fingerprint-Only Scan

```bash
nikto -h inlanefreight.com -Tuning b
```

---

### Key Findings

#### Infrastructure

* IPv4 and IPv6 enabled
* Apache/2.4.41 (Ubuntu)

#### CMS

* WordPress installation confirmed
* `/wp-login.php` exposed

#### Security Weaknesses

* Missing `Strict-Transport-Security`
* Missing `X-Content-Type-Options`
* Deprecated headers
* Potential BREACH exposure
* Outdated Apache version
* Cookie flags misconfigured

These findings indicate **realistic exploitation paths**.

---

## 8. Operational Takeaways

Fingerprinting revealed:

* Precise server software and version
* CMS and administrative endpoints
* Defensive controls (WAF)
* Misconfigurations and outdated components

This intelligence directly informs **exploit selection and sequencing**.

---

# Red Team Playbook: Web Fingerprinting

## Objective

Identify technologies, versions, and defensive controls to enable targeted exploitation.

---

## Phase 1: Passive Identification

### Actions

* Inspect HTTP headers
* Analyze redirects
* Review TLS metadata

### Tools

* `curl`
* Browser dev tools

---

## Phase 2: Automated Profiling

### Tools

* `WhatWeb`
* `Wappalyzer`
* `BuiltWith`

---

## Phase 3: Defensive Control Detection

### Actions

* Detect WAF presence
* Identify filtering behavior

### Tools

* `wafw00f`

---

## Phase 4: Vulnerability Alignment

### Actions

* Match versions to CVEs
* Identify CMS attack surface
* Locate admin endpoints

---

## OPSEC Notes

* Fingerprinting is low-noise
* Excessive probing triggers WAFs
* Prefer headers over payloads initially

---

# Blue Team Playbook: Defending Against Fingerprinting

## Threat Summary

Fingerprinting enables:

* Targeted exploitation
* Reduced attacker noise
* Faster compromise

Attackers who fingerprint accurately **fail less often**.

---

## Defensive Controls

### Reduce Information Disclosure

* Remove or mask `Server` headers
* Disable `X-Powered-By`
* Avoid framework-specific redirects

---

### Harden Headers

* Enable HSTS
* Set secure cookie flags
* Implement modern CSP

---

### Patch Management

* Keep web servers up to date
* Remove unused files (`license.txt`)
* Harden CMS installations

---

## Monitoring & Detection

### Indicators

* Repeated HEAD requests
* Method probing
* WAF fingerprinting signatures

---

## Incident Response Workflow

1. Detect reconnaissance patterns
2. Correlate with DNS and HTTP logs
3. Rate-limit or block source
4. Audit exposed endpoints
5. Review configuration hygiene

---

## Defensive Takeaway

Fingerprinting succeeds because **systems talk too much**.

The quieter and more uniform your responses, the harder it is for attackers to tailor their attacks.

