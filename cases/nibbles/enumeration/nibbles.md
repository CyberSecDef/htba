# Case: Nibbles - Enumeration

## Target Information

| Property | Value |
|----------|-------|
| **IP Address** | 10.129.116.32 |
| **Machine Name** | Nibbles |
| **Creator** | mrb3n |
| **Operating System** | Linux |
| **Difficulty** | Easy |
| **User Path** | Web |
| **Privilege Escalation** | World-writable File / Sudoers Misconfiguration |
| **IppSec Video** | https://www.youtube.com/watch?v=s_0GcRGv6Ds |
| **Walkthrough** | https://0xdf.gitlab.io/2018/06/30/htb-nibbles.html |

## Enumeration

### Initial Port Scan

```bash
nmap -sV --open -oA nibbles_initial_scan 10.129.116.32
```

**Results**:
```
Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-12-26 08:20 CST
Nmap scan report for 10.129.116.32
Host is up (0.12s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.2 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/.
Nmap done: 1 IP address (1 host up) scanned in 9.92 seconds
```

### Full TCP Scan

```bash
nmap -p- --open -oA nibbles_full_tcp_scan 10.129.116.32
```

**Results**:
```
Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-12-26 08:24 CST
Nmap scan report for 10.129.116.32
Host is up (0.12s latency).
Not shown: 65008 closed tcp ports (reset), 525 filtered tcp ports (no-response)
Some closed ports may be reported as filtered due to --defeat-rst-ratelimit
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http

Nmap done: 1 IP address (1 host up) scanned in 39.52 seconds
```

### Script Scan

```bash
nmap -sC -p 22,80 -oA nibbles_script_scan 10.129.116.32
```

**Results**:
```
Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-12-26 08:28 CST
Nmap scan report for 10.129.116.32
Host is up (0.12s latency).

PORT   STATE SERVICE
22/tcp open  ssh
| ssh-hostkey: 
|   2048 c4:f8:ad:e8:f8:04:77:de:cf:15:0d:63:0a:18:7e:49 (RSA)
|   256 22:8f:b1:97:bf:0f:17:08:fc:7e:2c:8f:e9:77:3a:48 (ECDSA)
|_  256 e6:ac:27:a3:b5:a9:f1:12:3c:34:a5:5d:5b:eb:3d:e9 (ED25519)
80/tcp open  http
```
