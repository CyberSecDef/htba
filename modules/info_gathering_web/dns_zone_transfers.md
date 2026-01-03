# Technical Report: DNS Zone Transfers (AXFR)

## 1. Executive Summary

DNS zone transfers are a **legitimate replication mechanism** designed to keep authoritative name servers synchronized. However, when misconfigured, they represent one of the **highest-impact DNS reconnaissance vulnerabilities**. A successful unauthorized zone transfer instantly reveals a complete inventory of a domain’s DNS records—subdomains, IP addresses, mail servers, service records, and internal naming conventions—eliminating the need for brute-force enumeration.

While modern DNS environments typically restrict zone transfers, misconfigurations persist due to legacy setups, cloud DNS mismanagement, or human error. As a result, attempting zone transfers (with authorization) remains a critical reconnaissance step.

---

## 2. What Is a DNS Zone Transfer

A DNS zone transfer is the process by which a **secondary DNS server** obtains a full copy of a DNS zone from the **primary (master) DNS server**.

### Purpose

* Maintain consistency across name servers
* Provide redundancy and fault tolerance
* Ensure up-to-date DNS data

### Zone Transfer Types

* **AXFR** – Full zone transfer (entire zone file)
* **IXFR** – Incremental zone transfer (changes only)

The vulnerability discussed here primarily concerns **AXFR**.

---

## 3. Zone Transfer Process (AXFR)

The AXFR workflow consists of a structured exchange:

1. **Zone Transfer Request**
   The secondary server sends an AXFR request to the primary server.

2. **SOA Record Transfer**
   The primary server responds with the SOA record, including the zone’s serial number.

3. **DNS Records Transmission**
   All records in the zone are transferred:

   * A / AAAA
   * MX
   * NS
   * CNAME
   * TXT
   * SRV
   * PTR
   * Others

4. **Zone Transfer Completion**
   The primary server signals that all records have been sent.

5. **Acknowledgement (ACK)**
   The secondary server confirms successful receipt.

This exchange typically occurs over **TCP port 53**, not UDP.

---

## 4. The Zone Transfer Vulnerability

### Root Cause

The vulnerability arises when:

* Zone transfers are **not restricted**
* Access controls are **misconfigured**
* Legacy “allow any” policies remain in place

Historically, unrestricted zone transfers were common. Modern security standards prohibit this, but outdated configurations still exist.

---

## 5. Impact of an Unauthorized Zone Transfer

A successful AXFR provides attackers with **complete DNS visibility**:

### Exposed Information

* **All subdomains**

  * Including hidden, internal, or non-public services
* **IP address mappings**

  * Direct targets for scanning and exploitation
* **Mail infrastructure**

  * MX records, phishing and relay analysis
* **Service records**

  * SIP, authentication, internal services
* **Technology clues**

  * TXT records, verification strings, tooling indicators
* **Reverse DNS mappings**

  * PTR records revealing naming conventions

In practical terms, a zone transfer turns **hours or days of recon into seconds**.

---

## 6. Why Zone Transfers Still Matter Today

Even failed attempts are informative:

* Reveal whether AXFR is permitted
* Identify authoritative name servers
* Confirm TCP/53 behavior
* Expose DNS software fingerprints
* Indicate maturity of DNS security posture

Zone transfer attempts are **low-effort, high-reward** checks.

---

## 7. Exploiting Zone Transfers with dig

### AXFR Request Syntax

```bash
dig axfr @nameserver targetdomain.com
```

### Demonstration Example

```bash
dig axfr @nsztm1.digi.ninja zonetransfer.me
```

This command:

* Requests a full zone transfer (`axfr`)
* Targets a specific authoritative name server
* Attempts to retrieve the entire zone file

---

## 8. Interpreting Zone Transfer Output

Successful output includes:

* **SOA record** (zone authority and serial)
* **All DNS records**
* **Service records**
* **Internal metadata**
* **Record counts and transfer size**

The example domain `zonetransfer.me` is intentionally misconfigured to demonstrate the risk, returning dozens of records in a single response.

---

## 9. Remediation and Mitigation

### Standard Defensive Controls

* Restrict AXFR to **explicit secondary IPs**
* Use **TSIG authentication** for transfers
* Disable AXFR where secondary servers are unnecessary
* Monitor TCP/53 traffic
* Regularly audit DNS configurations

Modern DNS platforms support all of these—but only if properly configured.

---

# Red Team Playbook: DNS Zone Transfer Exploitation

## Objective

Attempt authorized DNS zone transfers to rapidly enumerate all DNS assets.

---

## Phase 1: Identify Authoritative Name Servers

### Actions

* Query NS records
* Enumerate all authoritative servers
* Identify on-prem vs cloud DNS

---

## Phase 2: Attempt Zone Transfers

### Commands

```bash
dig axfr @ns1.target.com target.com
dig axfr @ns2.target.com target.com
```

### Notes

* Test each authoritative server
* AXFR may succeed on secondaries but not primaries

---

## Phase 3: Analyze Retrieved Data

### Actions

* Extract subdomain list
* Identify internal naming patterns
* Correlate IP addresses
* Flag high-value targets (admin, dev, legacy)

---

## Phase 4: Pivot to Exploitation

### Common Follow-Ups

* Web exploitation on discovered subdomains
* Subdomain takeover checks
* Mail server attacks
* VPN and auth portal targeting

---

## OPSEC Considerations

* AXFR is **loud** and highly logged
* Always ensure authorization
* Limit attempts to one per server
* Prefer early-stage execution

---

# Blue Team Playbook: Zone Transfer Defense & Detection

## Threat Summary

Unauthorized zone transfers provide attackers with **complete DNS intelligence** and often precede targeted exploitation campaigns.

---

## Detection Strategies

### Network Monitoring

* TCP/53 connections from untrusted IPs
* AXFR request patterns
* Large DNS responses over TCP

### DNS Server Logs

* AXFR request logging
* Transfer failures
* Unauthorized client attempts

---

## Preventive Controls

### Configuration Hardening

* Explicitly restrict zone transfers
* Enforce TSIG authentication
* Disable AXFR by default
* Separate internal and external DNS zones

### Monitoring

* Alert on AXFR attempts
* Monitor authoritative server access
* Track DNS configuration changes

---

## Incident Response Workflow

1. Detect AXFR attempt
2. Identify requesting IP
3. Verify authorization
4. Block unauthorized source
5. Audit exposed DNS records
6. Review downstream exploitation attempts

---

## Defensive Takeaway

If an attacker can perform a zone transfer, **they no longer need reconnaissance**—you handed them the blueprint.

Zone transfers should be treated like **database replication**, not public information services.

