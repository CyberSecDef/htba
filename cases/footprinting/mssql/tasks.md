# Target: 10.129.230.249

## Questions

*Question 1* - Enumerate the target using the concepts taught in this section. List the hostname of MSSQL server.

Question 2 - Connect to the MSSQL instance running on the target using the account (backdoor:Password1), then list the non-default database present on the server.

## Test Playbook

- We are currently working on the MSSql Test Case.  This can be found at ./cases/footprinting/mssql/*.  Please confirm understanding.

- For this test event, please log all executed commands in program specific log files in the subfolder: ./cases/footprinting/mssql/scans/*.  Each log file should be named <SCANTOOL>.log.  Whenever a scan tool (nmap, gobuster, telnet, ssh, etc.) is used, a line should be appended to that log file with the full command executed, a line break, and then the results from the command and another line break.  Avoid overloading the target with many simultaneous requests. Please confirm understanding.

- Get the health status for the kaliMcp server

- Using kaliMpc, perform a short nmap scan against target: 10.129.230.249

- Using kaliMpc, perform an nmap scan pulling versions and banners against target: 10.129.230.249

- Using kaliMpc, perform an aggressive nmap scan for ports 1433 against target: 10.129.230.249

- Using kaliMpc, perform an nmap scan using all ms-sql* scripts  against target: 10.129.230.249

- Using kaliMpc, perform an nmap scan using all ms-sql* scripts with username "backdoor" and password "Password1" against target: 10.129.230.249.  do not user a domain/hostname with the password.

- using kaliMpc, execute the metasploit scanner mssql_ping and scan the target: 10.129.230.249

- using kaliMpc, Login manually with username "backdoor" and password "Password1" and enumerate data against target: 10.129.230.249.  do not user a domain/hostname with the password.

- Generate a Penetration Test Report following the format in ./media/pentest_report_template.md.  
All actions, logs, scans and such are in the folder: ./cases/footprinting/mssql/*
Place the final report in the folder: ./cases/footprinting/mssql/mssql_pentest_report.md

Generate as robust and technical a report as possible using the information available in the ./cases/footprinting/mssql/* folder and subfolders.  
Fill in details and descriptions and paragraphs as needed from the specific case folder and external research.
