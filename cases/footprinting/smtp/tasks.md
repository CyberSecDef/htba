# Target: 10.129.104.26

## Questions

*Question_1* - Enumerate the SMTP service and submit the banner, including its version as the answer

*Question_2* - Enumerate the SMTP service even further and find the username that exists on the system. Submit it as the answer

## Test Playbook

- We are currently working on the SMTP Test Case.  This can be found at ./cases/footprinting/smtp/*.  Please confirm understanding.

- For this test event, please log all executed commands in program specific log files in the subfolder: ./cases/footprinting/smtp/scans/*.  Each log file should be named <SCANTOOL>.log.  Whenever a scan tool (nmap, gobuster, telnet, ssh, etc.) is used, a line should be appended to that log file with the full command executed, a line break, and then the results from the command and another line break.  Pleae confirm understanding.

- Get the health status for the kaliMcp server

- Using kaliMpc, perform a short nmap scan against target: 10.129.104.26

- Using kaliMpc, perform an nmap scan pulling versions and banners against target: 10.129.104.26

- Using kaliMpc, perform an aggressive nmap scan for ports 25,587,465 against target: 10.129.104.26

- Using kaliMpc, perform an nmap scan for all smtp* scripts against target: 10.129.104.26

- using kaliMpc, enumerate all smtp information you can find about the target: 10.129.104.26

- Generate a Penetration Test Report following the format in ./media/pentest_report_template.md.  
All actions, logs, scans and such are in the folder: ./cases/footprinting/smtp/*
Place the final report in the folder: ./cases/footprinting/smtp/smtp_pentest_report.md

Generate as robust and technical a report as possible using the information available in the ./cases/footprinting/smtp/* folder and subfolders.  
Fill in details and descriptions and paragraphs as needed from the specific case folder and external research.
