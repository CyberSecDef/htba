# Technical Report: FTP and TFTP Protocols, Configuration, and Security Enumeration

## 1. Introduction to FTP

The **File Transfer Protocol (FTP)** is one of the oldest application-layer protocols in the TCP/IP stack. It operates at the same OSI layer as protocols such as HTTP and POP and is designed specifically for transferring files between a client and a server.

FTP is supported by:

* Dedicated FTP clients
* Command-line utilities
* Web browsers (limited support)

Despite its age, FTP is still commonly found in internal enterprise environments and legacy infrastructures.

---

## 2. FTP Communication Model

FTP uses **two separate TCP channels**:

### 2.1 Control Channel

* Established over **TCP port 21**
* Used for:

  * Authentication
  * Command transmission
  * Server responses (status codes)

### 2.2 Data Channel

* Traditionally uses **TCP port 20**
* Handles:

  * File uploads/downloads
  * Directory listings
* Supports resuming interrupted transfers

This dual-channel design is a defining feature of FTP and also a common source of firewall and security complications.

---

## 3. Active vs Passive FTP

### Active Mode

* Client connects to server on port 21
* Client tells server which local port to use for data transfer
* Server initiates the data connection
* **Fails behind firewalls**, as inbound connections are blocked

### Passive Mode

* Server provides a port number
* Client initiates both control and data connections
* **Firewall-friendly**
* Default mode in most modern FTP clients

Passive mode exists specifically to address firewall limitations.

---

## 4. FTP Commands and Status Codes

FTP operates through textual commands sent over the control channel, such as:

* File uploads/downloads
* Directory creation/deletion
* File renaming

Each command generates a **numeric status code** indicating success or failure. Not all commands are implemented consistently across FTP servers.

---

## 5. Security Characteristics of FTP

* FTP is a **clear-text protocol**
* Usernames and passwords can be **sniffed**
* Data transfers are unencrypted unless TLS is used
* Anonymous FTP may be enabled

Because of these weaknesses, FTP is considered insecure unless:

* Used in trusted networks
* Protected with TLS/SSL
* Strictly configured

---

## 6. Anonymous FTP

Anonymous FTP allows users to log in without valid credentials, typically using:

* Username: `anonymous`
* Password: any or none

While convenient, anonymous access introduces significant risk:

* Unauthorized file disclosure
* Data exfiltration
* File uploads leading to exploitation

Most anonymous FTP servers limit permissions, but misconfigurations are common.

---

## 7. TFTP Overview

**Trivial File Transfer Protocol (TFTP)** is a stripped-down alternative to FTP.

### Key Differences from FTP

* Uses **UDP** instead of TCP
* No authentication
* No encryption
* No directory listing
* Operates only on world-readable/writable files

TFTP relies on application-layer recovery mechanisms due to UDP’s unreliability.

### Security Implications

Because of its lack of security controls, TFTP should only be used in:

* Local
* Isolated
* Trusted networks

---

## 8. Common TFTP Commands

| Command | Purpose               |
| ------- | --------------------- |
| connect | Set remote host       |
| get     | Download files        |
| put     | Upload files          |
| status  | Show session state    |
| verbose | Enable verbose output |
| quit    | Exit session          |

TFTP lacks directory enumeration entirely.

---

## 9. vsFTPd Overview

**vsFTPd (Very Secure FTP Daemon)** is one of the most widely used FTP servers on Linux systems.

### Installation

```bash
apt install vsftpd
```

vsFTPd is favored for its:

* Simplicity
* Performance
* Security-focused design

---

## 10. vsFTPd Default Configuration

Main configuration file:

```
/etc/vsftpd.conf
```

### Core Default Settings

| Setting           | Description           |
| ----------------- | --------------------- |
| listen            | Standalone vs inetd   |
| listen_ipv6       | Enable IPv6           |
| anonymous_enable  | Allow anonymous login |
| local_enable      | Allow system users    |
| dirmessage_enable | Directory messages    |
| xferlog_enable    | Transfer logging      |
| pam_service_name  | PAM authentication    |
| ssl_enable        | TLS encryption        |

By default, anonymous access and SSL are disabled.

