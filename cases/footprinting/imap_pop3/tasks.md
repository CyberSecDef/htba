# Target: 10.129.195.140

## Questions

*Question 1* - Figure out the exact organization name from the IMAP/POP3 service and submit it as the answer.

*Question 2* - What is the FQDN that the IMAP and POP3 servers are assigned to?

*Question 3* - Enumerate the IMAP service and submit the flag as the answer. (Format: HTB{...})

*Question 4* - What is the customized version of the POP3 server?

*Question 5* - What is the admin email address?

*Question 6* - Try to access the emails on the IMAP server and submit the flag as the answer. (Format: HTB{...})

## Test Playbook

- We are currently working on the imap_pop3 Test Case.  This can be found at ./cases/footprinting/imap_pop3/*.  Please confirm understanding.

- For this test event, please log all executed commands in program specific log files in the subfolder: ./cases/footprinting/imap_pop3/scans/*.  Each log file should be named <SCANTOOL>.log.  Whenever a scan tool (nmap, gobuster, telnet, ssh, etc.) is used, a line should be appended to that log file with the full command executed, a line break, and then the results from the command and another line break.  Pleae confirm understanding.

- Get the health status for the kaliMcp server

- Using kaliMpc, perform a short nmap scan against target: 10.129.195.140

- Using kaliMpc, perform an nmap scan pulling versions and banners against target: 10.129.195.140

- Using kaliMpc, perform an aggressive nmap scan for ports 110,143,993,995 against target: 10.129.195.140

- Using kaliMpc, perform an nmap scan for all imap* scripts against target: 10.129.195.140

- Using kaliMpc, perform an nmap scan for all pop3* scripts against target: 10.129.195.140

- using kaliMpc, enumerate all imap and pop3 information you can find about the target: 10.129.195.140

- Generate a Penetration Test Report following the format in ./media/pentest_report_template.md.  
All actions, logs, scans and such are in the folder: ./cases/footprinting/imap_pop3/*
Place the final report in the folder: ./cases/footprinting/imap_pop3/imap_pop3_pentest_report.md

Generate as robust and technical a report as possible using the information available in the ./cases/footprinting/imap_pop3/* folder and subfolders.  
Fill in details and descriptions and paragraphs as needed from the specific case folder and external research.
