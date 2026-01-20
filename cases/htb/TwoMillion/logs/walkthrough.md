# TwoMillion - Attack Walkthrough

## Phase 1: Reconnaissance

### Host Discovery & Port Scanning

Initial nmap scan against target 10.129.229.66 revealed two open TCP ports:
- **Port 22** - SSH (OpenSSH 8.9p1 Ubuntu)
- **Port 80** - HTTP (nginx)

```bash
nmap -Pn -sS -sV -T4 10.129.229.66
```

### Web Enumeration

Baseline curl scan showed the IP redirects to `http://2million.htb/`. Added entry to `/etc/hosts`:

```bash
echo "10.129.229.66 2million.htb" >> /etc/hosts
```

Ran multiple web enumeration tools:
- Gobuster (directory enumeration)
- Nikto (vulnerability scanning)
- ReconSpider (link/asset extraction)
- WafW00f (WAF detection)
- WhatWeb (fingerprinting)

## Phase 2: Initial Access

### Invite Code Discovery

1. Browsed to the site and found `/invite` page
2. Discovered `inviteapi.min.js` loaded on the page
3. Identified function names in the JavaScript code
4. Executed `makeInviteCode()` in browser developer console
5. Received ROT13-encrypted response containing a POST endpoint
6. Posted to endpoint and received base64-encoded invite code
7. Decoded invite code: `ZYWVC-MS3EL-Z97AB-83QGH`

### Account Registration

Registered a new account using the invite code and logged in.

### API Enumeration

1. Found "Connection Pack" functionality at `/api/v1/user/vpn/generate`
2. Used dirb/ffuf to enumerate `/api/v1/admin/` endpoints
3. Browsed to `/api/v1` and discovered three admin endpoints:
   - `/api/v1/admin/auth`
   - `/api/v1/admin/settings/update`
   - `/api/v1/admin/vpn/generate`

### Privilege Escalation (Web)

1. Logged in via Postman with test credentials (test:test123)
2. Used PUT request to `/api/v1/admin/settings/update` to promote account to admin

### Command Injection

1. Discovered command injection vulnerability in `/api/v1/admin/vpn/generate`
2. The username field accepts additional commands

## Phase 3: Exploitation

### Reverse Shell

1. Started netcat listener on port 4444
2. Injected PHP reverse shell payload via the vulnerable API endpoint
3. Established shell connection

### Credential Discovery

1. Found `.env` file with database credentials
2. Credentials matched the admin SSH user

### SSH Access

Used discovered credentials to SSH as admin user.

**User Flag:** `9f5610c657f44776c417d0d9e83ab74d`

## Phase 4: Privilege Escalation

### Email Discovery

Read admin email at `/var/mail/admin` from sender `ch4p@2million.htb`. Email referenced a kernel vulnerability.

### CVE-2023-0386 Exploitation

1. Identified CVE-2023-0386 - OverlayFS vulnerability allowing file manipulation with preserved metadata (SetUID bits)
2. Downloaded exploit from GitHub: `https://github.com/xkaneiki/CVE-2023-0386.git`
3. Transferred exploit to target using Python HTTP server
4. Compiled and executed exploit to gain root access

**Root Flag:** `1431fb0da4b48334a998a72a409cfba3`

## Tools Used

- nmap
- curl
- Gobuster
- dirb
- ffuf
- Nikto
- ReconSpider
- WafW00f
- WhatWeb
- Postman
- netcat
- Python (http.server)

## Key Vulnerabilities

1. **Information Disclosure** - JavaScript source revealed invite code generation function
2. **Insecure API** - User could self-promote to admin role
3. **Command Injection** - VPN generation endpoint allowed command injection
4. **Credential Reuse** - Web application database credentials matched SSH credentials
5. **CVE-2023-0386** - Linux kernel OverlayFS vulnerability for privilege escalation
