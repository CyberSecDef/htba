# Technical Report: Domain Information Gathering and Passive Reconnaissance (OSINT)

## 1. Purpose of Domain Information Gathering

Domain information collection is a **foundational phase of any penetration test**, especially in black-box scenarios. It is not limited to discovering subdomains; rather, it seeks to understand the **entire external footprint of an organization** on the Internet.

The primary objectives are to:

* Understand how the company operates
* Identify externally exposed infrastructure
* Infer internal technologies, platforms, and workflows
* Map relationships between services, vendors, and systems

This phase is **passive**, meaning:

* No direct interaction with target systems
* No active scanning
* No traffic sent directly to company-owned hosts

Remaining passive minimizes detection and mirrors how an attacker would operate as a normal visitor or customer.

---

## 2. Passive Reconnaissance Philosophy

The document emphasizes two key enumeration principles:

1. **Observe what is visible**
2. **Infer what must exist but is not visible**

Services presented publicly (e.g., IoT platforms, app development, hosting, analytics) **require specific backend technologies**, even if those technologies are not directly advertised. By thinking like a developer or systems architect, one can infer:

* Supporting infrastructure
* Third-party dependencies
* Likely authentication mechanisms
* Administrative interfaces

This mindset transforms passive reconnaissance from simple data collection into **technical inference**.

---

## 3. Initial Recon: Company Website Analysis

The company’s main website is the first and most valuable OSINT source.

Key activities include:

* Reading service descriptions carefully
* Identifying technology hints (analytics, portals, APIs)
* Noting what is missing (e.g., no login page, no API docs)
* Mapping business functions to technical requirements

For example:

* IoT services imply device management portals
* Data science offerings imply dashboards and storage
* IT security services imply internal tooling and admin panels

This analysis informs **where to search next** and **what technologies to expect**.

---

## 4. SSL Certificates as a Reconnaissance Source

SSL/TLS certificates provide **high-value passive intelligence**.

Certificates often include:

* Multiple DNS names (SANs)
* Validity periods
* Organizational details

In the example, a single certificate covered:

* `inlanefreight.htb`
* `www.inlanefreight.htb`
* `support.inlanefreight.htb`

This immediately reveals **additional active subdomains** without touching the target directly.

---

## 5. Certificate Transparency and crt.sh

### 5.1 Certificate Transparency Overview

Certificate Transparency (RFC 6962) requires certificate authorities to log all issued certificates in publicly auditable logs. This enables detection of:

* Misissued certificates
* Rogue certificates
* Shadow infrastructure

### 5.2 Using crt.sh

The service **crt.sh** exposes these logs publicly.

By querying a domain, one can discover:

* Historical subdomains
* Forgotten services
* Staging and preview environments
* Internal tooling exposed temporarily

The document demonstrates:

* Web-based queries
* JSON output
* Automated parsing using `curl`, `jq`, `grep`, and `awk`

This approach produces a **clean, deduplicated subdomain list** suitable for further analysis.

---

## 6. Subdomain Enumeration and Filtering

After collecting certificate data, results are:

* Normalized
* Deduplicated
* Filtered to isolate unique subdomains

This step is critical to:

* Reduce noise
* Avoid duplicate effort
* Focus only on potentially active services

Wildcard entries (`*.domain.com`) are noted but treated carefully, as they do not guarantee actual hosts.

---

## 7. Identifying Company-Hosted vs Third-Party Systems

Not all discovered subdomains are fair game in a penetration test.

The document correctly distinguishes between:

* **Company-hosted systems** (in scope)
* **Third-party hosted systems** (often out of scope)

Using DNS resolution (`host` command), the tester identifies:

* Subdomains resolving to internal IP ranges
* Infrastructure likely owned and operated by the company

This step is essential for:

* Legal compliance
* Ethical testing
* Scope enforcement

---

## 8. IP Address Consolidation

Resolved IP addresses are:

* Collected into a list
* Deduplicated
* Prepared for further passive analysis

This allows correlation across tools and data sources without touching the target infrastructure directly.

