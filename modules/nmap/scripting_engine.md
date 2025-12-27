# Nmap Scripting Engine (NSE) Summary

## Overview

Nmap Scripting Engine (NSE) uses Lua scripts for advanced service interaction, vulnerability detection, and enumeration. Scripts are categorized into 14 groups for targeted scanning. NSE enhances Nmap's capabilities beyond basic scanning.

## Script Categories

- **auth**: Authentication credential detection.
- **broadcast**: Host discovery via broadcasting; adds discovered hosts to scans.
- **brute**: Brute-force login attempts on services.
- **default**: Scripts run with `-sC` (default category).
- **discovery**: Service evaluation and information gathering.
- **dos**: Denial-of-service vulnerability checks (use cautiously).
- **exploit**: Exploits known vulnerabilities.
- **external**: Uses external services for processing.
- **fuzzer**: Identifies vulnerabilities via unexpected packet handling (time-consuming).
- **intrusive**: Potentially harmful scripts affecting the target.
- **malware**: Detects malware infections.
- **safe**: Non-intrusive, defensive scripts.
- **version**: Extends service detection.
- **vuln**: Identifies specific vulnerabilities.

## Using NSE Scripts

### Default Scripts (-sC)

Runs default category scripts.

**Command:**

```bash
sudo nmap <target> -sC
```

### Specific Category

Runs all scripts in a category.

**Command:**

```bash
sudo nmap <target> --script <category>
```

### Defined Scripts

Runs specific scripts (comma-separated).

**Command:**

```bash
sudo nmap <target> --script <script-name>,<script-name>,...
```

**Example: Banner and SMTP Commands on Port 25**

```bash
sudo nmap 10.129.2.28 -p 25 --script banner,smtp-commands
```

**Output:**

```
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-16 23:21 CEST
Nmap scan report for 10.129.2.28
Host is up (0.050s latency).

PORT   STATE SERVICE
25/tcp open  smtp
|_banner: 220 inlane ESMTP Postfix (Ubuntu)
|_smtp-commands: inlane, PIPELINING, SIZE 10240000, VRFY, ETRN, STARTTLS, ENHANCEDSTATUSCODES, 8BITMIME, DSN, SMTPUTF8,
MAC Address: DE:AD:00:00:BE:EF (Intel Corporate)
```

- `banner` reveals OS (Ubuntu).
- `smtp-commands` lists available SMTP commands (e.g., VRFY for user enumeration).

### Aggressive Scan (-A)

Combines service detection (-sV), OS detection (-O), traceroute (--traceroute), and default scripts (-sC).

**Command:**

```bash
sudo nmap 10.129.2.28 -p 80 -A
```

**Output:**

```
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-17 01:38 CEST
Nmap scan report for 10.129.2.28
Host is up (0.012s latency).

PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-generator: WordPress 5.3.4
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: blog.inlanefreight.com
MAC Address: DE:AD:00:00:BE:EF (Intel Corporate)
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: Linux 2.6.32 (96%), Linux 3.2 - 4.9 (96%), Linux 2.6.32 - 3.10 (96%), Linux 3.4 - 3.10 (95%), Linux 3.1 (95%), Linux 3.2 (95%), 
AXIS 210A or 211 Network Camera (Linux 2.6.17) (94%), Synology DiskStation Manager 5.2-5644 (94%), Netgear RAIDiator 4.2.28 (94%), 
Linux 2.6.32 - 2.6.35 (94%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 1 hop

TRACEROUTE
HOP RTT      ADDRESS
1   11.91 ms 10.129.2.28

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 11.36 seconds
```

- Identifies Apache 2.4.29, WordPress 5.3.4, title "blog.inlanefreight.com", and likely Linux OS.

## Vulnerability Assessment

Use `vuln` category for vulnerability scanning.

**Command:**

```bash
sudo nmap 10.129.2.28 -p 80 -sV --script vuln
```

**Output:**

