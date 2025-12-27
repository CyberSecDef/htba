# Target: 10.129.164.215
### 1. Which version of the FTP server is running on the target system? Submit the entire banner as the answer.
```
$> sudo nmap -sV -p21 -sC -A  10.129.164.215

Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-12-27 12:23 CST
Nmap scan report for 10.129.164.215
Host is up (0.0092s latency).

PORT   STATE SERVICE VERSION
21/tcp open  ftp
| fingerprint-strings: 
|   GenericLines: 
|     220 InFreight FTP v1.1
|     Invalid command: try being more creative
|_    Invalid command: try being more creative
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port21-TCP:V=7.94SVN%I=7%D=12/27%Time=69502430%P=x86_64-pc-linux-gnu%r(
SF:GenericLines,74,"220\x20InFreight\x20FTP\x20v1\.1\r\n500\x20Invalid\x20
SF:command:\x20try\x20being\x20more\x20creative\r\n500\x20Invalid\x20comma
SF:nd:\x20try\x20being\x20more\x20creative\r\n");
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: Linux 5.0 - 5.5 (96%), Linux 4.15 - 5.8 (95%), Linux 3.1 (95%), Linux 3.2 (95%), Linux 5.3 - 5.4 (95%), AXIS 210A or 211 Network Camera (Linux 2.6.17) (95%), Linux 2.6.32 (94%), ASUS RT-N56U WAP (Linux 3.4) (93%), Linux 3.16 (93%), Linux 5.0 - 5.4 (93%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops

TRACEROUTE (using port 21/tcp)
HOP RTT     ADDRESS
1   8.60 ms 10.10.14.1
2   9.06 ms 10.129.164.215

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 66.66 seconds
```


### 2.  Enumerate the FTP server and find the flag.txt file. Submit the contents of it as the answer.
```
nmap -Pn --script ftp-anon -p21 10.129.164.215
Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-12-27 12:47 CST
Nmap scan report for 10.129.164.215
Host is up (0.0098s latency).

PORT   STATE SERVICE
21/tcp open  ftp
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
|_-rw-r--r--   1 ftpuser  ftpuser        39 Nov  8  2021 flag.txt

Nmap done: 1 IP address (1 host up) scanned in 6.58 seconds
```

ftp anonymous@10.129.164.215
Connected to 10.129.164.215.
220 InFreight FTP v1.1
331 Anonymous login ok, send your complete email address as your password
Password: 
230 Anonymous access granted, restrictions apply
Remote system type is UNIX.
Using binary mode to transfer files.

ftp> ls
229 Entering Extended Passive Mode (|||34876|)
150 Opening ASCII mode data connection for file list
-rw-r--r--   1 ftpuser  ftpuser        39 Nov  8  2021 flag.txt
226 Transfer complete


ftp> less flag.txt
