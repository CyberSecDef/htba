# Host Discovery with Nmap Summary

Host discovery: Identify live hosts before port/service scans. Use ICMP/ARP; store results for comparison/reporting. Firewalls may block; use evasion techniques.

## Scan Network Range

- Command: `sudo nmap 10.129.2.0/24 -sn -oA tnet | grep for | cut -d" " -f5`
- Output: Live IPs.
- Options: `-sn` (no port scan), `-oA` (all formats).

**Additional**: Filter output with `awk`, `grep`.

## Scan IP List

- Create list: `cat hosts.lst` (one IP per line).
- Command: `sudo nmap -sn -oA tnet -iL hosts.lst | grep for | cut -d" " -f5`
- Output: Active from list.

**Additional**: Generate list: `for i in {1..254}; do echo 10.10.10.$i; done > ips.txt`

## Scan Multiple IPs

- Command: `sudo nmap -sn -oA tnet 10.129.2.18 10.129.2.19 10.129.2.20 | grep for | cut -d" " -f5`
- Or range: `sudo nmap -sn -oA tnet 10.129.2.18-20 | grep for | cut -d" " -f5`

## Scan Single IP

- Command: `sudo nmap 10.129.2.18 -sn -oA host`
- Output: Up/down, MAC.
- Force ICMP: `-PE`
- Trace packets: `--packet-trace`
- Reason: `--reason`
- Disable ARP: `--disable-arp-ping` (for ICMP only).

**Example with Trace**:

- `sudo nmap 10.129.2.18 -sn -oA host -PE --packet-trace --disable-arp-ping`
- Shows ICMP echo request/reply.

**Additional**: Other pings: TCP SYN (-PS), UDP (-PU), SCTP (-PY). Tools: fping, hping3. For large nets: Masscan. Always root for ARP. Reference: nmap.org/book/host-discovery-strategies.html. Practice on HTB.
