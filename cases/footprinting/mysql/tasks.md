# Target: 10.129.181.202

## Questions

*Question 1* - Enumerate the MySQL server and determine the version in use. (Format: MySQL X.X.XX)
Write your answer

*Question 2* - During our penetration test, we found weak credentials "robin:robin". We should try these against the MySQL server. What is the email address of the customer "Otto Lang"?

## Test Playbook

- We are currently working on the MYSQL Test Case.  This can be found at ./cases/footprinting/mysql/*.  Please confirm understanding.

- For this test event, please log all executed commands in program specific log files in the subfolder: ./cases/footprinting/mysql/scans/*.  Each log file should be named <SCANTOOL>.log.  Whenever a scan tool (nmap, gobuster, telnet, ssh, etc.) is used, a line should be appended to that log file with the full command executed, a line break, and then the results from the command and another line break.  Pleae confirm understanding.

- Get the health status for the kaliMcp server

- Using kaliMpc, perform a short nmap scan against target: 10.129.181.202

- Using kaliMpc, perform an nmap scan pulling versions and banners against target: 10.129.181.202

- Using kaliMpc, perform an aggressive nmap scan for ports 3306 against target: 10.129.181.202

- Login manually with provided credentials and enumerate data

- Generate a Penetration Test Report following the format in ./media/pentest_report_template.md.  
All actions, logs, scans and such are in the folder: ./cases/footprinting/mysql/*
Place the final report in the folder: ./cases/footprinting/mysql/mysql_pentest_report.md

Generate as robust and technical a report as possible using the information available in the ./cases/footprinting/mysql/* folder and subfolders.  
Fill in details and descriptions and paragraphs as needed from the specific case folder and external research.
