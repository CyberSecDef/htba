# Technical Report: robots.txt in Web Reconnaissance

## 1. Executive Summary

The `robots.txt` file is a foundational component of web crawler etiquette, designed to guide well-behaved bots on which areas of a website they should or should not crawl. While it is **not a security control**, it frequently becomes an **intelligence disclosure mechanism** during reconnaissance.

For penetration testers, `robots.txt` offers **high-signal, low-effort insight** into a site’s internal structure, sensitive directories, and defensive mindset. Ironically, the very paths website owners wish to hide from search engines often become the first places attackers investigate.

---

## 2. What Is robots.txt

Technically, `robots.txt` is a **plain-text file** located at the root of a website:

```
https://www.example.com/robots.txt
```

It follows the **Robots Exclusion Standard**, which defines how automated crawlers should interact with a site. The file consists of **directives** that specify which URLs crawlers may or may not access.

Key point:
**robots.txt provides guidance, not enforcement.**

---

## 3. How robots.txt Works

### 3.1 User-Agents

Each set of rules applies to one or more **user-agents**, which identify specific crawlers.

Examples:

* `*` → all crawlers
* `Googlebot` → Google
* `Bingbot` → Microsoft

---

### 3.2 Directives

Directives define crawler behavior for the specified user-agent.

Common directives include:

| Directive   | Purpose                                     |
| ----------- | ------------------------------------------- |
| Disallow    | Paths the bot should not crawl              |
| Allow       | Explicitly permits access to specific paths |
| Crawl-delay | Throttles crawler request rate              |
| Sitemap     | Provides sitemap location                   |

Example:

```txt
User-agent: *
Disallow: /private/
```

This instructs all compliant crawlers not to access URLs beginning with `/private/`.

---

## 4. robots.txt File Structure

A `robots.txt` file is composed of **records**, separated by blank lines.

Each record contains:

1. One `User-agent` line
2. One or more directives

Example structure:

```txt
User-agent: *
Disallow: /admin/
Disallow: /private/
Allow: /public/

User-agent: Googlebot
Crawl-delay: 10

Sitemap: https://www.example.com/sitemap.xml
```

This structure allows fine-grained crawler control.

---

## 5. Why robots.txt Exists (Legitimate Reasons)

### 5.1 Server Load Management

* Prevents aggressive crawling
* Reduces unnecessary traffic
* Protects fragile endpoints

### 5.2 Search Index Control

* Keeps admin pages out of search results
* Prevents indexing of duplicate or low-value content

### 5.3 Legal & Ethical Considerations

* Supports compliance with site policies
* Signals intent regarding access boundaries

Important distinction:
**Intent ≠ enforcement**

---

## 6. robots.txt Is Not a Security Mechanism

Key limitations:

* No authentication
* No access control
* No enforcement
* Fully public

A malicious actor can:

* Fetch `robots.txt`
* Ignore its directives
* Access listed paths directly

From a security standpoint, `robots.txt` should be treated as **public documentation**, not a barrier.

---

## 7. robots.txt in Web Reconnaissance

For reconnaissance, `robots.txt` is often a **treasure map**.

### 7.1 Uncovering Hidden Directories

Disallowed paths frequently reveal:

* `/admin/`
* `/private/`
* `/backup/`
* `/internal/`
* `/dev/`

These paths often contain:

* Admin panels
* Staging environments
* Backup files
* Sensitive data

---

### 7.2 Mapping Website Structure

By reviewing allowed and disallowed paths, testers can:

* Infer application layout
* Identify unlinked functionality
* Discover alternate content trees

This aids crawl scoping and manual exploration.

---

### 7.3 Identifying Defensive Awareness

Some sites include:

* Fake directories
* Honeypot paths
* Bot traps

These indicate a **higher defensive maturity** and influence OPSEC decisions.

---

## 8. Analyzing a Sample robots.txt

Example file:

```txt
User-agent: *
Disallow: /admin/
Disallow: /private/
Allow: /public/

User-agent: Googlebot
Crawl-delay: 10

Sitemap: https://www.example.com/sitemap.xml
```

### Reconnaissance Insights

* `/admin/` likely exists
* `/private/` likely contains sensitive content
* `/public/` is intentionally indexed
* Googlebot throttling suggests crawl sensitivity
* Sitemap reveals full indexed URL list

Without touching the application, we already have **multiple investigative leads**.

---

## 9. Operational Value of robots.txt

robots.txt is:

* Passive
* Low noise
* Always accessible
* Often overlooked

It should be checked **early** in reconnaissance to guide:

* Crawling scope
* Manual testing
* Fuzzing priorities

---

# Red Team Playbook: robots.txt Reconnaissance

## Objective

Leverage robots.txt to identify sensitive paths and infer application structure with minimal interaction.

---

## Phase 1: Initial Retrieval

### Actions

* Request `/robots.txt`
* Store full contents
* Note user-agent distinctions

---

## Phase 2: Intelligence Extraction

### Focus Areas

* Disallowed directories
* Sitemap references
* Crawler-specific rules

---

## Phase 3: Target Prioritisation

### High-Value Paths

* `/admin/`
* `/private/`
* `/backup/`
* `/internal/`
* Environment-specific paths (`/dev/`, `/test/`)

---

## Phase 4: Controlled Validation

### Actions

* Manually access paths (authorized only)
* Combine with crawling and fingerprinting
* Cross-reference with CT logs and DNS data

---

## OPSEC Notes

* robots.txt access is expected and logged
* Do not brute-force based solely on robots.txt
* Treat listed paths as **leads**, not guaranteed vulnerabilities

---

# Blue Team Playbook: Defending robots.txt Exposure

## Threat Summary

robots.txt frequently discloses:

* Sensitive directory names
* Application structure
* Operational intent

Attackers use it as a **roadmap**, not a lock.

---

## Defensive Controls

### 1. Do Not List Sensitive Paths

Never include:

* Admin panels
* Internal tools
* Backup directories
* Authenticated resources

If access must be restricted, use **authentication**, not robots.txt.

---

### 2. Use robots.txt for SEO Only

Limit usage to:

* Duplicate content control
* Crawl optimization
* Sitemap pointers

---

### 3. Monitor Access Patterns

### Indicators

* Immediate access to disallowed paths
* robots.txt fetch followed by targeted probing
* Correlation with crawling behavior

---

## Incident Response Workflow

1. Detect suspicious robots.txt usage
2. Correlate with subsequent requests
3. Review exposed paths
4. Harden or remove sensitive resources
5. Update robots.txt hygiene

---

## Defensive Takeaway

robots.txt is not a “Private” sign on a locked door.
It is a **public sign pointing at the door**.

If a path must be protected, it should be secured—not hidden.
