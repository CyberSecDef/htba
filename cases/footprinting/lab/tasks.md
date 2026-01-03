# Targets: 
    DNS - X.X.X.X
    Server - X.X.X.X
    MX - X.X.X.X

## Details

### Section 1

We were commissioned by the company Inlanefreight Ltd to test three different servers in their internal network. The company uses many different services, and the IT security department felt that a penetration test was necessary to gain insight into their overall security posture.

The first server is an internal DNS server that needs to be investigated. In particular, our client wants to know what information we can get out of these services and how this information could be used against its infrastructure. Our goal is to gather as much information as possible about the server and find ways to use that information against the company. However, our client has made it clear that it is forbidden to attack the services aggressively using exploits, as these services are in production.

Additionally, our teammates have found the following credentials "XXXXXX:XXXXXX", and they pointed out that some of the company's employees were talking about SSH keys on a forum.

The administrators have stored a flag.txt file on this server to track our progress and measure success. Fully enumerate the target and submit the contents of this file as proof.

### Section 2

This second server is a server that everyone on the internal network has access to. In our discussion with our client, we pointed out that these servers are often one of the main targets for attackers and that this server should be added to the scope.

Our cusXXXXXXer agreed to this and added this server to our scope. Here, too, the goal remains the same. We need to find out as much information as possible about this server and find ways to use it against the server itself. For the proof and protection of cusXXXXXXer data, a user named HTB has been created. Accordingly, we need to obtain the credentials of this user as proof.

### Section 3

The third server is an MX and management server for the internal network. Subsequently, this server has the function of a backup server for the internal accounts in the domain. Accordingly, a user named HTB was also created here, whose credentials we need to access.

## Questions

*Question 1.1* - Enumerate the DNS server carefully and find the flag.txt file. Submit the contents of this file as the answer.

*Question 2.1* - Enumerate the server carefully and find the username "HTB" and its password. Then, submit this user's password as the answer.

*Question 3.1* - Enumerate the server carefully and find the username "HTB" and its password. Then, submit HTB's password as the answer.

## Test Playbook

- We are currently working on the LAB Test Case.  This can be found at ./cases/footprinting/lab/*.  Please confirm understanding.  please only confirm understanding, we are going to run through this step by step.

- For this test event, please log all executed commands in program specific log files in the subfolder: ./cases/footprinting/lab/scans/*.  Each log file should be named <SCANTOOL>.log.  Whenever a scan tool (nmap, gobuster, telnet, ssh, etc.) is used, a line should be appended to that log file with the full command executed, a line break, and then the results from the command and another line break.  Avoid overloading the target with many simultaneous requests. Please confirm understanding.

- Get the health status for the kaliMcp server

### Section 1

- Using kaliMpc, perform a short nmap scan against target: X.X.X.X

- Using kaliMpc, perform an nmap scan pulling versions and banners against target: X.X.X.X

- Using kaliMpc, perform an aggressive nmap scan for ports tcp and udp 53 against target: X.X.X.X

- Using kaliMpc, perform multiple DIG scans to enumerate as much information as possible against target: X.X.X.X

- Using kaliMpc, perform an nmap scan using all dns* scripts against target: X.X.X.X.  Provide the determined domain name to the scripts if needed.

- Using kaliMpc, perform a zone transfer to see if that can enumerate information against target: X.X.X.X

- Using kaliMpc, execute metasploit to enumerate all dns information against target: X.X.X.X.  Do not harm the servers in any way, just exfiltrate data.

- Using kaliMpc, attempt to utilize the credentials XXXXXX:XXXXXX in multiple ways to exfiltate information against target: X.X.X.X

### Section 2

- Using kaliMpc, perform a short nmap scan against target: X.X.X.X

- Using kaliMpc, perform an nmap scan pulling versions and banners against target: X.X.X.X

- Using kaliMpc, perform an aggressive nmap scan against target: X.X.X.X

- Using kaliMpc, perform an nmap scan using all nfs* scripts against target: X.X.X.X

- Using kaliMpc, perform an nmap scan using all smb* scripts against target: X.X.X.X

- Using kaliMpc, perform an nmap scan using all rdp* scripts against target: X.X.X.X

- Using kaliMpc, execute smbclient tools for enumerations against target: X.X.X.X

- Using kaliMpc, execute smbmap tools for enumerations against target: X.X.X.X

- Using kaliMpc, execute rpcclient tools for enumerations against target: X.X.X.X

- Using kaliMpc, execute winrm tools for enumerations against target: X.X.X.X

- Using kaliMpc, mount the Techsupport share via NFS and examine the ticket files. drop the contents in the scans folder.  look for any crentials.

- using kaliMpc, perform an nmap scan using all RDP scripts to see if this reveals any additional information or authentication methods.

- using kaliMpc, log in to the server with the XXXXXX account and see if that can be pivoted to HTB.  If not, enumerate any other information that might lead to the HTB password.

- Using kaliMpc, perform an nmap scan using all smb* scripts against target: X.X.X.X.  use the credentials we found for XXXXXX.

- using kaliMpc, execute the mssqlclient using the sa credentials we found.  list any databases available.  enumerate all tables in those databases.

### Section 3

- Using kaliMpc, perform a short nmap scan against target: X.X.X.X

- Using kaliMpc, perform an nmap scan pulling versions and banners against target: X.X.X.X

- Using kaliMpc, perform an aggressive nmap scan against target: X.X.X.X

- Using kaliMpc, perform an aggressive nmap scan for ports 110,143,993,995 against target: X.X.X.X

- Using kaliMpc, perform an nmap scan for all imap* scripts against target: X.X.X.X

- Using kaliMpc, perform an nmap scan for all pop3* scripts against target: X.X.X.X

- using kaliMpc, enumerate all imap and pop3 information you can find about the target: X.X.X.X

- Using kaliMpc, perform an nmap scan of UDP ports pulling versions and banners against target: X.X.X.X

- using kaliMpc, attempt snmp access to the target using onesixtyone.  the wordlist to use is at: /usr/share/seclists/Discovery/SNMP/snmp-onesixtyone.txt

- using kaliMpc, execute snmpwalk with the community string "backup" against the target: X.X.X.X

- using kaliMpc, try to open an imap connection using the "XXXXXX" credentials against the target: X.X.X.X.  if this is sucessful, list all available mailboxes.

- logged in via SSH with private key, pivoted to mysql and found credentials.

- Generate a Penetration Test Report following the format in ./media/pentest_report_template.md.  
All actions, logs, scans and such are in the folder: ./cases/footprinting/lab/*
Ensure you read them all as some were generated by me.
Generate as robust and technical a report as possible using the information available in the ./cases/footprinting/lab/* folder and subfolders.  
Fill in details and descriptions and paragraphs as needed from the specific case folder and external research, but do not fabricate any 'facts' without stating so.  Any performance metrics should be found in the logs/scans or not referenced.
For every subsection, or referenced data point, cite which log and where the data came from.
For all infered sections or walkthrough, label them as such.
For all self generated code or actions, label them as such.
Any and all claims must be based in a logged fact/evidence or labeled as inferred/assumed/etc.
Clearly distinguish between findings, analysis/expert interpreation and recomendations.
Also create event walkthroughs stepping through each step taken in detail during this event.
make it clear in the report what took place in section 1, section 2 and section 3
Place the final report in the folder: ./cases/footprinting/lab/lab_pentest_report.md