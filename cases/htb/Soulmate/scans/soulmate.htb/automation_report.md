# Automated Penetration Test Report

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')  
**Target:** ${target}  
**Tool:** auto_nmap.sh v2.0

---

## Executive Summary

This report contains the findings from an automated enumeration scan of the target system(s). 
The scan was performed using the auto_nmap.sh automation script which integrates multiple 
reconnaissance and enumeration tools.

---

## Table of Contents

1. [Scan Summary](#scan-summary)
2. [Open Ports and Services](#open-ports-and-services)
3. [Discovered Domains](#discovered-domains)
4. [Discovered Credentials](#discovered-credentials)
5. [Virtual Hosts](#virtual-hosts)
6. [SMB/Share Information](#smbshare-information)
7. [Recommendations](#recommendations)
8. [Tool Output Files](#tool-output-files)

---

## Scan Summary

| Parameter | Value |
|-----------|-------|
| Target | soulmate.htb |
| Scan Date | 2026-01-19 10:11:45 |
| Output Directory | /mnt/htba/automations/nmap_scan_20260119_095441 |
| Host Pingable | true |
| TTL Value | 63 |
| Probable OS (TTL-based) | Linux/Unix/macOS |

## Open Ports and Services

| Port | Service | Version |
|------|---------|---------|

## Discovered Domains

- cdnjs.cloudflare.com
- cdn.jsdelivr.net
- images.pexels.com
- soulmate.htb

## Discovered Credentials

⚠️ **SENSITIVE INFORMATION** - Handle with care

_No credentials discovered during automated scanning._

## Virtual Hosts

_No virtual hosts discovered._

## SMB/Share Information

_No SMB shares discovered._

## Recommendations

Based on the automated scan results, consider the following next steps:

1. **Manual Verification**: Verify all findings manually before exploitation
2. **Credential Testing**: Test discovered credentials against all services
3. **Web Application Testing**: Perform detailed web application security testing
4. **Vulnerability Scanning**: Run targeted vulnerability scans based on service versions
5. **Documentation**: Document all findings in the case folder

## Tool Output Files

All scan outputs are stored in the following locations:

| Directory | Contents |
|-----------|----------|
| scans/ | Nmap XML, nmap, gnmap outputs |
| logs/ | Tool-specific output logs |
| evidence/ | Screenshots and proof files |
| loot/ | Exfiltrated files and data |

### Key Output Files

```
commands_executed.txt
discovered_credentials.txt
discovered_domains.txt
discovered_vhosts.txt
logs/soulmate.htb_80_finalrecon.txt
logs/soulmate.htb_80_gobuster_vhost.txt
logs/soulmate.htb_80_whatweb.txt
scan_log.txt
scans/soulmate.htb_host_discovery.xml
scans/soulmate.htb_initial_scan.xml
soulmate.htb_80_curl_composer.json.txt
soulmate.htb_80_curl_.env.txt
soulmate.htb_80_curl_.git_config.txt
soulmate.htb_80_curl_headers.txt
soulmate.htb_80_curl_options.txt
soulmate.htb_80_curl_package.json.txt
soulmate.htb_80_curl_README.md.txt
soulmate.htb_80_curl_robots.txt
soulmate.htb_80_curl_security.txt.txt
soulmate.htb_80_curl_sitemap.xml
soulmate.htb_80_curl_.well-known_security.txt.txt
soulmate.htb_80_nikto.txt
soulmate.htb_80_reconspider.txt
soulmate.htb_80_wafw00f.txt
suggested_hosts_entries.txt
```
