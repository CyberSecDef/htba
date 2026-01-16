# Protected File Transfers

**Technical Report, Red Team Playbooks, and Blue Team Playbooks**

---

## Executive Summary

During penetration tests, operators frequently encounter or generate **highly sensitive data**, including credentials, directory service databases (e.g., `NTDS.dit`), internal network topology data, and enumeration artifacts. Transferring such data in plaintext—even during authorized testing—creates **significant legal, ethical, and operational risk**.

This section addresses **secure handling and transfer of sensitive data when traditional encrypted transport mechanisms (SSH, HTTPS, SFTP)** are unavailable. It emphasizes **file-level encryption prior to transfer** as a compensating control, ensuring confidentiality even if network traffic is intercepted.

Key themes include:

* Professional responsibility and ethical constraints
* Avoidance of real PII exfiltration unless explicitly authorized
* File-level encryption on Windows using PowerShell (AES)
* File-level encryption on Linux using OpenSSL
* Password hygiene and cryptographic best practices

---

## Professional & Ethical Considerations

### Sensitive Data Handling

Penetration testers may encounter:

* Usernames and password hashes
* Active Directory databases
* Network architecture details
* Enumeration results revealing internal security posture

**Best practice**:

* Do **not** exfiltrate real PII, financial data, or trade secrets unless explicitly authorized
* When testing DLP or egress controls, use **synthetic data** that mimics protected data formats

Failure to protect client data can result in:

* Contract termination
* Legal exposure
* Loss of trust
* Professional reputation damage

In short: *“You’re allowed to break in—not to be reckless once you’re inside.”*

---

## Why Encryption Is Required

Even during sanctioned tests:

* Network traffic may be monitored
* Data may traverse untrusted segments
* Logs, PCAPs, or IDS systems may capture payloads

Encrypting data **before transport** ensures:

* Confidentiality if intercepted
* Reduced legal exposure
* Alignment with professional standards

Encryption compensates when:

* HTTPS / SSH are unavailable
* SMB signing is disabled
* Tunneling is impractical
* Netcat or raw TCP transfers are required

---

# File Encryption on Windows

## PowerShell AES Encryption (Invoke-AESEncryption.ps1)

### Overview

`Invoke-AESEncryption.ps1` is a lightweight PowerShell script that:

* Encrypts **strings or files**
* Uses **AES-256 (CBC mode)**
* Derives keys using **SHA-256**
* Outputs Base64 (for text) or `.aes` files (for binaries)

This makes it ideal for:

* Living-off-the-land operations
* Environments without OpenSSL
* File encryption prior to Netcat/RDP/WinRM transfer

---

### Cryptographic Design Notes

* **Algorithm**: AES-256-CBC
* **Key derivation**: SHA-256 hash of passphrase
* **IV handling**: Prepended to ciphertext
* **Padding**: Zero padding
* **Output**:

  * Base64 string (text mode)
  * Binary `.aes` file (file mode)

While not enterprise-grade PKI, this is **more than sufficient** for protecting data-in-transit during a test.

---

### Supported Operations

#### Encrypt / Decrypt Text

* Useful for credentials, tokens, config strings
* Outputs Base64 ciphertext

#### Encrypt / Decrypt Files

* Preserves timestamps
* Appends `.aes` extension
* Suitable for large files (e.g., AD dumps, scan results)

---

### Operational Usage Flow

1. Transfer script to target host
2. Import as PowerShell module
3. Encrypt sensitive files
4. Transfer encrypted artifacts
5. Decrypt on analyst system

---

### Password Hygiene (Critical)

* **Unique password per engagement**
* Never reuse encryption keys across clients
* Treat encryption passwords as sensitive artifacts
* Assume files *may* be intercepted

Reusing a single encryption password across engagements is how a bad day becomes a career-limiting event.

---

# File Encryption on Linux

## OpenSSL File Encryption

### Overview

OpenSSL is commonly available on Linux systems and supports:

