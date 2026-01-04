# Technical Report: Search Engine Discovery (OSINT)

## 1. Executive Summary

Search Engine Discovery—commonly referred to as **OSINT (Open Source Intelligence)**—leverages publicly indexed data from search engines to uncover information about websites, organizations, infrastructure, and individuals. While designed for benign information retrieval, search engines inadvertently expose **security-relevant artifacts** such as sensitive documents, administrative endpoints, configuration files, and organizational metadata.

For penetration testers, search engine discovery is a **low-noise, high-yield reconnaissance technique** that often reveals vulnerabilities without sending a single packet to the target’s infrastructure.

---

## 2. What Is Search Engine Discovery

Search engine discovery uses:

* Public search engines
* Advanced search operators
* Indexed historical data

to extract information that is:

* Publicly accessible
* Often unintentionally exposed
* Frequently overlooked by defenders

This technique does **not bypass security controls**; instead, it exploits **indexing, caching, and publication mistakes**.

---

## 3. Why Search Engine Discovery Matters

### 3.1 Open Source and Legal

* Relies exclusively on public data
* No interaction with target systems
* Suitable for early-phase recon and scoping

### 3.2 Breadth of Coverage

Search engines index:

* Websites
* Documents
* Code snippets
* Cloud storage links
* Cached and historical content

This breadth frequently exceeds what direct crawling can reach.

### 3.3 Ease and Cost

* No tooling required beyond a browser
* No authentication
* No rate limits imposed by the target
* Extremely cost-effective

---

## 4. Practical Applications of OSINT

Search engine discovery supports:

* **Security Assessments**
  Exposed files, credentials, endpoints, and internal references

* **Competitive Intelligence**
  Products, partners, technologies, and business direction

* **Threat Intelligence**
  Tracking campaigns, infrastructure reuse, and attacker artifacts

* **Investigative Research**
  Organizational links, policy disclosures, compliance posture

---

## 5. Limitations of Search Engine Discovery

Despite its power, OSINT has constraints:

* Not all content is indexed
* Robots.txt and noindex directives limit visibility
* Recently removed content may persist in caches
* Authenticated content is excluded

Search engines reflect **what was visible**, not necessarily what *is* visible.

---

## 6. Search Operators: Precision Tools

Search operators act as **filters and selectors**, enabling highly targeted queries.

### 6.1 Core Operators

| Operator    | Purpose             | Example                         |
| ----------- | ------------------- | ------------------------------- |
| `site:`     | Limit to a domain   | `site:example.com`              |
| `inurl:`    | Match URL contents  | `inurl:login`                   |
| `filetype:` | Filter by file type | `filetype:pdf`                  |
| `intitle:`  | Match page title    | `intitle:"confidential report"` |
| `intext:`   | Match page body     | `intext:"password reset"`       |

---

### 6.2 Advanced Operators

| Operator    | Purpose                 | Example               |
| ----------- | ----------------------- | --------------------- |
| `cache:`    | View cached page        | `cache:example.com`   |
| `link:`     | Pages linking to target | `link:example.com`    |
| `related:`  | Similar sites           | `related:example.com` |
| `info:`     | Page summary            | `info:example.com`    |
| `numrange:` | Numeric ranges          | `numrange:1000-2000`  |

---

### 6.3 Boolean & Modifiers

| Operator    | Effect            |
| ----------- | ----------------- |
| `AND`       | Require all terms |
| `OR`        | Allow any term    |
| `NOT` / `-` | Exclude term      |
| `*`         | Wildcard          |
| `..`        | Numeric range     |
| `" "`       | Exact phrase      |

---

## 7. Google Dorking (Google Hacking)

**Google Dorking** uses carefully constructed queries to uncover:

* Sensitive files
* Hidden endpoints
* Misconfigurations
* Forgotten content

This technique exploits **indexing behavior**, not vulnerabilities in Google.

---

## 8. Common Google Dork Categories

### 8.1 Login and Admin Pages

```
site:example.com inurl:login
site:example.com (inurl:admin OR inurl:login)
```

### 8.2 Exposed Documents

```
site:example.com filetype:pdf
site:example.com (filetype:xls OR filetype:docx)
```

### 8.3 Configuration Files

```
site:example.com inurl:config.php
site:example.com (ext:conf OR ext:cnf)
```

### 8.4 Database Backups

```
site:example.com inurl:backup
site:example.com filetype:sql
```

These queries often reveal **high-impact findings with zero traffic to the target**.

---

## 9. Search Engine Caching Risks

Cached content can expose:

* Deleted files
* Old credentials
* Deprecated endpoints
* Historical business data

Attackers frequently review caches to **resurrect removed exposure**.

---

## 10. Operational Value in Reconnaissance

Search engine discovery excels at:

* Early-phase mapping
* Identifying high-value targets
* Guiding later active testing
* Reducing brute-force noise

It should be one of the **first techniques used**, not an afterthought.

---

# Red Team Playbook: Search Engine Discovery (OSINT)

## Objective

Leverage search engines and advanced operators to discover sensitive information without interacting with target infrastructure.

---

## Phase 1: Baseline Enumeration

### Actions

* Query `site:` for domain footprint
* Identify indexed subdomains
* Note document types

---

## Phase 2: Targeted Dorking

### Focus Areas

* Authentication pages
* Backups and configs
* Office documents
* Logs and dumps

---

## Phase 3: Correlation

### Actions

* Cross-reference with CT logs
* Validate against crawling output
* Prioritize live vs historical content

---

## Phase 4: Validation (Authorized Only)

### Actions

* Confirm accessibility
* Check for credential exposure
* Assess sensitivity and impact

---

## OPSEC Notes

* Zero interaction with target systems
* Searches are untraceable to the target
* Avoid automated scraping of search results
* Document timestamps carefully

---

# Blue Team Playbook: Defending Against Search Engine Discovery

## Threat Summary

Search engines amplify:

* Publication mistakes
* Poor access controls
* Inadequate content hygiene

Attackers exploit **what you already made public**.

---

## Preventive Controls

### Content Management

* Audit public directories
* Remove backups and temp files
* Restrict document access

---

### Index Control

* Use `noindex` where appropriate
* Review robots.txt usage
* Validate sitemap accuracy

---

### Cache Awareness

* Request cache removals for sensitive content
* Monitor historical exposure
* Rotate credentials after exposure

---

## Monitoring & Detection

### Indicators

* External reports of exposed data
* Unexpected search result discoveries
* OSINT findings during internal audits

---

## Incident Response Workflow

1. Identify exposed content
2. Confirm search engine indexing
3. Remove or secure source
4. Request cache purge
5. Rotate affected secrets
6. Review publishing controls

---

## Defensive Takeaway

Search engines do not leak data—they **remember it**.

If sensitive information was ever public, assume it is indexed, cached, copied, and searchable. Effective defense means **never publishing what cannot safely be found**.
