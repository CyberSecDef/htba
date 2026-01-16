# Living off the Land (LOTL / LOLBins / GTFOBins)

**Technical Report, Red Team Playbooks, and Blue Team Playbooks**

---

## Executive Summary

“Living off the Land” (LOTL) is a post-exploitation methodology that leverages **native operating system binaries, scripts, and libraries** to perform malicious or unauthorized actions without introducing foreign tools. The term and its formalization emerged from research by **Christopher Campbell (@obscuresec)** and **Matt Graeber (@mattifestation)**, later popularized through the **LOLBAS** (Windows) and **GTFOBins** (Linux) projects .

LOTL techniques are effective because they:

* Reduce attacker footprint
* Bypass application allow-listing
* Blend into legitimate administrative activity
* Evade signature-based defenses

This section focuses specifically on **file upload and download operations** using LOTL binaries across Windows and Linux systems.

---

## Core LOTL Concepts

### What Are LOLBins?

**LOLBins (Living off the Land Binaries)** are:

* Legitimate, signed binaries
* Shipped with the operating system
* Designed for benign administrative tasks
* Abusable for unintended purposes

Examples of LOTL functionality include:

* File download
* File upload
* Command execution
* File read/write
* Security control bypasses

Importantly, **these binaries are not exploits**. They are tools behaving as designed—just used creatively.

---

## Reference Repositories

### Windows

* **LOLBAS Project**
  A curated database of Windows binaries, scripts, and libraries that can be abused for LOTL techniques .

Search operators:

* `/download`
* `/upload`

### Linux

* **GTFOBins**
  A Unix-focused project cataloging binaries that can bypass restrictions or perform post-exploitation tasks .

Search operators:

* `+file download`
* `+file upload`

These resources are **operational reference manuals**, not optional reading.

---

## Windows LOTL: File Upload via CertReq.exe

### CertReq.exe Overview

`certreq.exe` is a legitimate Windows utility for managing certificate requests. Certain versions support the `-Post` argument, enabling it to send arbitrary file content over HTTP.

This effectively allows:

* File exfiltration
* Data staging
* HTTP-based upload without third-party tools

---

### Operational Flow

1. Attacker starts a Netcat listener
2. Target executes `certreq.exe` with `-Post`
3. File contents are sent over HTTP
4. Attacker captures file via Netcat

Even when the command times out, the file contents are typically transmitted successfully .

---

### Compatibility Caveat

* Not all Windows versions support `-Post`
* Updated versions may be required
* Operators must validate binary capability before relying on it

This highlights a key LOTL principle: **test before you need it**.

---

## Linux LOTL: File Transfer via OpenSSL

### Why OpenSSL?

OpenSSL is:

* Widely installed
* Trusted
* Rarely blocked
* Cryptographically capable

It can be abused to perform **Netcat-style encrypted file transfers**, combining LOTL with secure transport.

---

### TLS-Based File Transfer Flow

1. Attacker generates a self-signed certificate
2. Attacker starts an OpenSSL server
3. Target connects using `openssl s_client`
4. File data is transferred over TLS

This technique:

* Encrypts data in transit
* Blends with legitimate TLS traffic
* Avoids common Netcat signatures .

---

## Additional LOTL File Transfer Tools (Windows)

### BITSAdmin / BITS

**Background Intelligent Transfer Service (BITS)**:

* Designed for background downloads
* Respects network utilization
* Integrates with proxies and credentials

Available via:

* `bitsadmin`
* PowerShell `Start-BitsTransfer`

This is especially dangerous because:

* It looks like normal OS behavior
* It survives reboots
* It often bypasses egress filtering

---

### Certutil.exe

`certutil.exe` can download arbitrary files and has historically functioned as:

> “wget for Windows”

Caveat:

* AMSI commonly flags this usage today
* Still relevant in constrained or legacy environments .

---

## Operational Philosophy

The key lesson of LOTL is **optionality**.

Attackers who rely on one tool fail.
Attackers who know five native options succeed quietly.

The module explicitly encourages:

* Practicing obscure methods
* Building muscle memory
* Preparing for constrained environments .

---

# Red Team Playbooks

---

## Playbook 1: Windows LOTL File Upload (CertReq)

**Objective**
Exfiltrate files without introducing malware or tools.

**Prerequisites**

* Command execution on Windows host
* CertReq version supporting `-Post`
* Outbound HTTP allowed

**Execution Flow**

1. Start Netcat listener
2. Execute CertReq POST upload
3. Capture file contents
4. Store and analyze offline

**OPSEC Notes**

* Expect timeouts
* Use small test files first
* Avoid sensitive real PII unless authorized

---

## Playbook 2: Linux Encrypted LOTL Transfer (OpenSSL)

**Objective**
Transfer files securely using native binaries.

**Prerequisites**

* OpenSSL on both ends
* TCP connectivity

**Execution Flow**

1. Generate self-signed cert
2. Start OpenSSL server
3. Connect from target using `s_client`
4. Transfer file contents

**Advantages**

* Encrypted
* Minimal footprint
* IDS-resistant

---

## Playbook 3: Windows LOTL Download (BITS)

**Objective**
Download tools stealthily.

**Execution Flow**

1. Host payload over HTTP/S
2. Use BITS or PowerShell BITS cmdlets
3. Stage payload in writable directory

**Why This Works**

* Trusted OS service
* Proxy-aware
* Background execution

---

# Blue Team Playbooks

---

## Detection: LOTL Abuse (General)

**Indicators**

* Legitimate binaries performing unusual actions
* File transfers without browsers
* Encryption + outbound traffic correlation

**Telemetry Sources**

* Process command-line logging
* PowerShell Script Block Logging
* EDR behavioral analytics

---

## Detection: CertReq Abuse

**Indicators**

* CertReq with `-Post`
* Unexpected HTTP POST traffic
* Certificate tooling outside PKI workflows

**Response**

* Alert and investigate context
* Verify user role and intent

---

## Detection: OpenSSL Abuse

**Indicators**

* OpenSSL running outside admin workflows
* TLS sessions without known services
* File redirection into OpenSSL processes

---

## Detection: BITS Abuse

**Indicators**

* BITS jobs created by non-admins
* Downloads from unknown hosts
* Persistent or background transfers

**Prevention**

* Restrict BITS usage
* Monitor job creation events
* Apply application control policies

---

## Incident Response Guidance

1. Identify LOTL binary usage
2. Correlate with network activity
3. Validate intent vs role
4. Inspect transferred data
5. Determine scope and persistence

---

## Final Notes

Living off the Land is not clever—it’s **inevitable**.

If a binary exists, someone will abuse it.
If defenders only hunt malware, they will miss the attacker entirely.

And yes—if your EDR says “nothing malicious detected” while `certreq.exe` is uploading files over HTTP, that’s not stealth. That’s a gap.
