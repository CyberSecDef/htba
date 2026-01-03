# Technical Report: Certificate Transparency (CT) Logs

## 1. Executive Summary

Certificate Transparency (CT) logs are a foundational security mechanism designed to strengthen trust in SSL/TLS by providing **public, tamper-evident records of issued certificates**. While their primary purpose is defensive—detecting rogue or mis-issued certificates—they also serve as one of the **most powerful passive reconnaissance sources** available to penetration testers.

For web reconnaissance, CT logs offer a **historical, authoritative view of subdomains** associated with a domain, often revealing environments and services that are invisible to DNS brute-forcing, no longer actively used, or intentionally hidden.

---

## 2. SSL/TLS Trust and the Problem CT Solves

SSL/TLS secures web traffic by:

* Encrypting data in transit
* Authenticating website identity via digital certificates

This trust model depends on **Certificate Authorities (CAs)** behaving correctly. However, history has shown that:

* CAs can be compromised
* Certificates can be mis-issued
* Rogue certificates can be created for impersonation, MITM attacks, or malware delivery

CT logs were introduced to **remove secrecy from certificate issuance**.

---

## 3. What Are Certificate Transparency Logs

Certificate Transparency logs are:

* **Public**
* **Append-only**
* **Cryptographically verifiable**

Every publicly trusted CA is required to submit issued certificates to multiple CT logs. These logs are maintained by independent organizations and are accessible to anyone.

Conceptually, CT logs function as a **global, auditable registry of SSL/TLS certificates**.

---

## 4. Core Security Benefits of CT Logs

### 4.1 Early Detection of Rogue Certificates

Monitoring CT logs allows:

* Website owners
* Security teams
* Researchers

to detect certificates issued without authorization and revoke them before abuse.

### 4.2 Accountability for Certificate Authorities

Because all issuance is public:

* CA misbehavior is visible
* Violations damage CA reputation
* Ecosystem trust is enforced socially and technically

### 4.3 Strengthening the Web PKI

CT logs introduce **public oversight** into what was historically a closed trust system, dramatically improving the integrity of the Web PKI.

---

## 5. How CT Logs Work (High-Level)

1. CA issues a certificate
2. Certificate is submitted to multiple CT logs
3. Logs append the certificate and return a Signed Certificate Timestamp (SCT)
4. Browsers verify SCT presence during TLS handshakes
5. Certificates without valid CT inclusion are rejected by modern browsers

This ensures **every trusted certificate leaves a public trail**.

---

## 6. CT Logs as a Reconnaissance Asset

### 6.1 Why CT Logs Are Powerful for Recon

Unlike:

* DNS brute-forcing (guess-based)
* Wordlist enumeration (incomplete)
* VHost fuzzing (noisy)

CT logs provide:

* **Authoritative evidence** that a subdomain existed
* **Historical visibility** into old and expired assets
* **Complete SAN listings** tied to real certificates

If a subdomain ever had a certificate, it likely appears in CT logs.

---

### 6.2 Subdomain Discovery Advantages

CT logs can reveal:

* Development and staging systems
* Temporary test environments
* Legacy services
* Decommissioned but still reachable hosts
* Internal naming conventions

These assets often:

* Run outdated software
* Lack modern hardening
* Are forgotten by defenders

---

## 7. CT Logs vs Other Enumeration Methods

| Method          | Nature                     | Coverage              | Noise     |
| --------------- | -------------------------- | --------------------- | --------- |
| DNS brute-force | Guess-based                | Medium                | High      |
| Zone transfer   | Misconfiguration-dependent | Complete              | Very high |
| VHost fuzzing   | Server-side                | Partial               | High      |
| **CT logs**     | Certificate-based          | **High / historical** | **None**  |

CT logs are uniquely **passive, authoritative, and low-risk**.

---

## 8. Searching Certificate Transparency Logs

Two commonly used platforms are highlighted.

### 8.1 crt.sh

**Strengths**

* Free
* No registration
* Simple interface
* SAN extraction

**Limitations**

* Minimal filtering
* Manual analysis required

Ideal for:

* Quick subdomain discovery
* Manual investigations

---

### 8.2 Censys

**Strengths**

* Advanced filtering
* Certificate attribute searches
* Host correlation
* API access

**Limitations**

* Requires account
* Free tier limits

Ideal for:

* Large-scale reconnaissance
* Automation
* Infrastructure correlation

---

## 9. Automating CT Log Searches with crt.sh

crt.sh provides a JSON output that can be queried programmatically.

### Example: Finding `dev` Subdomains

```bash
curl -s "https://crt.sh/?q=facebook.com&output=json" |
jq -r '.[] | select(.name_value | contains("dev")) | .name_value' |
sort -u
```

### Breakdown

* `curl` retrieves CT log entries in JSON
* `jq` filters SAN entries containing `"dev"`
* `sort -u` deduplicates results

This approach:

* Is fully passive
* Scales well
* Integrates cleanly into recon pipelines

---

## 10. Operational Implications

CT logs often expose:

* Naming patterns (`dev`, `test`, `secure`, `internal`)
* Third-party integrations
* Deprecated but still reachable hosts
* Organizational structure clues

They are especially effective **early in reconnaissance** to guide all subsequent enumeration.

---

# Red Team Playbook: Certificate Transparency Reconnaissance

## Objective

Leverage CT logs to discover subdomains and historical assets without interacting with target infrastructure.

---

## Phase 1: Initial CT Enumeration

### Actions

* Query crt.sh for base domain
* Extract SAN entries
* Deduplicate results

### Outcomes

* High-confidence subdomain list
* Historical visibility

---

## Phase 2: Pattern Analysis

### Focus Areas

* `dev`, `test`, `staging`
* Geographic or office naming
* Product or service identifiers

---

## Phase 3: Asset Validation

### Actions

* Resolve discovered subdomains
* Check HTTP/HTTPS reachability
* Inspect TLS configurations
* Identify expired or weak certs

---

## Phase 4: Pivot to Active Recon

### Follow-Ups

* DNS resolution
* VHost fuzzing
* Web scanning
* Auth testing

CT logs inform **where to focus**, not what to exploit directly.

---

## OPSEC Notes

* CT log searches are invisible to targets
* No rate limits imposed by victims
* Ideal for stealthy engagements
* Should precede brute-forcing

---

# Blue Team Playbook: Defending Against CT-Based Recon

## Threat Summary

CT logs are **inherently public** and cannot be hidden. Defense focuses on **controlling what appears in them**, not preventing access.

---

## Defensive Strategy

### 1. Certificate Hygiene

* Avoid issuing certificates for:

  * Unused subdomains
  * Temporary test systems
  * Internal-only hosts

### 2. Asset Inventory

* Maintain a complete list of:

  * All issued certificates
  * All SAN entries
  * All subdomains ever exposed

---

## Monitoring and Detection

### CT Monitoring

* Subscribe to CT log alerts
* Detect unexpected certificate issuance
* Identify naming leaks early

### Correlation

* Map CT-discovered subdomains to:

  * DNS
  * Web servers
  * Load balancers

---

## Incident Response Workflow

1. Detect unexpected certificate
2. Identify affected subdomain
3. Assess exposure and reachability
4. Revoke certificate if needed
5. Decommission or harden service
6. Review certificate issuance policies

---

## Defensive Takeaway

CT logs do not create risk—they **expose reality**.

If a subdomain appears in CT logs, defenders must assume attackers already know about it. Security comes from **asset discipline**, not obscurity.
