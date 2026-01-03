# Target: 10.129.148.149

## Questions

*Question 1* - Enumerate the SNMP service and obtain the email address of the admin. Submit it as the answer

*Question 2* - What is the customized version of the SNMP server?

*Question 3* - Enumerate the custom script that is running on the system and submit its output as the answer

## Test Playbook

- We are currently working on the SNMP Test Case.  This can be found at ./cases/footprinting/snmp/*.  Please confirm understanding.

- For this test event, please log all executed commands in program specific log files in the subfolder: ./cases/footprinting/snmp/scans/*.  Each log file should be named <SCANTOOL>.log.  Whenever a scan tool (nmap, gobuster, telnet, ssh, etc.) is used, a line should be appended to that log file with the full command executed, a line break, and then the results from the command and another line break.  Pleae confirm understanding.

- Get the health status for the kaliMcp server

- Using kaliMpc, perform a short nmap scan against target: 10.129.148.149

- Using kaliMpc, perform an nmap scan pulling versions and banners against target: 10.129.148.149

- Using kaliMpc, perform an aggressive nmap scan for ports 161,162 against target: 10.129.148.149

- Using kaliMpc, perform an nmap scan for all snmp* scripts against target: 10.129.148.149

- using kaliMpc, enumerate all snmp information you can find about the target: 10.129.148.149

- using kaliMpc, execute snmpwalk against the target: 10.129.148.149

- using kaliMpc, execute onesixtyone using the wordlist at /usr/share/seclists/Discovery/SNMP/snmp-onesixtyone.txt against target: 10.129.148.149

- using kaliMpc, enumerate all the information you can using braa and the previously determined community strings  and OIDs

- Generate a Penetration Test Report following the format in ./media/pentest_report_template.md.  
All actions, logs, scans and such are in the folder: ./cases/footprinting/snmp/*
Place the final report in the folder: ./cases/footprinting/snmp/snmp_pentest_report.md

Generate as robust and technical a report as possible using the information available in the ./cases/footprinting/snmp/* folder and subfolders.  
Fill in details and descriptions and paragraphs as needed from the specific case folder and external research.
