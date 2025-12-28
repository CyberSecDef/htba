# Nmap Service Enumeration Summary

## Overview

Service enumeration identifies running services, their versions, and potential vulnerabilities. Accurate version detection is crucial for finding exploits. Nmap's `-sV` option performs service version detection via banner grabbing and signature matching. Combine with port scanning for efficiency.

## Service Version Detection (-sV)

Perform a quick port scan first to identify open ports, then use `-sV` for version detection. Full scans (-p-) are time-consuming; monitor progress with spacebar or `--stats-every`.

**Basic Command:**

```bash
sudo nmap 10.129.2.28 -p- -sV
```

**With Progress Updates:**

```bash
sudo nmap 10.129.2.28 -p- -sV --stats-every=5s
```

**Verbose Output:**

```bash
sudo nmap 10.129.2.28 -p- -sV -v
```

**Sample Output (Full Scan):**

```
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-15 20:00 CEST
Nmap scan report for 10.129.2.28
Host is up (0.013s latency).
Not shown: 65525 closed ports
PORT      STATE    SERVICE      VERSION
22/tcp    open     ssh          OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
25/tcp    open     smtp         Postfix smtpd
80/tcp    open     http         Apache httpd 2.4.29 ((Ubuntu))
110/tcp   open     pop3         Dovecot pop3d
139/tcp   filtered netbios-ssn
143/tcp   open     imap         Dovecot imapd (Ubuntu)
445/tcp   filtered microsoft-ds
993/tcp   open     ssl/imap     Dovecot imapd (Ubuntu)
995/tcp   open     ssl/pop3     Dovecot pop3d
MAC Address: DE:AD:00:00:BE:EF (Intel Corporate)
Service Info: Host:  inlane; OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 91.73 seconds
```

**With Packet Trace (for debugging):**

```bash
sudo nmap 10.129.2.28 -p- -sV -Pn -n --disable-arp-ping --packet-trace
```

**Sample Packet Trace Output:**

```
NSOCK INFO [0.4200s] nsock_trace_handler_callback(): Callback: READ SUCCESS for EID 18 [10.129.2.28:25] (35 bytes): 220 inlane ESMTP Postfix (Ubuntu)..
Service scan match (Probe NULL matched with NULL line 3104): 10.129.2.28:25 is smtp.  Version: |Postfix smtpd|||
```

## Banner Grabbing

Nmap grabs banners after TCP handshake. Servers send banners (e.g., SMTP: "220 inlane ESMTP Postfix (Ubuntu)"). Nmap may miss details; manual grabbing reveals more.

**Manual Banner Grabbing with nc:**

```bash
nc -nv 10.129.2.28 25
```

**Output:**

```
Connection to 10.129.2.28 port 25 [tcp/*] succeeded!
220 inlane ESMTP Postfix (Ubuntu)
```

**Intercept Traffic with tcpdump:**

```bash
sudo tcpdump -i eth0 host 10.10.14.2 and 10.129.2.28
```

**Sample tcpdump Output (Three-Way Handshake + Banner):**

```
18:28:07.128564 IP 10.10.14.2.59618 > 10.129.2.28.smtp: Flags [S], seq 1798872233, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 331260178 ecr 0,sackOK,eol], length 0
18:28:07.255151 IP 10.129.2.28.smtp > 10.10.14.2.59618: Flags [S.], seq 1130574379, ack 1798872234, win 65160, options [mss 1460,sackOK,TS val 1800383922 ecr 331260178,nop,wscale 7], length 0
18:28:07.255281 IP 10.10.14.2.59618 > 10.129.2.28.smtp: Flags [.], ack 1, win 2058, options [nop,nop,TS val 331260304 ecr 1800383922], length 0
18:28:07.319306 IP 10.129.2.28.smtp > 10.10.14.2.59618: Flags [P.], seq 1:36, ack 1, win 510, options [nop,nop,TS val 1800383985 ecr 331260304], length 35: SMTP: 220 inlane ESMTP Postfix (Ubuntu)
18:28:07.319426 IP 10.10.14.2.59618 > 10.129.2.28.smtp: Flags [.], ack 36, win 2058, options [nop,nop,TS val 331260368 ecr 1800383985], length 0
```

## Additional Relevant Information and Tools

- **Aggressive Scanning:** Use `-A` for OS, service, and traceroute detection alongside version scanning.
- **SSL/TLS Services:** For SSL ports (e.g., 443, 993), use `openssl s_client` for banner grabbing: `openssl s_client -connect 10.129.2.28:993`.
- **Alternative Banner Grabbers:** `telnet` for interactive banners: `telnet 10.129.2.28 25`. Or `curl` for HTTP: `curl -I http://10.129.2.28`.
- **Vulnerability Scanning:** Use version info with `searchsploit` (from Exploit-DB): `searchsploit "Apache 2.4.29"`. Or integrate with Nessus/OpenVAS.
- **Scripting Engine:** Nmap scripts (e.g., `--script banner`) for enhanced banner grabbing.
- **Evasion:** Services may hide banners; use `--script http-headers` for web servers.
- **Performance Tips:** Limit ports with `-p` for faster scans. Use `-T4` for balanced timing.
- **Reporting:** Save with `-oA` and convert XML to HTML for reports.

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

Similar code found with 2 license types
