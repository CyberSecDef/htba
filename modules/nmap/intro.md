# Introduction to Nmap Summary

Nmap (Network Mapper): Open-source tool in C/C++/Python/Lua for network analysis/security auditing. Scans hosts, ports, services, OS. Uses raw packets; detects firewalls/IDS.

## Use Cases

- Audit networks/security.
- Simulate pentes.
- Check firewalls/IDS.
- Network mapping.
- Identify open ports/connections.
- Vuln assessment.

**Additional**: Recon, compliance checks (e.g., PCI).

## Architecture

- Host Discovery: Find live hosts.
- Port Scanning: Identify open/closed/filtered ports.
- Service Enumeration/Detection: Fingerprint services/versions.
- OS Detection: Identify OS.
- NSE (Nmap Scripting Engine): Scriptable interactions.

## Syntax

- `nmap <scan types> <options> <target>`
- Targets: IP, range, hostname.

## Scan Techniques

- TCP: SYN (-sS), Connect (-sT), ACK (-sA), Window (-sW), Maimon (-sM).
- UDP: -sU.
- Stealth: Null (-sN), FIN (-sF), Xmas (-sX).
- Advanced: Idle (-sI), SCTP (-sY/-sZ), IP protocol (-sO), FTP bounce (-b).
- Custom flags: `--scanflags <flags>`.

**Example SYN Scan**:

- Command: `sudo nmap -sS localhost`
- Output: Open ports (e.g., 22/tcp open ssh).
- How: Sends SYN; SYN-ACK = open; RST = closed; no response = filtered.

**Additional**: TCP handshake: SYN → SYN-ACK → ACK (full connect). SYN scan stealthy (half-open).

## Cheatsheet

### Scanning Options

- `10.10.10.0/24`: Range.
- `-sn`: No port scan.
- `-Pn`: No ping.
- `-n`: No DNS.
- `-PE`: ICMP ping.
- `--packet-trace`: Packets.
- `--reason`: Reasons.
- `--disable-arp-ping`: No ARP.
- `--top-ports=<num>`: Top ports.
- `-p-`: All.
- `-p22-110`: Range.
- `-p22,25`: Specific.
- `-F`: 100.
- `-sS`: SYN.
- `-sA`: ACK.
- `-sU`: UDP.
- `-sV`: Versions.
- `-sC`: Default scripts.
- `--script <script>`: Script.
- `-O`: OS.
- `-A`: Aggressive.
- `-D RND:5`: Decoys.
- `-e`: Interface.
- `-S 10.10.10.200`: Spoof IP.
- `-g`: Source port.
- `--dns-server <ns>`: DNS.

### Output Options

- `-oA filename`: All.
- `-oN filename`: Normal.
- `-oG filename`: Grepable.
- `-oX filename`: XML.

### Performance Options

- `--max-retries <num>`: Retries.
- `--stats-every=5s`: Status.
- `-v/-vv`: Verbose.
- `--initial-rtt-timeout 50ms`: RTT.
- `--max-rtt-timeout 100ms`: Max RTT.
- `--min-rate 300`: Rate.
- `-T <0-5>`: Timing.

**General Tips**: Root for raw sockets. Install: `sudo apt install nmap`. Practice on HTB. Combine with Wireshark for packets. For large scans: `-T4 --min-rate 1000`. Module: Network Enumeration with Nmap.
