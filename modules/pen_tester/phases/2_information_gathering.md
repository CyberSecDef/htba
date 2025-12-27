# Information Gathering Phase Summary

Information Gathering is the foundational phase of penetration testing (pentest), performed iteratively throughout the process. It collects data on the target company, employees, infrastructure, and organization from public and private sources. This phase informs all subsequent steps (e.g., vulnerability assessment, exploitation). Categories include Open-Source Intelligence (OSINT), Infrastructure Enumeration, Service Enumeration, Host Enumeration, and Pillaging (post-exploitation).

## Open-Source Intelligence (OSINT)

Gather publicly available info on targets to identify events, dependencies, and connections. Sources: Social media, job postings, GitHub, StackOverflow. Can reveal sensitive data like passwords, hashes, keys, tokens, or SSH keys. If found, report per RoE Incident Handling. Developers often unintentionally expose code/configs. Learn more in Corporate Recon module.

**Additional Tools/Commands**:

- `theHarvester -d domain.com -b all` (Harvest emails, IPs, subdomains).
- Maltego or Recon-ng for automated OSINT.
- Google Dorks: `site:domain.com filetype:pdf` (Find docs).
- Shodan: Search for exposed devices/services.

## Infrastructure Enumeration

Map the company's internet/intranet footprint using OSINT and active scans. Identify servers (DNS, mail, web, cloud), IPs, and security measures (firewalls, WAFs). Compare to scope. Helps with evasive testing. Applicable externally (public) or internally (for password spraying).

**Additional Tools/Commands**:

- `dig domain.com` or `nslookup domain.com` (DNS enumeration).
- `whois domain.com` (Domain registration info).
- Nmap: `nmap -sn 192.168.1.0/24` (Host discovery).
- Amass or Sublist3r for subdomain enumeration.

## Service Enumeration

Identify network-accessible services on hosts/servers. Determine version, purpose, and vulnerabilities. Outdated versions often have known exploits. Admins may avoid updates to maintain functionality.

**Additional Tools/Commands**:

- Nmap: `nmap -sV -p- targetIP` (Service/version detection).
- `netstat -tuln` (Local services, post-access).
- Banner grabbing: `nc targetIP port` (Manual service info).

## Host Enumeration

Examine each scoped host for OS, services, versions, roles, and network interactions. Use active scans and OSINT. Internal enumeration reveals hidden services/misconfigs. Post-exploitation: Inspect locally for sensitive files/scripts.

**Additional Tools/Commands**:

- Nmap: `nmap -O targetIP` (OS detection).
- `enum4linux targetIP` (SMB enumeration on Linux/Windows).
- `smbclient -L targetIP` (SMB shares).
- Wireshark for traffic analysis.

## Pillaging

Collect sensitive data (e.g., names, creds, customer info) from exploited hosts during Post-Exploitation. Not a standalone stage but integral to info gathering/priv escalation. Impact demonstrates attack severity; aids lateral movement.

**Note**: Covered in modules like Network Enumeration with Nmap, Password Attacks, Active Directory Enumeration, Privilege Escalation (Linux/Windows), Attacking Common Services/Applications/Enterprise Networks. Practice on 150+ HTB targets.

**Additional Tools/Commands**:

- `find / -name "*.txt" 2>/dev/null` (Find files on Linux).
- `dir /s /b *.txt` (Windows file search).
- Mimikatz: `sekurlsa::logonpasswords` (Extract creds).
- BloodHound for AD pillaging.

**General Tips**: Perform all categories per pentest. Info is everywhere (social, code repos). Use evasive techniques to avoid detection. Return to this phase iteratively. For HTB Academy, focus on modules for hands-on practice. Always scope-check findings.