---

## 11. FTP User Restrictions

The file:

```
/etc/ftpusers
```

Contains users **explicitly denied** FTP access—even if valid locally.

This provides an additional security control layer beyond PAM.

---

## 12. Dangerous vsFTPd Settings

The following settings significantly expand attack surface:

| Setting                     | Risk                   |
| --------------------------- | ---------------------- |
| anonymous_enable=YES        | Public access          |
| anon_upload_enable=YES      | Arbitrary file upload  |
| anon_mkdir_write_enable=YES | Directory creation     |
| write_enable=YES            | Full file manipulation |
| no_anon_password=YES        | No authentication      |

These options are often enabled temporarily and forgotten.

---

## 13. Anonymous FTP Enumeration

Upon connection:

* Server responds with **220 banner**
* Banner may disclose:

  * Server name
  * Version
  * OS type

Anonymous users can often:

* List directories
* Download files
* Infer business structure

---

## 14. FTP Client Diagnostics

The `status`, `debug`, and `trace` commands reveal:

* Transfer modes
* Connection state
* Raw FTP command exchange

These commands help attackers and defenders understand server behavior.

---

## 15. Directory Listing Controls

### hide_ids

* Replaces UID/GID with `ftp`
* Prevents user enumeration
* Reduces information leakage

### ls_recurse_enable

* Enables recursive directory listings
* Exposes full directory trees
* Extremely useful for attackers

---

## 16. File Download Capabilities

FTP allows:

* Single-file downloads (`get`)
* Full mirror downloads (`wget -m`)

Mirroring entire FTP trees is efficient but highly suspicious in enterprise environments.

---

## 17. File Upload Risks

If uploads are permitted:

* Files may be executed by:

  * Web servers
  * Cron jobs
  * Log parsers
* Leads to:

  * Remote Command Execution (RCE)
  * Reverse shells
  * Privilege escalation

FTP upload capability near web roots is particularly dangerous.

---

## 18. FTP Footprinting with Nmap

Nmap is commonly used to identify FTP services.

### Relevant NSE Scripts

* ftp-anon
* ftp-syst
* ftp-brute
* ftp-vsftpd-backdoor
* ftp-bounce

These scripts automate:

* Anonymous login checks
* Banner grabbing
* Directory listing
* Vulnerability detection

---

## 19. Nmap Scan Results Interpretation

Nmap can detect:

* FTP version
* Anonymous access
* Writable directories
* Server configuration details via STAT

Script tracing (`--script-trace`) exposes:

* Exact commands sent
* Response codes
* Network-level behavior

---

## 20. Manual FTP Interaction

Alternative tools for service interaction:

* `nc`
* `telnet`
* `openssl s_client`

These allow:

* Banner retrieval
* Raw command testing
* TLS certificate inspection

---

## 21. FTP over TLS (FTPS)

When TLS is enabled:

* FTP credentials are encrypted
* SSL certificates reveal:

  * Hostnames
  * Organizational details
  * Email addresses
  * Geographic information

Certificates often leak valuable reconnaissance data.

---

## 22. Security Implications

Key risks demonstrated:

* Anonymous access
* Clear-text authentication
* Excessive permissions
* File upload abuse
* Information disclosure via banners and listings
* Internal services exposed due to trust assumptions

The document repeatedly highlights a critical pattern:

> Internal services are often poorly hardened because they are assumed to be unreachable.

---

## 23. Defensive Takeaways

Best practices implied by the material:

* Disable anonymous FTP unless absolutely required
* Enforce TLS encryption
* Restrict upload permissions
* Audit vsFTPd configuration regularly
* Disable recursive listings
* Monitor logs for bulk downloads
* Treat internal services as hostile-exposed

---

## 24. Conclusion

FTP remains widely deployed despite fundamental security weaknesses. Misconfigured FTP servers—especially those allowing anonymous access and uploads—pose severe risks to enterprise environments.

The document demonstrates that **FTP enumeration is trivial when configuration hygiene is poor**, and exploitation often follows immediately once access is discovered.

Effective defense requires **intentional configuration, continuous auditing, and elimination of legacy assumptions**.
