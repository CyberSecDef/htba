# Technical Report: Domain Name System (DNS)

## 1. Executive Summary

The Domain Name System (DNS) is a foundational internet protocol responsible for translating human-readable domain names into IP addresses. While conceptually simple, DNS plays a critical role in infrastructure discovery, traffic routing, and trust validation. From a penetration-testing perspective, DNS is one of the most valuable reconnaissance layers available, often exposing assets, internal naming conventions, third-party services, and security posture without direct interaction with target hosts.

---

## 2. DNS Purpose and Role

DNS functions as a distributed, hierarchical naming system that maps domain names to numerical IP addresses. Without DNS, users would need to manually remember IP addresses for every service they access. DNS enables scalability, abstraction, and redundancy by decoupling service identity from network addressing .

From an attacker’s viewpoint, DNS is less a convenience layer and more an intelligence repository.

---

## 3. DNS Resolution Process (Recursive Lookup)

The DNS resolution workflow follows a strict hierarchical sequence:

1. **Local Cache Check**
   The client checks its local DNS cache for a previously resolved entry.

2. **DNS Resolver Query**
   If unresolved, the client forwards the request to a recursive resolver (typically ISP-provided or public resolvers such as Google DNS).

3. **Root Name Server Query**
   The resolver queries a root server to identify which TLD server is authoritative for the requested domain.

4. **TLD Name Server Query**
   The TLD server responds with the authoritative name server for the specific domain.

5. **Authoritative Name Server Query**
   The authoritative server returns the final IP address.

6. **Response and Caching**
   The resolver returns the IP to the client and caches the response for the TTL duration.

This chain establishes multiple observation and interception points for both attackers and defenders.

---

## 4. Hosts File and Local Name Resolution

The hosts file provides a local override mechanism for DNS resolution, allowing static mappings between hostnames and IP addresses. Entries in this file are resolved before DNS queries occur.

### Locations

* **Windows:** `C:\Windows\System32\drivers\etc\hosts`
* **Linux/macOS:** `/etc/hosts`

### Common Uses

* Local development redirection
* Troubleshooting connectivity
* Blocking domains by redirecting them to `0.0.0.0`

From a security perspective, unauthorized modification of the hosts file is a classic persistence and traffic-manipulation technique.

---

## 5. DNS Zones and Zone Files

A **DNS zone** is an administrative portion of the DNS namespace managed by a specific authority. A **zone file** defines the records within that zone.

### Zone File Components

* **SOA (Start of Authority):** Administrative metadata and timing parameters
* **NS Records:** Authoritative name servers
* **MX Records:** Mail routing
* **A / AAAA Records:** IPv4 and IPv6 mappings
* **CNAME Records:** Aliases

Zone misconfigurations frequently lead to information disclosure, zone transfers, and service impersonation.

---

## 6. DNS Record Types

DNS records store discrete types of infrastructure data:

| Record | Purpose                                  |
| ------ | ---------------------------------------- |
| A      | IPv4 address mapping                     |
| AAAA   | IPv6 address mapping                     |
| CNAME  | Host aliasing                            |
| MX     | Mail routing                             |
| NS     | Zone delegation                          |
| TXT    | Arbitrary text (SPF, DKIM, verification) |
| SOA    | Zone authority metadata                  |
| SRV    | Service discovery                        |
| PTR    | Reverse DNS mapping                      |

The `IN` class designator indicates records are for the Internet protocol suite.

---

## 7. DNS as a Reconnaissance Goldmine

DNS data enables:

* **Asset Discovery:** Subdomains, mail servers, VPN endpoints
* **Infrastructure Mapping:** Load balancers, CDNs, third-party providers
* **Technology Fingerprinting:** TXT records revealing tooling (SPF, password managers)
* **Change Detection:** New subdomains indicating new services or attack surfaces

DNS often leaks more than the organization intends—without triggering alerts.

---

# Red Team Playbook: DNS Reconnaissance & Exploitation

## Objective

Leverage DNS to identify assets, infrastructure, and attack vectors prior to direct exploitation.

---

## Phase 1: Passive Reconnaissance

### Techniques

* WHOIS lookups
* Passive DNS databases
* Certificate transparency logs

### Key Targets

* NS records
* MX records
* TXT records
* CNAME chains

---

## Phase 2: Active Enumeration

### Common Tools

* `dig`
* `nslookup`
* `dnsrecon`
* `amass`
* `subfinder`

### Actions

* Enumerate subdomains
* Identify misconfigured CNAMEs
* Attempt zone transfers (`AXFR`)
* Resolve PTR records for reverse lookups

---

## Phase 3: Exploitation Opportunities

### Common Weaknesses

* Zone transfers enabled
* Dangling CNAMEs (subdomain takeover)
* Leaked credentials or tooling in TXT records
* Legacy systems exposed via DNS aliases

---

## Phase 4: Post-Discovery Pivoting

* Use DNS findings to target web apps, VPNs, mail servers
* Correlate DNS names with internal naming conventions
* Identify trust boundaries and third-party dependencies

---

## OPSEC Considerations

* Prefer passive DNS where possible
* Throttle active queries
* Use distributed resolvers to reduce detection

---

# Blue Team Playbook: DNS Detection, Defense & Hardening

## Threat Summary

DNS reconnaissance is often the earliest phase of an attack lifecycle and is frequently undetected due to its benign appearance.

---

## Detection Opportunities

### Network Level

* Excessive DNS queries
* High-entropy subdomain lookups
* Repeated `NXDOMAIN` responses

### Host Level

* Unauthorized hosts file changes
* Suspicious resolver configuration changes

---

## Logging Requirements

* DNS query logs
* Resolver logs
* EDR file integrity monitoring (hosts file)
* Firewall DNS telemetry

---

## Incident Response Actions

1. Identify querying source
2. Correlate with other recon activity
3. Validate legitimacy of DNS requests
4. Contain suspicious clients
5. Review exposed DNS records

---

## Hardening Measures

* Disable zone transfers unless explicitly required
* Minimize DNS record exposure
* Audit TXT records regularly
* Enforce DNSSEC where applicable
* Monitor for new subdomains continuously

---

## Preventive Controls

* Split-horizon DNS for internal resources
* Change detection on DNS infrastructure
* Strong access control on DNS management platforms

---

## Final Notes

DNS is often underestimated because it “just works.” In practice, it is one of the most reliable intelligence sources for attackers and one of the most overlooked monitoring points for defenders. Mature security programs treat DNS as both a **control plane** and a **telemetry source**, not merely a utility service.

When ready, post the next document and the same structure will be applied automatically.
