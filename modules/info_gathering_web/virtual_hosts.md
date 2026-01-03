# Technical Report: Virtual Hosts (VHosts) in Web Reconnaissance

## 1. Executive Summary

Virtual hosting allows a single web server to host **multiple websites or applications on the same IP address**. While this is operationally efficient, it introduces a reconnaissance opportunity: attackers can discover **hidden websites, applications, and environments** that are not exposed through DNS alone.

Virtual host discovery is a natural extension of DNS and subdomain enumeration and frequently uncovers **non-public, misconfigured, or legacy applications** that significantly expand the attack surface.

---

## 2. What Are Virtual Hosts

A **virtual host (VHost)** is a configuration construct within a web server (e.g., Apache, Nginx, IIS) that maps an incoming HTTP request to a specific website or application.

Unlike DNS, which maps names to IP addresses, **virtual hosts operate at the web server layer** and determine *what content is served once traffic reaches the server*.

---

## 3. VHosts vs Subdomains

Although closely related, subdomains and virtual hosts are distinct concepts.

### Subdomains

* DNS constructs (e.g., `blog.example.com`)
* Require DNS records (A, AAAA, or CNAME)
* May point to the same or different IP addresses
* Used for logical organization and routing

### Virtual Hosts

* Web-server-level constructs
* Distinguished by the **HTTP Host header**
* Can exist **without DNS records**
* May serve content for domains, subdomains, or entirely separate domains

A key reconnaissance insight:
**DNS does not tell the whole story—VHosts can exist without DNS visibility.**

---

## 4. How Virtual Hosts Work

### The Role of the HTTP Host Header

Every HTTP request includes a `Host` header:

```
GET / HTTP/1.1
Host: www.example.com
```

The web server:

1. Receives the request at an IP address
2. Reads the `Host` header
3. Matches it against configured virtual hosts
4. Serves content from the corresponding document root

The Host header acts as a **routing switch** inside the web server.

---

## 5. Accessing VHosts Without DNS

If a virtual host exists but does not have a DNS record, it can still be accessed by:

* Modifying the local **hosts file** to map a hostname to the target IP
* Sending HTTP requests with a custom `Host` header

This is the foundation of **VHost fuzzing**.

---

## 6. Example: Name-Based Virtual Hosting

A single server hosting multiple domains:

```apache
<VirtualHost *:80>
    ServerName www.example1.com
    DocumentRoot /var/www/example1
</VirtualHost>

<VirtualHost *:80>
    ServerName www.example2.org
    DocumentRoot /var/www/example2
</VirtualHost>
```

All domains resolve to the same IP, but the Host header determines which site is served.

---

## 7. Server-Side VHost Lookup Flow

1. Browser resolves domain to IP
2. Browser sends HTTP request with Host header
3. Web server inspects Host header
4. Matching virtual host configuration is selected
5. Content is served from the associated document root

If no match exists, the server may:

* Serve a default site
* Return an error
* Redirect the request

---

## 8. Types of Virtual Hosting

### Name-Based Virtual Hosting

* Uses Host header
* Most common
* Cost-effective
* Some TLS limitations (largely solved via SNI)

### IP-Based Virtual Hosting

* One IP per site
* Better isolation
* Higher cost
* Easier TLS handling

### Port-Based Virtual Hosting

* Same IP, different ports
* Less user-friendly
* Often used for internal or admin services

---

## 9. Why Virtual Hosts Matter for Recon

VHosts frequently expose:

* Internal or staging applications
* Administrative portals
* Legacy websites
* Forgotten services
* Security-weakened test environments

These assets often **bypass DNS-based discovery entirely**.

---

## 10. Virtual Host Discovery (VHost Fuzzing)

VHost fuzzing discovers virtual hosts by **sending HTTP requests with different Host headers** to the same IP address and analyzing the responses.

This technique:

* Does not require DNS records
* Works even when subdomains are “hidden”
* Can reveal internal or non-public services

---

## 11. Virtual Host Discovery Tools

| Tool        | Purpose                           | Notable Features              |
| ----------- | --------------------------------- | ----------------------------- |
| gobuster    | VHost and directory brute-forcing | Fast, flexible, widely used   |
| feroxbuster | Rust-based brute-forcer           | Recursive, wildcard detection |
| ffuf        | Web fuzzer                        | Highly customizable           |

---

## 12. Gobuster for VHost Discovery

### Preparation Steps

1. Identify target IP address
2. Select or create a wordlist
3. Understand base domain structure

### Basic Command Structure

```bash
gobuster vhost -u http://<target_IP> -w <wordlist> --append-domain
```

### Important Flags

* `-u` – Target URL (IP or hostname)
* `-w` – Wordlist
* `--append-domain` – Required in newer versions
* `-t` – Thread count
* `-k` – Ignore TLS certificate errors
* `-o` – Output file

### Example Output Interpretation

A response with a distinct status code or content length often indicates a valid virtual host.

---

## 13. Operational Considerations

* VHost fuzzing generates **significant traffic**
* Easily detected by IDS/WAF systems
* Should always be performed **with authorization**
* Filtering and response comparison are critical to avoid false positives

---

# Red Team Playbook: Virtual Host Discovery

## Objective

Identify hidden websites and applications hosted on the same IP address by fuzzing HTTP Host headers.

---

## Phase 1: Reconnaissance

### Actions

* Resolve target domain to IP
* Identify exposed ports
* Baseline default responses

---

## Phase 2: Wordlist Strategy

### Options

* Generic subdomain lists
* Industry-specific lists
* Custom lists based on OSINT

---

## Phase 3: VHost Fuzzing

### Tools

* `gobuster`
* `ffuf`
* `feroxbuster`

### Actions

* Fuzz Host header
* Compare response codes, sizes, headers
* Identify anomalies

---

## Phase 4: Validation

### Actions

* Add discovered VHosts to hosts file
* Browse manually
* Enumerate applications
* Identify auth requirements

---

## Exploitation Pivot Points

* Dev/staging apps with weak auth
* Legacy CMS installations
* Admin portals
* Shared credentials across environments

---

## OPSEC Notes

* Throttle requests
* Avoid excessive threading
* Blend with legitimate user-agent strings
* Stop once high-value hosts are found

---

# Blue Team Playbook: Defending Against VHost Enumeration

## Threat Summary

VHost enumeration allows attackers to bypass DNS controls and directly discover hidden services hosted on production infrastructure.

---

## Detection Strategies

### Network & App Layer

* High-volume requests to same IP
* Rapidly changing Host headers
* Unusual Host values

### WAF Indicators

* Host header fuzzing patterns
* Repeated 404/400 responses
* Abnormal request timing

---

## Preventive Controls

### Configuration

* Disable default catch-all VHosts
* Enforce strict Host header validation
* Require authentication on non-public VHosts
* Separate environments onto different IPs

### Infrastructure

* Use split DNS
* Restrict access to internal VHosts
* Harden staging and dev environments

---

## Incident Response Workflow

1. Detect Host header abuse
2. Identify source IPs
3. Correlate with DNS and HTTP activity
4. Block or rate-limit offenders
5. Audit exposed virtual hosts
6. Remove unused or insecure VHosts

---

## Defensive Takeaway

If DNS is your **map**, virtual hosts are the **rooms inside the building**.

You can lock the front door—but if attackers can guess room numbers, they will eventually find the unlocked ones.

