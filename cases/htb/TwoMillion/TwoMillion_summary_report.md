# TwoMillion Penetration Test Report

## Executive Summary

TwoMillion is an Easy-rated HackTheBox machine running Ubuntu Linux with nginx web server. The assessment identified multiple critical vulnerabilities including information disclosure in client-side JavaScript, insecure direct object reference (IDOR) allowing privilege escalation, command injection in an API endpoint, and a Linux kernel vulnerability (CVE-2023-0386) enabling root access.

## Target Information

| Property | Value |
|----------|-------|
| IP Address | 10.129.229.66 |
| Hostname | 2million.htb |
| OS | Ubuntu Linux |
| Services | SSH (22), HTTP (80) |

## Findings Summary

| ID | Finding | Severity | CVSS |
|----|---------|----------|------|
| F1 | Information Disclosure in JavaScript | Medium | 5.3 |
| F2 | Insecure API - Self Privilege Escalation | Critical | 9.8 |
| F3 | Command Injection in VPN Generation API | Critical | 9.8 |
| F4 | Credential Reuse (Web to SSH) | High | 7.5 |
| F5 | CVE-2023-0386 - OverlayFS Privilege Escalation | High | 7.8 |

---

## Finding Details

### F1: Information Disclosure in JavaScript

**Severity:** Medium
**Location:** `/js/inviteapi.min.js`

**Description:**
The web application loads an obfuscated JavaScript file that exposes the invite code generation mechanism. While obfuscated using a packer, the code can be easily deobfuscated to reveal function names (`makeInviteCode`, `verifyInviteCode`) and API endpoints.

**Impact:**
Attackers can bypass the invite-only registration by understanding and calling the exposed API endpoints.

**Remediation:**
- Move invite code generation logic server-side
- Implement rate limiting on invite code generation
- Use server-side session validation for registration flow

---

### F2: Insecure API - Self Privilege Escalation

**Severity:** Critical
**Location:** `/api/v1/admin/settings/update`

**Description:**
Authenticated users can promote their own accounts to admin status by sending a PUT request to the admin settings endpoint. The API does not verify that the requestor has admin privileges before allowing role changes.

**Impact:**
Any authenticated user can gain administrative access to the application.

**Proof of Concept:**
```http
PUT /api/v1/admin/settings/update HTTP/1.1
Host: 2million.htb
Content-Type: application/json
Cookie: [session cookie]

{"is_admin": 1}
```

**Remediation:**
- Implement proper authorization checks on admin endpoints
- Verify requesting user has admin role before processing requests
- Log and alert on privilege escalation attempts

---

### F3: Command Injection in VPN Generation API

**Severity:** Critical
**Location:** `/api/v1/admin/vpn/generate`

**Description:**
The admin VPN generation endpoint accepts a username parameter that is passed unsanitized to a system command. Attackers with admin access can inject arbitrary commands.

**Impact:**
Remote code execution on the server with web application privileges.

**Proof of Concept:**
Injecting a reverse shell payload in the username parameter establishes a connection to the attacker's machine.

**Remediation:**
- Sanitize and validate all user input
- Use parameterized commands or dedicated libraries instead of shell execution
- Implement input allowlisting for username format

---

### F4: Credential Reuse (Web to SSH)

**Severity:** High
**Location:** `.env` file, SSH service

**Description:**
The web application stores database credentials in a `.env` file accessible after gaining shell access. These credentials are reused for the `admin` system user's SSH access.

**Impact:**
Compromising the web application leads directly to system-level access.

**Remediation:**
- Use unique credentials for different services
- Store sensitive files outside web-accessible directories
- Implement principle of least privilege for database users

---

### F5: CVE-2023-0386 - OverlayFS Privilege Escalation

**Severity:** High
**Location:** Linux kernel

**Description:**
The target system is vulnerable to CVE-2023-0386, a vulnerability in the Linux kernel's OverlayFS implementation. This allows unprivileged users to gain elevated privileges by exploiting improper handling of SetUID files during overlay operations.

**Impact:**
Local privilege escalation from any user to root.

**Remediation:**
- Update Linux kernel to a patched version
- Apply vendor security patches
- Consider disabling OverlayFS if not required

---

## Attack Path

```
[Reconnaissance]
       |
       v
[Information Disclosure] --> Discover invite API
       |
       v
[Account Registration] --> Create regular user account
       |
       v
[IDOR Privilege Escalation] --> Promote to admin
       |
       v
[Command Injection] --> Reverse shell as www-data
       |
       v
[Credential Reuse] --> SSH as admin user
       |
       v
[CVE-2023-0386] --> Root access
```

## Recommendations

1. **Immediate Actions:**
   - Patch Linux kernel to address CVE-2023-0386
   - Fix command injection vulnerability in VPN API
   - Implement proper authorization on admin endpoints

2. **Short-term Improvements:**
   - Conduct code review of all API endpoints
   - Implement input validation framework
   - Deploy Web Application Firewall (WAF)

3. **Long-term Strategy:**
   - Establish secure development lifecycle (SDLC)
   - Regular penetration testing
   - Automated vulnerability scanning in CI/CD pipeline

## Appendix

### Tools Used
- nmap (port scanning)
- Gobuster, dirb, ffuf (directory enumeration)
- Nikto (vulnerability scanning)
- Postman (API testing)
- netcat (reverse shell listener)

### Flags Captured
- User Flag: `9f5610c657f44776c417d0d9e83ab74d`
- Root Flag: `1431fb0da4b48334a998a72a409cfba3`

### References
- [CVE-2023-0386 - NVD](https://nvd.nist.gov/vuln/detail/CVE-2023-0386)
- [OWASP Command Injection](https://owasp.org/www-community/attacks/Command_Injection)
- [OWASP IDOR](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/05-Authorization_Testing/04-Testing_for_Insecure_Direct_Object_References)
