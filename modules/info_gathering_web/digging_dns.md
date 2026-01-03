# Technical Report: Digging DNS for Web Reconnaissance

## 1. Executive Summary

DNS reconnaissance is one of the most information-dense and least intrusive phases of web reconnaissance. Once DNS fundamentals and record types are understood, attackers can leverage DNS tooling to enumerate assets, uncover infrastructure relationships, identify mail systems, infer security tooling, and detect potential misconfigurations—often without directly interacting with target hosts.

This section focuses on **practical DNS reconnaissance**, emphasizing tooling, command usage, output interpretation, and operational caution.

---

## 2. Purpose of DNS Reconnaissance

DNS reconnaissance serves multiple strategic objectives:

* Discovering **subdomains and services**
* Identifying **mail infrastructure**
* Mapping **authoritative control boundaries**
* Detecting **misconfigurations** such as open zone transfers
* Profiling **defensive posture** (e.g., DNSSEC, recursion policies)

DNS is particularly valuable because it often exposes infrastructure details that are otherwise hidden behind load balancers, CDNs, or WAFs.

---

## 3. DNS Reconnaissance Tools Overview

DNS reconnaissance relies on both **manual** and **automated** tools, each serving different phases of assessment.

### Core DNS Tools and Use Cases

| Tool                | Key Features                                                        | Primary Use                                        |
| ------------------- | ------------------------------------------------------------------- | -------------------------------------------------- |
| `dig`               | Highly flexible, supports all record types, custom servers, tracing | Manual enumeration, deep analysis, troubleshooting |
| `nslookup`          | Simple interactive queries                                          | Quick resolution checks                            |
| `host`              | Minimal, clean output                                               | Fast record lookups                                |
| `dnsenum`           | Dictionary brute-forcing, zone transfer attempts                    | Automated subdomain discovery                      |
| `fierce`            | Recursive discovery, wildcard detection                             | Subdomain identification                           |
| `dnsrecon`          | Multiple techniques, structured output                              | Comprehensive DNS mapping                          |
| `theHarvester`      | OSINT aggregation                                                   | Email addresses, usernames, DNS data               |
| Online DNS Services | GUI-based queries                                                   | Rapid lookups without CLI access                   |

Each tool varies in **signal-to-noise ratio**, making tool selection an operational decision rather than a preference.

---

## 4. The Domain Information Groper (dig)

`dig` is the most precise and controllable DNS reconnaissance tool. It allows fine-grained querying, response filtering, and resolver selection.

### Common dig Commands and Functions

| Command                         | Purpose                                       |
| ------------------------------- | --------------------------------------------- |
| `dig domain.com`                | Default A record lookup                       |
| `dig domain.com A`              | IPv4 resolution                               |
| `dig domain.com AAAA`           | IPv6 resolution                               |
| `dig domain.com MX`             | Mail server discovery                         |
| `dig domain.com NS`             | Identify authoritative servers                |
| `dig domain.com TXT`            | Retrieve verification and policy records      |
| `dig domain.com CNAME`          | Alias resolution                              |
| `dig domain.com SOA`            | Zone authority details                        |
| `dig @1.1.1.1 domain.com`       | Query specific resolver                       |
| `dig +trace domain.com`         | Full resolution path                          |
| `dig -x IP`                     | Reverse DNS lookup                            |
| `dig +short domain.com`         | Minimal output                                |
| `dig +noall +answer domain.com` | Answer-only output                            |
| `dig domain.com ANY`            | Attempt full record retrieval (often blocked) |

**Note:** `ANY` queries are frequently ignored or rate-limited per RFC 8482 to reduce abuse.

---

## 5. DNS Query Output Breakdown

Understanding `dig` output is essential for accurate interpretation.

### Header Section

* **Opcode:** Type of query
* **Status:** Query result (e.g., NOERROR)
* **Flags:**

  * `qr`: response
  * `rd`: recursion requested
  * `ad`: authentic data (DNSSEC-validated)

### Question Section

Defines what record was requested (e.g., A record for `google.com`).

### Answer Section

Contains resolved records and TTL values. A TTL of `0` indicates no caching allowed.

### Footer Section

Includes:

* Query time
* Responding server
* Protocol used
* Timestamp
* Message size

### OPT Pseudosection (EDNS)

Appears when EDNS extensions are used, enabling:

* Larger UDP payloads
* DNSSEC support
* Additional metadata

---

## 6. Output Minimization for Automation

When scripting or chaining tools, minimal output is preferred:

* `+short` for raw values
* `+noall +answer` for structured parsing
* Resolver specification for consistency

This enables DNS to integrate cleanly into automated recon pipelines.

---

## 7. Operational Caution

DNS reconnaissance is **not invisible**:

* Excessive queries may trigger rate limiting
* Recursive brute forcing can raise alerts
* Permission is required for extensive enumeration in authorized testing

DNS is quiet, not silent.

---

# Red Team Playbook: DNS Reconnaissance Operations

## Objective

Enumerate DNS infrastructure to discover assets, services, and weaknesses prior to direct exploitation.

---

## Phase 1: Low-Noise Manual Enumeration

### Actions

* Query A, AAAA, NS, MX, TXT records
* Identify authoritative name servers
* Validate recursion behavior

### Tools

* `dig`
* `host`

---

## Phase 2: Infrastructure Mapping

### Actions

* Perform `+trace` queries
* Identify CDNs, third-party providers
* Map mail routing and redundancy

---

## Phase 3: Automated Enumeration

### Actions

* Subdomain brute forcing
* Wildcard detection
* Zone transfer attempts (AXFR)

### Tools

* `dnsenum`
* `dnsrecon`
* `fierce`

---

## Phase 4: OSINT Correlation

### Actions

* Harvest email addresses
* Identify employee naming conventions
* Correlate DNS names to exposed services

### Tools

* `theHarvester`

---

## Exploitation Opportunities

* Dangling CNAMEs → subdomain takeover
* Leaked TXT data → security tooling intel
* Exposed mail servers → phishing & relay analysis
* Legacy DNS aliases → forgotten systems

---

## OPSEC Notes

* Prefer `+short` output for automation
* Randomize query timing
* Use distributed resolvers when possible
* Avoid recursive brute forcing on monitored networks

---

# Blue Team Playbook: DNS Detection & Defense

## Threat Summary

DNS reconnaissance often precedes phishing, credential harvesting, lateral movement, and web exploitation.

---

## Detection Strategies

### Network Telemetry

* High-volume DNS queries
* Sequential subdomain enumeration
* Repeated NXDOMAIN responses

### Host Monitoring

* Resolver configuration changes
* Suspicious DNS client behavior

---

## Logging Requirements

* Recursive resolver logs
* Firewall DNS logs
* EDR file monitoring (hosts file)
* Cloud DNS change logs

---

## Incident Response Workflow

1. Identify querying source
2. Correlate with HTTP/SMTP activity
3. Validate legitimacy of enumeration
4. Throttle or block malicious clients
5. Review exposed DNS data

---

## Hardening Measures

* Disable unnecessary recursion
* Prevent zone transfers
* Minimize TXT record exposure
* Enforce DNSSEC where appropriate
* Monitor DNS changes continuously

---

## Defensive Takeaway

DNS reconnaissance is rarely blocked because it looks like normal traffic. Mature defenses focus on **behavioral analysis**, **change monitoring**, and **context correlation**, not simple allow/deny rules.
