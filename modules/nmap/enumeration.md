# Enumeration with Nmap Summary

Enumeration: Collect info for attack vectors. Focus on misconfigs, service interactions. Manual key; tools aid but don't replace knowledge. Nmap: Core tool for scanning.

## Enumeration Principles

- Goal: Find interaction points/resources, gather intel.
- Misconfigs from ignorance/security mindset gaps.
- Manual: Interact with services; understand protocols/syntax.
- Tools: Simplify but may miss slow-responding services (timeouts mark as closed/filtered).
- Analogy: Vague "living room" vs. specific "third drawer next to TV".

**Additional**: Phases: Passive (OSINT), Active (scanning). Always scope-check.

## Nmap Basics

- Versatile scanner: Hosts, ports, services, OS.
- Syntax: `nmap [options] target`
- Targets: IP, range (10.10.10.0/24), hostname.

## Cheatsheet

### Scanning Options

- `10.10.10.0/24`: Target range.
- `-sn`: Host discovery only.
- `-Pn`: Skip ping.
- `-n`: No DNS.
- `-PE`: ICMP ping.
- `--packet-trace`: Show packets.
- `--reason`: Result reasons.
- `--disable-arp-ping`: No ARP.
- `--top-ports=<num>`: Top ports.
- `-p-`: All ports.
- `-p22-110`: Range.
- `-p22,25`: Specific.
- `-F`: Top 100.
- `-sS`: SYN scan.
- `-sA`: ACK scan.
- `-sU`: UDP scan.
- `-sV`: Version scan.
- `-sC`: Default scripts.
- `--script <script>`: Specific script.
- `-O`: OS detection.
- `-A`: Aggressive (OS, service, traceroute).
- `-D RND:5`: Decoys.
- `-e`: Interface.
- `-S 10.10.10.200`: Spoof source IP.
- `-g`: Source port.
- `--dns-server <ns>`: Custom DNS.

### Output Options

- `-oA filename`: All formats.
- `-oN filename`: Normal.
- `-oG filename`: Grepable.
- `-oX filename`: XML.

### Performance Options

- `--max-retries <num>`: Retries.
- `--stats-every=5s`: Status.
- `-v/-vv`: Verbose.
- `--initial-rtt-timeout 50ms`: Initial RTT.
- `--max-rtt-timeout 100ms`: Max RTT.
- `--min-rate 300`: Packet rate.
- `-T <0-5>`: Timing (0 slow, 5 fast).

**Additional**: Timing: `-T4` for fast scans. Scripts: NSE for custom. For evasion: `-f` (fragment), `--spoof-mac`. Practice on HTB; combine with other tools (e.g., Masscan for speed). Module: Network Enumeration with Nmap for deep dive.