* Strong symmetric encryption
* Password-based key derivation
* Flexible cipher selection

It is ideal for:

* Unix-like targets
* Netcat-based transfers
* Minimal environments

---

### Recommended Encryption Parameters

* Cipher: `aes256`
* Key derivation: `pbkdf2`
* Iterations: `100000+`

These parameters significantly increase resistance to:

* Offline brute-force attacks
* Password cracking attempts

---

### Linux Encryption Workflow

1. Encrypt sensitive file using OpenSSL
2. Transfer encrypted file via any available method
3. Decrypt only on authorized analyst system

---

### Why PBKDF2 Matters

PBKDF2:

* Slows brute-force attacks
* Increases attacker cost
* Protects weak but unavoidable passwords

Skipping `-pbkdf2` and iteration tuning is like locking a vault with a bicycle lock.

---

## Transport Recommendations

Even with encrypted files:

* Prefer **SSH, SFTP, HTTPS** where possible
* Use Netcat/raw TCP only when necessary
* Minimize exposure window
* Remove artifacts post-transfer

Encryption protects confidentiality—but **transport security still matters**.

---

# Red Team Playbooks

---

## Playbook 1: Secure Data Exfiltration (Windows)

**Objective**
Protect sensitive artifacts prior to transfer.

**Prerequisites**

* PowerShell access
* Ability to write files
* Any transfer method available

**Execution Flow**

1. Transfer AES encryption script
2. Import PowerShell module
3. Encrypt sensitive files
4. Transfer `.aes` files
5. Securely delete plaintext originals

**OPSEC Notes**

* Use unique passwords per client
* Avoid obvious filenames (e.g., `ntds.dit.aes`)
* Clear PowerShell history if appropriate

---

## Playbook 2: Secure Data Exfiltration (Linux)

**Objective**
Encrypt files before using insecure transport.

**Prerequisites**

* Shell access
* OpenSSL available

**Execution Flow**

1. Encrypt files with strong parameters
2. Transfer encrypted file
3. Validate integrity
4. Remove plaintext copy

**OPSEC Notes**

* Avoid storing passwords in shell history
* Prefer interactive prompts
* Clean up encrypted artifacts if not needed

---

## Playbook 3: DLP Testing (Safe Mode)

**Objective**
Test egress/DLP without exfiltrating real data.

**Execution Flow**

1. Create synthetic PII-like dataset
2. Encrypt file
3. Attempt controlled exfiltration
4. Observe detection and blocking behavior

**Why This Matters**

* Validates controls
* Avoids legal exposure
* Keeps lawyers asleep at night

---

# Blue Team Playbooks

---

## Detection: Encrypted Data Staging

**Indicators**

* Sudden creation of `.aes`, `.enc`, `.bin` files
* PowerShell AES usage
* OpenSSL encryption commands on servers

**Monitoring Sources**

* EDR command-line logging
* PowerShell Script Block Logging
* Linux auditd / shell history

---

## Detection: Pre-Exfiltration Behavior

**Indicators**

* File size changes followed by network transfer
* Encryption followed by outbound TCP sessions
* Use of Netcat or raw sockets after encryption

**Defensive Actions**

* Correlate encryption + outbound traffic
* Alert on unusual crypto usage on endpoints

---

## Prevention & Hardening

* Restrict PowerShell script execution
* Apply AppLocker / WDAC rules
* Limit OpenSSL on non-admin systems
* Monitor WinRM and PowerShell usage
* Implement DLP with content inspection

---

## Incident Response Guidance

1. Identify encrypted artifacts
2. Preserve originals if available
3. Review command execution history
4. Correlate with network logs
5. Validate whether data was synthetic or real

---

## Final Notes

Encryption during penetration testing is not optional—it is **professional hygiene**.

Red teams that encrypt protect their clients.
Blue teams that detect encryption catch attackers **before** data leaves the building.

And yes—nothing ruins an engagement faster than explaining to legal why a plaintext credential dump was flying across the network like it was 1999.
