# Nmap Firewall and IDS/IPS Evasion Summary

## Overview

Nmap provides techniques to bypass firewalls and IDS/IPS systems, including packet fragmentation, decoys, source IP spoofing, and port manipulation. Firewalls block/drop packets; IDS detects patterns; IPS prevents attacks. Use evasion to avoid detection and blocking.

## Determining Firewalls and Rules

Firewalls drop or reject packets. Dropped: No response. Rejected: RST (TCP) or ICMP errors (e.g., Port Unreachable).

**TCP ACK Scan (-sA):** Harder to filter than SYN/Connect scans. Sends ACK packets; open/closed ports respond with RST. Firewalls often allow ACK from established connections.

**SYN Scan (Filtered Ports):**

```bash
sudo nmap 10.129.2.28 -p 21,22,25 -sS -Pn -n --disable-arp-ping --packet-trace
```

- Port 21: ICMP Port Unreachable (filtered)
- Port 22: SYN-ACK (open)
- Port 25: No response (filtered)

**ACK Scan:**

```bash
sudo nmap 10.129.2.28 -p 21,22,25 -sA -Pn -n --disable-arp-ping --packet-trace
```

- Port 21: ICMP Port Unreachable (filtered)
- Port 22: RST (unfiltered, likely open)
- Port 25: No response (filtered)

## Detecting IDS/IPS

IDS monitors traffic passively; IPS blocks actively. Use multiple VPS IPs to test blocking. If one IP blocked, switch. Aggressive scans trigger alerts.

## Decoys (-D)

Spoof source IPs to disguise origin. Use random IPs (RND:number) or specific ones. Real IP mixed in randomly. Decoys must be alive to avoid SYN floods.

**Decoy Scan:**

```bash
sudo nmap 10.129.2.28 -p 80 -sS -Pn -n --disable-arp-ping --packet-trace -D RND:5
```

- Sends packets from 5 random IPs + real IP.

## Source IP Spoofing (-S)

Spoof source IP to bypass subnet blocks. Combine with interface (-e).

**Default OS Scan (Port 445 Filtered):**

```bash
sudo nmap 10.129.2.28 -n -Pn -p445 -O
```

- Port 445: filtered

**Spoofed Source IP:**

```bash
sudo nmap 10.129.2.28 -n -Pn -p 445 -O -S 10.129.2.200 -e tun0
```

- Port 445: open (bypassed filter)

## DNS Proxying

Use trusted DNS servers (--dns-server) in DMZ. Spoof source port 53 (--source-port) for trusted traffic.

**SYN Scan on Filtered Port 50000:**

```bash
sudo nmap 10.129.2.28 -p50000 -sS -Pn -n --disable-arp-ping --packet-trace
```

- Filtered

**From Source Port 53:**

```bash
sudo nmap 10.129.2.28 -p50000 -sS -Pn -n --disable-arp-ping --packet-trace --source-port 53
```

- Open (bypassed)

**Netcat Connection from Port 53:**

```bash
ncat -nv --source-port 53 10.129.2.28 50000
```

- Connected: "220 ProFTPd"

## Additional Relevant Information and Tools

- **Fragmentation:** --mtu or -f splits packets to evade filters.
- **Data Length:** --data-length adds junk data to packets.
- **Timing:** -T 0-2 for slow, evasive scans.
- **Other Tools:** hping3 for custom packet crafting (e.g., `hping3 --scan 1-100 -S 10.129.2.28`). Scapy for Python scripting.
- **MAC Spoofing:** --spoof-mac for layer 2 evasion.
- **Proxy Chains:** Use proxychains with Nmap for multi-hop evasion.
- **Best Practices:** Combine techniques (e.g., decoys + spoofing). Test on non-production. Monitor for blocking. Use --badsum for malformed packets.
- **Limitations:** Spoofing may not work if responses needed; use live decoys. ISPs filter spoofed packets.
- **Further Reading:** Nmap evasion guide at <https://nmap.org/book/man-bypass-firewalls-ids.html>.