```
Nmap scan report for 10.129.2.28
Host is up (0.036s latency).

PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
| http-enum:
|   /wp-login.php: Possible admin folder
|   /readme.html: Wordpress version: 2
|   /: WordPress version: 5.3.4
|   /wp-includes/images/rss.png: Wordpress version 2.2 found.
|   /wp-includes/js/jquery/suggest.js: Wordpress version 2.5 found.
|   /wp-includes/images/blank.gif: Wordpress version 2.6 found.
|   /wp-includes/js/comment-reply.js: Wordpress version 2.7 found.
|   /wp-login.php: Wordpress login page.
|   /wp-admin/upgrade.php: Wordpress login page.
|_  /readme.html: Interesting, a readme.
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-stored-xss: Couldn't find any stored XSS vulnerabilities.
| http-wordpress-users:
| Username found: admin
|_Search stopped at ID #25. Increase the upper limit if necessary with 'http-wordpress-users.limit'
| vulners:
|   cpe:/a:apache:http_server:2.4.29:
|       CVE-2019-0211   7.2 https://vulners.com/cve/CVE-2019-0211
|       CVE-2018-1312   6.8 https://vulners.com/cve/CVE-2018-1312
|       CVE-2017-15715  6.8 https://vulners.com/cve/CVE-2017-15715
<SNIP>
```

- `http-enum`: Enumerates WordPress paths and versions.
- `http-wordpress-users`: Finds usernames (e.g., admin).
- `vulners`: Lists CVEs for Apache 2.4.29.

## Additional Relevant Information and Tools

- **Popular Scripts:** `http-vuln-*` for web vulns, `smb-vuln-*` for SMB, `ftp-anon` for anonymous FTP access.
- **Custom Scripts:** Write in Lua; place in `~/.nmap/scripts/` and update `script.db` with `nmap --script-updatedb`.
- **Integration:** Use with Metasploit (import XML), or tools like OpenVAS/Nessus for deeper vuln scanning.
- **Performance:** Scripts can slow scans; use `--script-timeout` to limit. Avoid `intrusive`/`dos` in production.
- **Documentation:** Full NSE docs at <https://nmap.org/nsedoc/index.html>. List scripts: `nmap --script-help <script>`.
- **Examples:** `--script "not intrusive"` to exclude intrusive scripts. `--script-args` for script parameters (e.g., `--script-args http-wordpress-users.limit=100`).

## Nmap Cheatsheet (Relevant Options)

### Scanning Options

- `-sn`: Host discovery only.
- `-Pn`: Skip ping.
- `-n`: No DNS.
- `-PE`: ICMP ping.
- `--packet-trace`: Packet details.
- `--reason`: Result reasons.
- `--disable-arp-ping`: No ARP ping.
- `--top-ports=<num>`: Top ports.
- `-p-`: All ports.
- `-p22-110`: Port range.
- `-p22,25`: Specific ports.
- `-F`: Top 100.
- `-sS`: SYN scan.
- `-sA`: ACK scan.
- `-sU`: UDP scan.
- `-sV`: Version detection.
- `-sC`: Default scripts.
- `--script <script>`: Custom scripts.
- `-O`: OS detection.
- `-A`: Aggressive scan.
- `-D RND:5`: Decoys.
- `-e`: Interface.
- `-S <IP>`: Spoof source IP.
- `-g`: Source port.
- `--dns-server <ns>`: DNS server.

### Output Options

- `-oA <file>`: All formats.
- `-oN <file>`: Normal.
- `-oG <file>`: Grepable.
- `-oX <file>`: XML.

### Performance Options

- `--max-retries <num>`: Retries.
- `--stats-every=5s`: Status.
- `-v/-vv`: Verbose.
- `--initial-rtt-timeout 50ms`: Initial RTT.
- `--max-rtt-timeout 100ms`: Max RTT.
- `--min-rate 300`: Packet rate.
- `-T <0-5>`: Timing (0-5).
