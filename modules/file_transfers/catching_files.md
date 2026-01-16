# Catching Files over HTTP/S

**Technical Report, Red Team Playbooks, and Blue Team Playbooks**

---

## Executive Summary

HTTP and HTTPS are the **most reliable and universally permitted transport mechanisms** in enterprise environments. Firewalls, proxies, and IDS/IPS platforms are typically designed to *allow* web traffic, not block it outright. As a result, HTTP/S becomes the **primary channel of choice** for file transfers during penetration tests—especially when other protocols (SMB, SSH, FTP) are restricted.

This section focuses on **secure inbound file capture** using HTTP, specifically:

* Hosting upload endpoints
* Preventing accidental code execution
* Avoiding directory indexing
* Leveraging encryption-in-transit via HTTPS where possible
* Minimizing operational risk

It also reinforces a recurring professional theme: *convenience without discipline becomes self-inflicted compromise.*

---

## Why HTTP/S Is the Preferred Transport

### Enterprise Reality

HTTP/S is:

* Almost always allowed outbound
* Commonly allowed inbound to specific services
* Often TLS-encrypted
* Considered “normal” traffic by SOC teams

From a red-team perspective:

* Web traffic blends in
* Encrypted payloads reduce IDS visibility
* Fewer protocol-specific alerts are triggered

From a blue-team perspective:

* This is exactly why it must be monitored carefully

---

## Security Risk of Improper Web Upload Handling

Allowing file uploads is **dangerous by default**.

Key risks:

* Web shell uploads
* Arbitrary code execution
* Directory listing exposure
* Sensitive file leakage

Apache, in particular, is notorious for:

* Aggressive module loading
* PHP auto-execution
* Misconfiguration foot-guns

This is why **Nginx** is preferred in this context.

---

# Nginx for Secure File Uploads

## Why Nginx Instead of Apache

Nginx advantages:

* Minimal by default
* No automatic script execution
* No PHP execution unless explicitly configured
* Simple configuration surface
* Fewer “oops, we just popped ourselves” moments

If Apache is a loaded gun, Nginx is a locked toolbox.

---

## Upload Architecture Overview

### Design Goals

* Accept file uploads
* Prevent execution
* Avoid directory enumeration
* Keep attack surface minimal

### Transport

* HTTP (example shown)
* HTTPS strongly recommended in real engagements

---

## Step-by-Step Configuration Breakdown

### 1. Create Upload Directory

Purpose:

* Isolate uploaded files
* Avoid web root contamination

Key consideration:

* Directory must **not** be executable

---

### 2. Assign Ownership to `www-data`

Purpose:

* Allow Nginx to write files
* Avoid running Nginx as root
* Maintain principle of least privilege

Failure here results in:

* Permission errors
* Operators “temporarily” chmod-ing 777 (don’t)

---

### 3. Nginx PUT Configuration

Key configuration elements:

* Non-standard port (9001)
* Isolated upload path
* WebDAV PUT enabled
* Explicit root mapping

Critical security detail:

* **No PHP, CGI, or execution handlers configured**
* PUT uploads data only—nothing runs

This is intentional.

---

### 4. Enable the Site

Symlinking:

* Activates the site
* Keeps configuration modular
* Allows quick disablement

Operational benefit:

* Easy teardown after engagement

---

### 5. Handling Port Conflicts

Common issue:

* Port 80 already in use (labs, proxies, Python servers)

Resolution steps:

* Identify conflicting process
* Remove default Nginx config
* Bind only required ports

This reinforces an important lesson:

> *Your tooling will collide with other tooling—expect it.*

---

## Uploading Files via cURL

### PUT Method Advantages

* Simple
* Scriptable
* Available everywhere
* No browser required

Use cases:

* Exfiltration
* Uploading loot from compromised hosts
* Staging encrypted artifacts

This method pairs perfectly with:

* AES-encrypted files
* DLP testing
* Egress-restricted environments

---

## Directory Listing Considerations

Directory indexing is:

* Enabled by default in Apache
* **Disabled by default in Nginx**

This is a **major security win**.

Why this matters:

* Prevents accidental exposure
* Reduces analyst mistakes
* Limits post-compromise discovery by third parties

In offensive security, *boring defaults are good defaults.*

---

## Living-Off-The-Land (LOLBins) Context

This section sets the stage for:

* Native Windows/Linux tools
* Minimal footprint operations
* Avoiding third-party binaries
* Blending with normal admin behavior

HTTP file transfers using built-in tools will resurface in:

* Privilege escalation
* AD enumeration
* Post-exploitation workflows

This is foundational material, not a one-off trick.

---

# Red Team Playbooks

---

## Playbook 1: Secure HTTP File Capture

**Objective**
Receive files from compromised hosts using HTTP while minimizing detection and risk.

**Prerequisites**

* Control of attacker infrastructure
* Ability to run Nginx
* Firewall access to chosen port

**Execution Flow**

1. Deploy minimal Nginx PUT endpoint
2. Use non-standard port
3. Disable directory listing
4. Receive encrypted files via PUT
5. Validate integrity
6. Tear down service post-use

**OPSEC Notes**

* Never enable script execution
* Randomize upload directory names
* Remove upload service immediately after use

---

## Playbook 2: Encrypted Data Exfiltration via HTTP

**Objective**
Safely exfiltrate sensitive artifacts.

**Execution Flow**

1. Encrypt files on target
2. Upload via HTTP PUT
3. Verify receipt
4. Securely delete plaintext originals
5. Decrypt offline

**Why This Works**

* Encrypted payload
* Normal web traffic
* Minimal endpoint footprint

---

## Playbook 3: DLP / Egress Testing

**Objective**
Evaluate client monitoring controls.

**Execution Flow**

1. Generate synthetic sensitive data
2. Encrypt file
3. Upload over HTTP
4. Observe alerts, blocks, or logs
5. Document findings

This satisfies:

* Security objectives
* Legal boundaries
* Professional responsibility

---

# Blue Team Playbooks

---

## Detection: HTTP PUT Abuse

**Indicators**

* PUT requests to unusual ports
* WebDAV activity
* File uploads without authentication

**Telemetry Sources**

* Web server logs
* Proxy logs
* IDS signatures for PUT methods

---

## Detection: Staging Behavior

**Indicators**

* File encryption followed by HTTP transfer
* Unusual upload destinations
* Off-hours upload activity

**Correlation Opportunities**

* Endpoint encryption + outbound HTTP
* Command execution followed by PUT requests

---

## Prevention & Hardening

* Disable PUT where not required
* Require authentication for uploads
* Monitor WebDAV usage
* Enforce HTTPS with valid certificates
* Restrict upload directories at OS level

---

## Incident Response Guidance

1. Identify uploaded artifacts
2. Preserve timestamps
3. Review encryption indicators
4. Correlate with endpoint activity
5. Determine whether data was synthetic or real

---

## Final Notes

HTTP/S is not “safe” by default—it is **trusted by default**, and attackers love that distinction.

Red teams use HTTP because it works.
Blue teams must monitor HTTP because it works *too well*.

And yes—if you accidentally enable PHP execution on your upload server, congratulations: you’ve just pentested yourself.
