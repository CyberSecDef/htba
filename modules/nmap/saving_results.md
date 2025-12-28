# Nmap Saving Results Summary

## Overview
Nmap allows saving scan results in multiple formats for later analysis, comparison, and reporting. This is crucial for documenting findings, tracking changes between scans, and generating reports. Formats include normal output, grepable output, and XML output. You can save in all formats simultaneously using the `-oA` option.

## Output Formats
Nmap supports three primary output formats:

1. **Normal Output (-oN)**: Human-readable format with `.nmap` extension. Includes scan details, host info, ports, and services.
2. **Grepable Output (-oG)**: Designed for easy parsing with tools like `grep`. Uses `.gnmap` extension. Contains comma-separated values for ports and services.
3. **XML Output (-oX)**: Structured format for scripting and reporting. Uses `.xml` extension. Can be converted to HTML for readable reports.

### Saving in All Formats (-oA)
Use `-oA <basename>` to save results in all three formats with the specified basename. Files are saved in the current directory unless a full path is provided.

**Command Example:**
```bash
sudo nmap 10.129.2.28 -p- -oA target
```

**Sample Output (from command above):**
```
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-16 12:14 CEST
Nmap scan report for 10.129.2.28
Host is up (0.0091s latency).
Not shown: 65525 closed ports
PORT      STATE SERVICE
22/tcp    open  ssh
25/tcp    open  smtp
80/tcp    open  http
MAC Address: DE:AD:00:00:BE:EF (Intel Corporate)

Nmap done: 1 IP address (1 host up) scanned in 10.22 seconds
```

**Generated Files:**
- `target.nmap` (normal)
- `target.gnmap` (grepable)
- `target.xml` (XML)

### Normal Output (-oN)
Readable format similar to console output. Includes headers, scan command, host details, ports, and timestamps.

**Example Content (target.nmap):**
```
# Nmap 7.80 scan initiated Tue Jun 16 12:14:53 2020 as: nmap -p- -oA target 10.129.2.28
Nmap scan report for 10.129.2.28
Host is up (0.053s latency).
Not shown: 4 closed ports
PORT   STATE SERVICE
22/tcp open  ssh
25/tcp open  smtp
80/tcp open  http
MAC Address: DE:AD:00:00:BE:EF (Intel Corporate)

# Nmap done at Tue Jun 16 12:15:03 2020 -- 1 IP address (1 host up) scanned in 10.22 seconds
```

### Grepable Output (-oG)
Optimized for `grep` searches. Contains host status and ports in a single line per host.

**Example Content (target.gnmap):**
```
# Nmap 7.80 scan initiated Tue Jun 16 12:14:53 2020 as: nmap -p- -oA target 10.129.2.28
Host: 10.129.2.28 ()    Status: Up
Host: 10.129.2.28 ()    Ports: 22/open/tcp//ssh///, 25/open/tcp//smtp///, 80/open/tcp//http///  Ignored State: closed (4)
# Nmap done at Tue Jun 16 12:14:53 2020 -- 1 IP address (1 host up) scanned in 10.22 seconds
```

### XML Output (-oX)
Machine-readable format. Includes detailed metadata, scan info, host details, ports, and statistics. Useful for integration with other tools or scripts.

