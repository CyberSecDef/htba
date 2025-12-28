# Web Enumeration Summary

Web servers (ports 80/443) host apps with high attack surface. Enumerate for hidden dirs/files, subdomains, tech stack, vulns. Critical for limited exposed services.

## Gobuster

- Versatile: DNS, vhost, dir brute-forcing, AWS S3.
- Dir mode: Brute-force dirs/files.

**Dir Scan**:

- Command: `gobuster dir -u http://10.10.10.121/ -w /usr/share/seclists/Discovery/Web-Content/common.txt`
- Output: Status codes (200: OK, 403: Forbidden, 301: Redirect).
- Example: Finds /wordpress (WordPress setup → RCE).

**DNS Subdomain Scan**:

- Install SecLists: `git clone https://github.com/danielmiessler/SecLists` or `sudo apt install seclists -y`.
- Add DNS server to resolv.conf (e.g., nameserver 1.1.1.1).
- Command: `gobuster dns -d inlanefreight.com -w /usr/share/SecLists/Discovery/DNS/namelist.txt`
- Output: Subdomains (e.g., blog.inlanefreight.com).

**Additional**: Alternatives: ffuf (`ffuf -u http://target/FUZZ -w wordlist`), dirb (`dirb http://target wordlist`), wfuzz. Module: Attacking Web Applications with Ffuf.

## Web Enumeration Tips

### Banner Grabbing / Web Server Headers

- Reveal framework, auth, misconfigs.
- Command: `curl -IL https://www.inlanefreight.com` (shows Apache/2.4.29, WordPress links).

**Additional**: EyeWitness for screenshots/fingerprinting/default creds.

### Whatweb

- Identifies web tech, versions.
- Command: `whatweb 10.10.10.121` (shows Apache 2.4.41, PHP 7.4.3).
- Network scan: `whatweb --no-errors 10.10.10.0/24` (multiple targets).

**Additional**: Wappalyzer (browser extension) for tech detection.

### Certificates

- SSL/TLS info (email, company) for phishing.
- View in browser or `openssl s_client -connect target:443` (cert details).

### Robots.txt

- Instructs crawlers; reveals hidden paths.
- Command: `curl 10.10.10.121/robots.txt` (shows /private, /uploaded_files).
- Example: /private → admin login.

### Source Code

- Comments/creds.
- Browser: Ctrl+U (view source).
- Example: HTML comment with test creds.

**Additional**: Burp Suite for intercepting/modifying requests. Nikto: `nikto -h target` (web vuln scan). Always check for backups (.bak, .old).
