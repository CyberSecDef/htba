# Technical Report: Subdomain Brute-Force Enumeration

## 1. Executive Summary

Subdomain brute-force enumeration is one of the most effective **active reconnaissance techniques** for expanding an organization’s external attack surface. By systematically testing candidate subdomain names against a target domain using curated wordlists, attackers can uncover development systems, administrative portals, legacy services, and overlooked infrastructure that often lacks the security controls of primary production systems.

Despite being detectable, brute-force enumeration remains widely used because of its **high success rate** and **direct correlation to exploitable assets**.

---

## 2. Purpose of Subdomain Bruteforcing

Subdomain brute-forcing aims to discover DNS names that:

* Are **not linked** from the primary website
* Do **not appear** in passive intelligence sources
* Reflect **internal naming conventions**
* Expose **non-production or forgotten systems**

From a penetration-testing perspective, brute-forcing often identifies the **lowest-effort entry points** into a target environment.

---

## 3. Subdomain Bruteforcing Process

The brute-force enumeration workflow consists of four discrete phases.

### 3.1 Wordlist Selection

Wordlist quality directly determines success.

#### General-Purpose Wordlists

* Broad coverage of common names
* Examples: `dev`, `test`, `admin`, `mail`, `vpn`
* Useful when naming conventions are unknown

#### Targeted Wordlists

* Industry-specific or technology-specific
* Smaller, faster, fewer false positives
* Higher signal-to-noise ratio

#### Custom Wordlists

* Built from:

  * OSINT
  * Employee names
  * Product names
  * Internal references
* Highest efficiency when intelligence-driven

Poor wordlists waste time; good wordlists find vulnerabilities.

---

### 3.2 Iteration and Querying

Each wordlist entry is appended to the target domain:

* `dev.example.com`
* `staging.example.com`
* `portal.example.com`

Automation tools iterate through thousands of candidates quickly, generating DNS queries for each.

---

### 3.3 DNS Lookup

For each candidate subdomain, a DNS lookup is performed—typically querying:

* **A records** (IPv4)
* **AAAA records** (IPv6)

Successful resolution indicates the subdomain exists and is reachable.

---

### 3.4 Filtering and Validation

Resolved subdomains are:

* Logged as valid
* Optionally probed via HTTP/HTTPS
* Categorized by service type

Validation often includes:

* Web access
* TLS certificate inspection
* Banner grabbing

---

## 4. Subdomain Bruteforcing Tools

Several tools specialize in brute-force enumeration, each with different strengths.

| Tool        | Description                                      |
| ----------- | ------------------------------------------------ |
| dnsenum     | Full DNS reconnaissance suite with brute-forcing |
| fierce      | Recursive enumeration with wildcard detection    |
| dnsrecon    | Multi-technique DNS enumeration                  |
| amass       | Modern, actively maintained, data-rich           |
| assetfinder | Lightweight and fast                             |
| puredns     | High-performance resolver and filter             |

Tool choice depends on engagement scope, stealth requirements, and data volume.

---

## 5. DNSEnum Deep Dive

`dnsenum` is a comprehensive DNS reconnaissance tool written in Perl and commonly used in penetration tests.

### Key Capabilities

* DNS record enumeration (A, AAAA, NS, MX, TXT)
* Automatic zone transfer attempts
* Subdomain brute-forcing via wordlists
* Google scraping for subdomain discovery
* Reverse DNS lookups
* WHOIS information gathering

It functions as an **all-in-one DNS intelligence collector**, not merely a brute-forcer.

---

## 6. Practical Example: dnsenum Usage

### Command Breakdown

```bash
dnsenum --enum inlanefreight.com \
-f /usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt \
-r
```

* `--enum`: Enables multiple enumeration techniques
* `-f`: Specifies the subdomain wordlist
* `-r`: Enables recursive enumeration of discovered subdomains

### Observed Results

* Primary domain resolved
* Multiple subdomains discovered
* Shared IP addresses identified
* Confirmation of DNS-based asset expansion

Recursive enumeration increases coverage but also increases detectability.

---

## 7. Operational Risks and Limitations

* Highly **detectable** by DNS monitoring
* Subject to **rate limiting**
* Wordlist bias can miss custom naming schemes
* Wildcard DNS can produce false positives

Brute-forcing should be deliberate, not indiscriminate.

---

# Red Team Playbook: Subdomain Bruteforcing

## Objective

Expand the external attack surface by discovering valid subdomains via active DNS brute-force enumeration.

---

## Phase 1: Preparation

### Actions

* Identify target domain
* Select appropriate wordlists
* Tune resolver settings

### Considerations

* Engagement authorization
* Rate limits
* DNS recursion behavior

---

## Phase 2: Controlled Bruteforcing

### Tools

* `dnsenum`
* `amass`
* `puredns`

### Techniques

* Start with general wordlists
* Pivot to targeted or custom lists
* Enable recursion selectively

---

## Phase 3: Validation & Categorization

### Actions

* Resolve IP addresses
* Identify shared hosting
* Probe services via HTTP/HTTPS
* Identify environment types (prod/dev/test)

---

## Phase 4: Exploitation Pivoting

### Common Exploits

* Default credentials on dev portals
* Outdated frameworks on legacy subdomains
* Subdomain takeover via dangling CNAMEs
* Authentication bypass in staging environments

---

## OPSEC Notes

* Throttle queries
* Avoid repeated NXDOMAIN floods
* Rotate resolvers if authorized
* Log discovered assets carefully

---

# Blue Team Playbook: Detection & Defense Against Subdomain Bruteforcing

## Threat Summary

Subdomain brute-forcing is a **high-confidence indicator of reconnaissance** and often precedes:

* Web exploitation
* Credential attacks
* Lateral movement

---

## Detection Strategies

### DNS Telemetry

* High-volume sequential DNS queries
* Repeated failed lookups
* Wordlist-pattern naming attempts

### Behavioral Indicators

* Recursive subdomain discovery patterns
* Enumeration against non-public names

---

## Logging Requirements

* Recursive resolver query logs
* Firewall DNS telemetry
* Cloud DNS access logs
* Certificate issuance monitoring

---

## Defensive Controls

### Preventive

* Maintain authoritative subdomain inventory
* Remove unused DNS entries
* Restrict access to dev/staging systems
* Enforce authentication parity across environments

### Detective

* DNS behavior analytics
* Alerting on brute-force patterns
* Monitoring for unexpected subdomain creation

---

## Incident Response Workflow

1. Identify enumeration source
2. Correlate with HTTP probing
3. Validate exposure of discovered subdomains
4. Lock down non-production environments
5. Review DNS hygiene and ownership

---

## Defensive Takeaway

If attackers can **brute-force your subdomains**, you already lost control of your perimeter map.

Subdomain brute-forcing succeeds not because it is clever—but because organizations **forget what they expose**.

