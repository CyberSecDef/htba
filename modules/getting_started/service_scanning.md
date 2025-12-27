# Service Scanning Summary

Service scanning identifies OS and running services on targets. Focus on misconfigured/vulnerable services for exploitation. Use tools like Nmap for automation.

## Nmap

- Scans ports (1-65,535); default: 1,000 common.
- TCP by default; UDP with `-sU`.
- States: Open, closed, filtered.

**Basic Scan**:

- Command: `nmap 10.129.42.253`
- Output: Open ports (e.g., 21/tcp open ftp).

**Advanced Scan**:

- Command: `nmap -sV -sC -p- 10.129.42.253`
- `-sV`: Version scan (fingerprints services).
- `-sC`: Default scripts (more info, e.g., banners, vulns).
- `-p-`: All ports.
- Output: Versions (e.g., vsftpd 3.0.3), OS (e.g., Ubuntu Linux), scripts (e.g., ftp-anon).

**OS Identification**: Cross-reference versions (e.g., OpenSSH 8.2p1 → Ubuntu 20.04). Not 100% reliable.

**Additional**: Nmap top 1000 ports. Tools: Masscan (faster for large ranges). For UDP: `nmap -sU -p- target`.

## Nmap Scripts

- Enhance scans; located in scripts.
- Find: `locate scripts/citrix` (lists Citrix scripts).
- Run specific: `nmap --script <script> -p<port> <host>` (e.g., `nmap --script citrix-enum-apps.nse -p443 target`).
- Useful for vulns (e.g., CVE-2019–19781).

**Additional**: NSE (Nmap Scripting Engine). Module: Network Enumeration with Nmap for deep dive.

## Attacking Network Services

### Banner Grabbing

- Fingerprint services quickly.
- Manual: `nc -nv 10.129.42.253 21` (shows vsFTPd 3.0.3).
- Automated: `nmap -sV --script=banner -p21 10.10.10.0/24`.

**Additional**: Telnet: `telnet target port`.

### FTP

- Common; may allow anonymous access.
- Scan: `nmap -sC -sV -p21 10.129.42.253` (shows anon login, pub dir).
- Connect: `ftp -p 10.129.42.253`
  - User: `anonymous`
  - Commands: `ls`, `cd pub`, `get file`.

**Additional**: Tools: FileZilla (GUI). Secure: SFTP (SSH-based). Vulns: Check vsftpd versions for backdoors.
