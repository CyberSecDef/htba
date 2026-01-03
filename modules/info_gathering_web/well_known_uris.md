# Technical Report: Well-Known URIs (.well-known) in Web Reconnaissance

## 1. Executive Summary

The **.well-known** mechanism, defined by **RFC 8615**, standardizes a discovery directory at `/.well-known/` for publishing **machine-readable metadata** about a website’s services, protocols, and security posture. While designed to simplify legitimate client configuration and interoperability, these endpoints often expose **high-value reconnaissance data**—sometimes without authentication—making them a prime target early in web recon.

For penetration testers, `.well-known` endpoints provide **authoritative, structured insight** into identity systems, email security, asset verification, and security contacts—frequently revealing endpoints and cryptographic material that directly inform attack paths.

---

## 2. What Are Well-Known URIs

A **Well-Known URI** is a standardized path under `/.well-known/` used to publish specific resources defined by standards bodies. Clients construct predictable URLs to retrieve configuration or policy documents, e.g.:

```
https://example.com/.well-known/security.txt
```

This consistency enables automated discovery by browsers, apps, and security tools—and by attackers performing recon.

---

## 3. Governance and Registry

The **IANA Well-Known URI Registry** catalogs approved URI suffixes, each with:

* A defined purpose
* Status (Permanent / Provisional)
* Authoritative specification reference

This governance ensures predictable semantics but also means **what to look for is publicly documented**.

---

## 4. Notable Well-Known URIs (Selected)

| URI Suffix             | Purpose                              | Status      | Reference                  |
| ---------------------- | ------------------------------------ | ----------- | -------------------------- |
| `security.txt`         | Security contact & disclosure policy | Permanent   | RFC 9116                   |
| `change-password`      | Standard password change URL         | Provisional | W3C                        |
| `openid-configuration` | OpenID Connect discovery metadata    | Permanent   | OpenID Connect             |
| `assetlinks.json`      | Domain ↔ app ownership verification  | Permanent   | Google Digital Asset Links |
| `mta-sts.txt`          | SMTP MTA-STS policy                  | Permanent   | RFC 8461                   |

Each entry exposes **structured configuration** that can materially advance reconnaissance.

---

## 5. Why .well-known Matters for Web Recon

### 5.1 Predictable Discovery

Attackers don’t guess—**they request known paths**. If implemented, endpoints are trivial to fetch.

### 5.2 High Signal, Low Noise

Responses are typically **JSON or text**, purpose-built for automation, and require minimal probing.

### 5.3 Direct Mapping to Attack Surfaces

Identity providers, token endpoints, cryptographic keys, email security policies, and asset trust relationships are commonly exposed.

---

## 6. Deep Dive: `openid-configuration`

### 6.1 Purpose

Part of **OpenID Connect Discovery**, `/.well-known/openid-configuration` publishes the identity provider’s metadata so clients can auto-configure authentication flows.

### 6.2 Typical Response (Example)

```json
{
  "issuer": "https://example.com",
  "authorization_endpoint": "https://example.com/oauth2/authorize",
  "token_endpoint": "https://example.com/oauth2/token",
  "userinfo_endpoint": "https://example.com/oauth2/userinfo",
  "jwks_uri": "https://example.com/oauth2/jwks",
  "response_types_supported": ["code", "token", "id_token"],
  "subject_types_supported": ["public"],
  "id_token_signing_alg_values_supported": ["RS256"],
  "scopes_supported": ["openid", "profile", "email"]
}
```

---

## 7. Reconnaissance Value of OpenID Metadata

### 7.1 Endpoint Discovery

* **Authorization endpoint** → auth flow entry point
* **Token endpoint** → credential/token exchange target
* **Userinfo endpoint** → PII exposure surface
* **JWKS URI** → public keys for token verification

### 7.2 Capability Mapping

* Supported scopes & response types
* Signing algorithms
* Subject types

This data informs **OAuth/OIDC attack feasibility** (e.g., misconfigurations, weak flows, token handling issues).

---

## 8. Other High-Value Well-Known Targets

### 8.1 `security.txt`

* Security contact details
* Disclosure policies
* Bug bounty references
  Useful for **social engineering**, timing disclosures, or assessing maturity.

### 8.2 `mta-sts.txt`

* Email transport security policy
* Mode (enforce / testing)
* MX patterns
  Useful for **phishing and email security posture analysis**.

### 8.3 `assetlinks.json`

* Trust bindings between domains and mobile apps
  Useful for **supply-chain and trust relationship mapping**.

---

## 9. Operational Considerations

* `.well-known` endpoints are **intentionally public**
* Content is **authoritative** (not inferred)
* Absence can be as informative as presence
* Misconfigurations persist due to copy-paste deployments

---

# Red Team Playbook: Well-Known URI Reconnaissance

## Objective

Enumerate `.well-known` endpoints to discover configuration, identity, cryptographic, and policy data that expands the attack surface.

---

## Phase 1: Enumeration

### Actions

* Request `/.well-known/` common suffixes
* Check HTTP status and content type
* Capture and store responses

### Priority Targets

* `openid-configuration`
* `security.txt`
* `mta-sts.txt`
* `assetlinks.json`
* `change-password`

---

## Phase 2: Identity & Auth Analysis

### Actions

* Map OAuth/OIDC endpoints
* Retrieve JWKS
* Assess supported flows and scopes
* Identify weak or deprecated algorithms

---

## Phase 3: Pivoting

### Follow-Ups

* Token handling tests
* Authorization flow abuse (as authorized)
* Email security analysis (MTA-STS)
* Trust boundary analysis (asset links)

---

## OPSEC Notes

* Requests are expected and low-noise
* Avoid brute-forcing unregistered URIs
* Correlate with DNS, CT logs, and fingerprinting

---

# Blue Team Playbook: Defending Well-Known URI Exposure

## Threat Summary

`.well-known` endpoints intentionally expose metadata; risk arises from **overexposure, misconfiguration, or stale data**, not from the mechanism itself.

---

## Preventive Controls

### Configuration Hygiene

* Publish only required URIs
* Remove deprecated endpoints
* Keep metadata accurate and minimal

### Identity Hardening

* Enforce modern OAuth/OIDC flows
* Disable legacy response types
* Rotate keys and validate JWKS integrity

---

## Monitoring & Detection

### Indicators

* Repeated access to identity endpoints
* Enumeration of multiple `.well-known` paths
* Correlation with auth probing

---

## Incident Response Workflow

1. Inventory all `.well-known` endpoints
2. Validate necessity and correctness
3. Audit identity and email security configs
4. Remove or restrict unused resources
5. Update documentation and ownership

---

## Defensive Takeaway

`.well-known` doesn’t create exposure—it **documents it**.

If your configuration cannot safely be public, it should not exist. Security maturity means being comfortable with what your metadata reveals.
