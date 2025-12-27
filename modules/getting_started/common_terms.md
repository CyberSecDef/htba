# Common Terms Summary

Pentesting involves many technologies/terms. Key ones: Shell, Port, Web Server. Memorize for efficiency (e.g., ports, protocols). Practice on HTB boxes.

## What is a Shell?

- Program taking keyboard input, passing to OS (e.g., Bash on Linux, enhanced sh).
- Other shells: Zsh, Tcsh, Ksh, Fish.
- "Getting a shell": Exploit for interactive access (bash/sh).
- Types:
  - **Reverse Shell**: Connects back to attacker listener.
  - **Bind Shell**: Binds to target port; attacker connects.
  - **Web Shell**: Runs OS commands via browser; semi-interactive/single-command (e.g., PHP script).

**Additional**: Languages for helpers: Python, Perl, Go, Bash, Java, awk, PHP. Upgrade shells for stability (e.g., `python -c 'import pty; pty.spawn("/bin/bash")'`).

## What is a Port?

- Virtual "window/door" for network connections; managed by OS.
- Associated with processes/services; differentiates traffic (e.g., SSH vs. HTTP).
- Standardized numbers; services can use non-standard.
- Categories:
  - **TCP**: Connection-oriented (handshake); reliable.
  - **UDP**: Connectionless; faster for real-time, less reliable.
- 65,535 each. Memorize common ones for quick recognition.

**Common Ports**:

| Port(s) | Protocol |
|---------|----------|
| 20/21 (TCP) | FTP |
| 22 (TCP) | SSH |
| 23 (TCP) | Telnet |
| 25 (TCP) | SMTP |
| 80 (TCP) | HTTP |
| 161 (TCP/UDP) | SNMP |
| 389 (TCP/UDP) | LDAP |
| 443 (TCP) | SSL/TLS (HTTPS) |
| 445 (TCP) | SMB |
| 3389 (TCP) | RDP |

**Additional**: Research protocols; use nmap top 1000. Tools: `netstat -tuln` (local ports); `ss -tuln` (socket stats).

## What is a Web Server?

- Back-end app handling HTTP traffic (ports 80/443); routes requests/responses.
- Public-facing; high attack surface if vulnerable.
- Vulnerabilities: OWASP Top 10 (standardized list; not exhaustive).

**OWASP Top 10**:

1. **Broken Access Control**: Improper restrictions; unauthorized access/modification.
2. **Cryptographic Failures**: Weak crypto; data exposure/compromise.
3. **Injection**: Unvalidated input (SQL, command, LDAP).
4. **Insecure Design**: Security not built-in.
5. **Security Misconfiguration**: Poor hardening/defaults; verbose errors.
6. **Vulnerable and Outdated Components**: Unsupported/outdated libs.
7. **Identification and Authentication Failures**: Weak auth/session mgmt.
8. **Software and Data Integrity Failures**: Integrity violations (untrusted sources).
9. **Security Logging and Monitoring Failures**: No breach detection.
10. **Server-Side Request Forgery (SSRF)**: Fetching unvalidated URLs; bypass protections.

**Additional**: Learn each category deeply. Tools: Burp Suite/ZAP for testing. Module: Introduction to Web Applications.

## Cheatsheet

Reference for commands. (Same as previous; included for completeness.)

### Basic Tools

- **General**:
  - `sudo openvpn user.ovpn`: Connect VPN.
  - `ifconfig`/`ip a`: Show IP.
  - `netstat -rn`: Accessible networks.
  - `ssh user@10.10.10.10`: SSH.
  - `ftp 10.129.42.253`: FTP.
- **Tmux**:
  - `tmux`: Start.
  - `ctrl+b`: Prefix.
  - `prefix c`: New window.
  - `prefix 1`: Switch window.
  - `prefix shift+%`: Split vert.
  - `prefix shift+"`: Split horiz.
  - `prefix ->`: Right pane.
- **Vim**:
  - `vim file`: Open.
  - `esc+i`: Insert.
  - `esc`: Normal.
  - `x`: Cut char.
  - `dw`: Cut word.
  - `dd`: Cut line.
  - `yw`: Copy word.
  - `yy`: Copy line.
  - `p`: Paste.
  - `:1`: Line 1.
  - `:w`: Save.
  - `:q`: Quit.
  - `:q!`: No save.
  - `:wq`: Save quit.

### Pentesting

- **Service Scanning**:
  - `nmap 10.129.42.253`: Basic.
  - `nmap -sV -sC -p- 10.129.42.253`: Script scan.
  - `locate scripts/citrix`: List scripts.
  - `nmap --script smb-os-discovery.nse -p445 10.10.10.40`: Run script.
  - `netcat 10.10.10.10 22`: Banner.
  - `smbclient -N -L \\\\10.129.42.253`: SMB shares.
  - `smbclient \\\\10.129.42.253\\users`: Connect share.
  - `snmpwalk -v 2c -c public 10.129.42.253 1.3.6.1.2.1.1.5.0`: SNMP.
  - `onesixtyone -c dict.txt 10.129.42.254`: Brute SNMP.
- **Web Enumeration**:
  - `gobuster dir -u http://10.10.10.121/ -w /usr/share/dirb/wordlists/common.txt`: Dir scan.
  - `gobuster dns -d inlanefreight.com -w /usr/share/SecLists/Discovery/DNS/namelist.txt`: Subdomain.

**Additional Commands**: For shells: PowerShell reverse. For ports: `lsof -i :80` (processes on port). For web: `nikto -h target` (web vuln scan). Practice memorization; use flashcards.
