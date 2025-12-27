# Nmap Performance Optimization Summary

## Overview

Nmap performance is crucial for large networks or low-bandwidth environments. Options control speed, packet frequency, timeouts, retries, and rates. Trade-offs: Faster scans may miss hosts/ports; balance speed with accuracy.

## Timeouts (RTT - Round-Trip-Time)

Nmap starts with 100ms initial timeout. Adjust for faster scans, but too low may miss hosts.

**Default Scan (Top 100 Ports on /24 Network):**

```bash
sudo nmap 10.129.2.0/24 -F
```

- Time: 39.44 seconds
- Hosts up: 10

**Optimized RTT:**

```bash
sudo nmap 10.129.2.0/24 -F --initial-rtt-timeout 50ms --max-rtt-timeout 100ms
```

- Time: 12.29 seconds
- Hosts up: 8 (missed 2 hosts due to short timeout)

## Max Retries

Default: 10 retries. Reduce to 0 for speed, but may skip unresponsive ports.

**Default Scan (Count Open Ports):**

```bash
sudo nmap 10.129.2.0/24 -F | grep "/tcp" | wc -l
```

- Open ports: 23

**Reduced Retries:**

```bash
sudo nmap 10.129.2.0/24 -F --max-retries 0 | grep "/tcp" | wc -l
```

- Open ports: 21 (missed 2 ports)

## Rates (Packet Sending)

Set minimum rate (--min-rate) for simultaneous packets. Useful in whitelisted environments.

**Default Scan:**

```bash
sudo nmap 10.129.2.0/24 -F -oN tnet.default
```

- Time: 29.83 seconds
- Open ports: 23

**Optimized Scan (300 packets/sec):**

```bash
sudo nmap 10.129.2.0/24 -F -oN tnet.minrate300 --min-rate 300
```

- Time: 8.67 seconds
- Open ports: 23

## Timing Templates (-T <0-5>)

Predefined aggressiveness levels. Default: -T 3 (normal). Higher values faster but riskier (detection/blocking).

- **-T 0 / paranoid**: Slowest, least intrusive.
- **-T 1 / sneaky**: Slow, evasive.
- **-T 2 / polite**: Reduces load.
- **-T 3 / normal**: Balanced (default).
- **-T 4 / aggressive**: Faster, more traffic.
- **-T 5 / insane**: Fastest, high risk.

**Default Scan:**

```bash
sudo nmap 10.129.2.0/24 -F -oN tnet.default
```

- Time: 32.44 seconds
- Open ports: 23

**Insane Scan (-T 5):**

```bash
sudo nmap 10.129.2.0/24 -F -oN tnet.T5 -T 5
```

- Time: 18.07 seconds
- Open ports: 23

## Additional Relevant Information and Tools

- **Trade-offs:** Aggressive settings (-T 5, low retries) speed up scans but increase false negatives and detection risk. Use in controlled environments.
- **Parallelism:** --min-parallelism sets concurrent probes (default adapts).
- **Host Groups:** --max-hostgroup limits simultaneous hosts.
- **Alternatives:** For ultra-fast port scanning, use Masscan (masscan -p1-65535 10.129.2.0/24 --rate=100000). Integrate with Nmap for service detection.
- **Monitoring:** Use --stats-every for progress. Avoid in production to prevent DoS.
- **Best Practices:** Start with -T 4 for speed, adjust RTT based on network latency (ping test first). Save results (-oA) for comparison.
- **Further Reading:** Timing templates details at <https://nmap.org/book/performance-timing-templates.html>. Full performance guide at <https://nmap.org/book/man-performance.html>.
