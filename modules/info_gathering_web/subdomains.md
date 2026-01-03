# Technical Report: Subdomains in Web Reconnaissance

## 1. Executive Summary

Subdomains represent one of the most fertile attack surfaces during web reconnaissance. While primary domains often receive the most security attention, subdomains frequently host auxiliary services such as development environments, legacy applications, administrative portals, and internal tooling. These assets are often less monitored, less hardened, and more likely to expose sensitive functionality.

Effective subdomain enumeration dramatically expands the scope of a penetration test and frequently identifies the **initial foothold** into an otherwise well-defended organization.

---

## 2. Understanding Subdomains

A subdomain is a DNS label that exists beneath a parent domain and is typically used to logically separate services or environments. Examples include:

* `blog.example.com`
* `shop.example.com`
* `mail.example.com`

From a DNS standpoint, subdomains are implemented through:

* **A / AAAA records** mapping the subdomain to an IP address
* **CNAME records** aliasing the subdomain to another hostname

While conceptually simple, subdomains often reflect internal organizational structure and operational decisions.

---

## 3. Why Subdomains Matter for Web Recon

Subdomains are rarely just cosmetic. They frequently reveal:

### Development and Staging Environments

Organizations often deploy:

* `dev.example.com`
* `staging.example.com`
* `test.example.com`

These environments may:

* Run older code
* Lack authentication
* Expose debug interfaces
* Contain hard-coded credentials or API keys

### Hidden Login Portals

Administrative interfaces are commonly placed on subdomains to reduce visibility:

* `admin.example.com`
* `portal.example.com`
* `vpn.example.com`

Security by obscurity is not security—enumeration defeats it quickly.

### Legacy Applications

Forgotten or deprecated services may still resolve in DNS:

* Old CMS platforms
* Abandoned internal tools
* Unsupported frameworks with known CVEs

### Sensitive Information Exposure

Subdomains may host:

* Configuration files
* Backup archives
* Internal documentation
* Test data mirroring production systems

From an attacker’s perspective, subdomains often offer **lower resistance with higher payoff**.

---

## 4. Subdomain Enumeration Overview

Subdomain enumeration is the systematic identification of all subdomains associated with a target domain. DNS is the primary mechanism enabling this discovery.

Two complementary strategies are used:

* **Active Enumeration** – Direct interaction with DNS infrastructure
* **Passive Enumeration** – Intelligence gathering without querying target DNS servers

Using both approaches yields the most comprehensive results.

---

## 5. Active Subdomain Enumeration

Active enumeration directly queries DNS infrastructure to identify valid subdomains.

### DNS Zone Transfers (AXFR)

A zone transfer attempts to retrieve the full DNS zone from an authoritative server. If misconfigured, this can disclose **every subdomain in one request**.

* Rare due to modern hardening
* High-impact when successful
* Extremely noisy and easily logged

### Brute-Force Enumeration

The most common active technique. This involves:

* Generating candidate subdomain names
* Querying DNS to determine which resolve

#### Common Tools

* `dnsenum`
* `ffuf`
* `gobuster`

#### Characteristics

* High coverage
* Detectable
* Dependent on wordlist quality

Active enumeration trades stealth for completeness.

---

## 6. Passive Subdomain Enumeration

Passive enumeration relies on third-party data sources and avoids direct interaction with target DNS servers.

### Certificate Transparency (CT) Logs

SSL/TLS certificates often include subdomains in the **Subject Alternative Name (SAN)** field. CT logs publicly record these certificates.

Advantages:

* Extremely rich data source
* Covers historical and current subdomains
* Completely passive

### Search Engine Enumeration

Using advanced search operators:

* `site:example.com`
* `site:*.example.com`

This can reveal:

* Indexed subdomains
* Forgotten services
* Publicly exposed resources

### Aggregated DNS Databases

Various services collect DNS data over time, enabling historical and cross-validated discovery.

Passive enumeration is:

* Stealthy
* Low-risk
* Incomplete on its own

---

## 7. Enumeration Strategy Considerations

| Approach | Strengths                 | Weaknesses                |
| -------- | ------------------------- | ------------------------- |
| Active   | High coverage, real-time  | Detectable, rate-limited  |
| Passive  | Stealthy, historical data | Incomplete, stale entries |

The most effective strategy is **hybrid enumeration**, using passive techniques first and active techniques selectively to fill gaps.

---

# Red Team Playbook: Subdomain Enumeration

## Objective

Identify all reachable subdomains to expand the attack surface and locate weak entry points.

---

## Phase 1: Passive Discovery (Low Noise)

### Actions

* Query Certificate Transparency logs
* Enumerate via search engines
* Query DNS aggregation services

### Outcomes

* Initial subdomain inventory
* Identification of high-value targets
* Zero interaction with target infrastructure

---

## Phase 2: Target Prioritization

### Focus On

* `dev`, `test`, `staging`, `beta`
* `admin`, `portal`, `vpn`
* Legacy or oddly named subdomains

---

## Phase 3: Active Enumeration (Controlled)

### Actions

* Brute-force common subdomain names
* Validate DNS resolution
* Identify CNAME chains

### Tools

* `dnsenum`
* `ffuf`
* `gobuster`

---

## Phase 4: Exploitation Pivoting

### Opportunities

* Subdomain takeover via dangling CNAMEs
* Auth bypass on dev portals
* Exploiting outdated frameworks
* Credential reuse between environments

---

## OPSEC Notes

* Throttle brute-force requests
* Avoid full zone transfer attempts unless authorized
* Blend enumeration into normal DNS traffic patterns

---

# Blue Team Playbook: Subdomain Defense & Detection

## Threat Summary

Subdomain enumeration is a precursor to:

* Web exploitation
* Credential harvesting
* Lateral movement
* Supply-chain compromise

Attackers rarely exploit the primary domain first.

---

## Detection Opportunities

### DNS Telemetry

* High-volume subdomain lookups
* Sequential name patterns
* Repeated NXDOMAIN responses

### Certificate Monitoring

* Unexpected SAN entries
* Certificates issued for unknown subdomains

---

## Defensive Controls

### Preventive

* Maintain a complete subdomain inventory
* Remove unused DNS entries
* Enforce consistent authentication across environments
* Restrict access to dev and staging systems

### Detective

* DNS query behavior analysis
* CT log monitoring
* Change detection on DNS zones

---

## Incident Response Actions

1. Identify enumerating source
2. Correlate with HTTP probing
3. Validate legitimacy of accessed subdomains
4. Remove or restrict exposed services
5. Audit authentication and patch levels

---

## Defensive Takeaway

Unused subdomains are liabilities.
Unknown subdomains are vulnerabilities.
Unmonitored subdomains are eventual breaches.

Organizations that cannot **inventory their subdomains** cannot defend their perimeter.