---

## 9. Shodan as an OSINT Amplifier

### 9.1 Shodan Overview

Shodan is a search engine for Internet-connected devices. It continuously scans the Internet for:

* Open ports
* Service banners
* TLS configurations
* Device types

### 9.2 Shodan Host Analysis

By querying Shodan with known IP addresses, the tester learns:

* Open ports
* Running services
* Software versions
* TLS protocol support
* Cryptographic parameters
* Geographic location

This provides **near-active reconnaissance results without sending traffic**.

---

## 10. Service Inference from Shodan Results

From Shodan output, the tester can infer:

* Web server types (Apache, nginx)
* SSH exposure
* Mail server presence
* DNS services
* Legacy protocols

TLS details such as:

* Disabled SSL/TLS versions
* Diffie-Hellman parameters
* Cipher strength

help assess **cryptographic posture** before any active testing.

---

## 11. Target Prioritization

The document highlights identifying **interesting hosts** (e.g., analytics platforms like Matomo) for later active investigation.

This prioritization is based on:

* Service complexity
* Likelihood of sensitive data
* Historical misconfiguration patterns

Passive recon directly informs **attack surface prioritization**.

---

## 12. DNS Record Enumeration

Using `dig any`, the tester retrieves all publicly visible DNS records.

### 12.1 Record Types Observed

* **A records** – IP mappings
* **MX records** – Email providers
* **NS records** – DNS hosting providers
* **TXT records** – Verification tokens and security policies
* **SOA records** – Domain authority metadata

Each record type reveals **different layers of organizational structure**.

---

## 13. TXT Records as an Intelligence Goldmine

TXT records frequently expose:

* Third-party service usage
* Cloud providers
* Collaboration platforms
* Email infrastructure
* Internal IP ranges
* Verification identifiers

In this case, TXT records revealed usage of:

* Atlassian
* Google (Gmail, site verification)
* LogMeIn
* Mailgun
* Microsoft services (Outlook, Office 365)
* INWX (domain registrar)
* Internal IP addresses

---

## 14. Third-Party Platform Inference

Each discovered provider implies **additional attack surface**:

### Atlassian

* Jira, Confluence, Bitbucket
* Potential exposed project data
* User enumeration opportunities

### Google Workspace

* Shared Drive links
* Public documents
* OAuth integrations

### LogMeIn

* Centralized remote access
* High-value target if credentials are reused

### Mailgun

* API endpoints
* Webhooks
* Potential SSRF or IDOR vectors

### Microsoft / Outlook / Azure

* Office 365
* OneDrive
* Azure Blob and File Storage
* SMB-accessible cloud shares

### INWX

* Domain management platform
* TXT “MS” values may correlate to account identifiers

---

## 15. Internal IP Disclosure via DNS

The SPF record exposes **internal IP addresses**, which:

* Reveal network segmentation
* Indicate internal mail relays
* Assist later pivoting or trust-boundary analysis

Even without scanning, this provides **valuable internal network insight**.

---

## 16. Reconnaissance Outcome Summary

By remaining fully passive, the tester achieves:

* Subdomain discovery
* IP address identification
* Hosting provider attribution
* Service fingerprinting
* Technology stack inference
* Third-party dependency mapping
* Attack surface prioritization

All without triggering alarms.

---

## 17. Strategic Value of Passive Domain Recon

The document reinforces a critical lesson:

> Effective attacks are rarely loud at the beginning.

Domain information gathering:

* Shapes the entire engagement
* Prevents wasted effort
* Identifies high-value targets early
* Enables precise, informed active testing later

This phase transforms a black-box test into an **educated, targeted operation**.

---

## 18. Conclusion

Domain information gathering through passive OSINT is not a preliminary chore—it is a **strategic intelligence operation**. By combining certificate transparency, DNS analysis, Shodan data, and technical inference, a tester can reconstruct a detailed picture of an organization’s external and semi-internal architecture.

The document demonstrates that **what a company exposes unintentionally often matters more than what it advertises intentionally** .