**Example Content (target.xml):**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE nmaprun>
<?xml-stylesheet href="file:///usr/local/bin/../share/nmap/nmap.xsl" type="text/xsl"?>
<!-- Nmap 7.80 scan initiated Tue Jun 16 12:14:53 2020 as: nmap -p- -oA target 10.129.2.28 -->
<nmaprun scanner="nmap" args="nmap -p- -oA target 10.129.2.28" start="12145301719" startstr="Tue Jun 16 12:15:03 2020" version="7.80" xmloutputversion="1.04">
<scaninfo type="syn" protocol="tcp" numservices="65535" services="1-65535"/>
<verbose level="0"/>
<debugging level="0"/>
<host starttime="12145301719" endtime="12150323493"><status state="up" reason="arp-response" reason_ttl="0"/>
<address addr="10.129.2.28" addrtype="ipv4"/>
<address addr="DE:AD:00:00:BE:EF" addrtype="mac" vendor="Intel Corporate"/>
<hostnames>
</hostnames>
<ports><extraports state="closed" count="4">
<extrareasons reason="resets" count="4"/>
</extraports>
<port protocol="tcp" portid="22"><state state="open" reason="syn-ack" reason_ttl="64"/><service name="ssh" method="table" conf="3"/></port>
<port protocol="tcp" portid="25"><state state="open" reason="syn-ack" reason_ttl="64"/><service name="smtp" method="table" conf="3"/></port>
<port protocol="tcp" portid="80"><state state="open" reason="syn-ack" reason_ttl="64"/><service name="http" method="table" conf="3"/></port>
</ports>
<times srtt="52614" rttvar="75640" to="355174"/>
</host>
<runstats><finished time="12150323493" timestr="Tue Jun 16 12:14:53 2020" elapsed="10.22" summary="Nmap done at Tue Jun 16 12:15:03 2020; 1 IP address (1 host up) scanned in 10.22 seconds" exit="success"/><hosts up="1" down="0" total="1"/>
</runstats>
</nmaprun>
```

## Converting XML to HTML
Use `xsltproc` to convert XML output to HTML for easy, non-technical reporting.

**Command:**
```bash
xsltproc target.xml -o target.html
```

This generates a styled HTML report viewable in a browser, useful for documentation.

## Additional Relevant Information and Tools
- **Parsing Outputs:** 
  - Use `grep` on `.gnmap` files for quick searches, e.g., `grep "open" target.gnmap`.
  - Parse XML with Python libraries like `xml.etree.ElementTree` or `lxml` for automated analysis.
- **Comparison Tools:** Use `diff` or `vimdiff` to compare saved results from different scans, e.g., `diff scan1.nmap scan2.nmap`.
- **Integration:** XML output can be imported into tools like Metasploit (`db_import`) or custom scripts for vulnerability management.
- **Best Practices:** Always save results with `-oA` for flexibility. Use timestamps in filenames for versioning, e.g., `nmap -p- -oA scan_$(date +%Y%m%d_%H%M%S) target`.
- **Security Note:** Be cautious with saved files containing sensitive data; encrypt or restrict access.
- **Further Reading:** Official Nmap output documentation at https://nmap.org/book/output.html.

## Nmap Cheatsheet (Relevant Options)
### Scanning Options
- `-sn`: Disables port scanning (host discovery only).
- `-Pn`: Disables ICMP Echo Requests.
- `-n`: Disables DNS Resolution.
- `-PE`: ICMP Echo ping.
- `--packet-trace`: Shows packets sent/received.
- `--reason`: Displays result reasons.
- `--disable-arp-ping`: Disables ARP pings.
- `--top-ports=<num>`: Scans top frequent ports.
- `-p-`: All ports.
- `-p22-110`: Port range.
- `-p22,25`: Specific ports.
- `-F`: Top 100 ports.
- `-sS`: TCP SYN scan.
- `-sA`: TCP ACK scan.
- `-sU`: UDP scan.
- `-sV`: Service version detection.
- `-sC`: Default script scan.
- `--script <script>`: Custom scripts.
- `-O`: OS detection.
- `-A`: OS, service, traceroute.
- `-D RND:5`: Decoys.
- `-e`: Network interface.
- `-S <IP>`: Source IP spoofing.
- `-g`: Source port.
- `--dns-server <ns>`: Custom DNS server.

### Output Options
- `-oA <file>`: All formats.
- `-oN <file>`: Normal.
- `-oG <file>`: Grepable.
- `-oX <file>`: XML.

### Performance Options
- `--max-retries <num>`: Retry count.
- 
