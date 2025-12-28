# Host and Port Scanning with Nmap Summary

After host discovery, scan ports/services. Understand states: open (connection established), closed (RST), filtered (no response/error), unfiltered (ACK scan), open|filtered (no response), closed|filtered (idle scan).

## Discovering Open TCP Ports

- Default: SYN scan (-sS) as root; else Connect (-sT).
- Ports: Specific (-p 22,25), range (-p 22-445), top (--top-ports=10), all (-p-), fast (-F, top 100).

**Example Top 10**:

- Command: `sudo nmap 10.129.2.28 --top-ports=10`
- Output: States (open/closed/filtered).

**Packet Trace**:

- Command: `sudo nmap 10.129.2.28 -p 21 --packet-trace -Pn -n --disable-arp-ping`
- Shows SYN sent, RST/ACK received (closed).

## Connect Scan

- Full TCP handshake: SYN → SYN-ACK → ACK.
- Accurate; logs on systems; detectable.
- "Polite" but not stealthy.

**Example on Port 443**:

- Command: `sudo nmap 10.129.2.28 -p 443 --packet-trace --disable-arp-ping -Pn -n --reason -sT`
- Output: Connected (open).

## Filtered Ports

- Firewall drops: No response; retries (--max-retries=10).
- Rejects: ICMP unreachable.

**Example Drop (Port 139)**:

- Command: `sudo nmap 10.129.2.28 -p 139 --packet-trace -n --disable-arp-ping -Pn`
- Multiple SYN sent; no response.

**Example Reject (Port 445)**:

- Command: `sudo nmap 10.129.2.28 -p 445 --packet-trace -n --disable-arp-ping -Pn`
- ICMP type 3/code 3 (unreachable).

## Discovering Open UDP Ports

- Stateless; no handshake; slower timeouts.
- Useful if TCP filtered but UDP not.

**Example UDP Scan**:

- Command: `sudo nmap 10.129.2.28 -F -sU`
- Fast scan (-F) on top 100 UDP.

**Additional**: Other TCP scans: ACK (-sA), Window (-sW), Maimon (-sM). For UDP: Version scan (-sV) for services. Tools: Masscan for speed. Always root. Practice on HTB. Reference: nmap.org/book/scan-methods.html.
