# TwoMillion - HackTheBox Lab Case

## Target Information

| Property | Value |
|----------|-------|
| **IP Address** | 10.129.229.66 |
| **Hostname** | 2million.htb |
| **Operating System** | Ubuntu Linux (OpenSSH 8.9p1, GLIBC 2.35) |
| **Difficulty** | Easy |
| **Attack Host** | 10.10.14.114 |

## Objectives

### Task 1: How Many TCP Ports are open?
2

### Task 2: What is the name of the JavaScript file loaded by the /invite page that has to do with invite codes?
inviteapi.min.js

### Task 3: What JavaScript function on the invite page returns the first hint about how to get an invite code? Don't include () in the answer.
makeInviteCode

### Task 4: The endpoint in makeInviteCode returns encrypted data. That message provides another endpoint to query. That endpoint returns a code value that is encoded with what very common binary to text encoding format. What is the name of that encoding?
base64 

### Task 5: What is the path to the endpoint the page uses when a user clicks on "Connection Pack"?
/api/v1/user/vpn/generate

### Task 6:  How many API endpoints are there under /api/v1/admin?
3

### Task 7: What API endpoint can change a user account to an admin account?
/api/v1/admin/settings/update

### Task 8: What API endpoint has a command injection vulnerability in it?
/api/v1/admin/vpn/generate
this will allow extra commands to be inserted into the username field

### Task 9: What file is commonly used in PHP applications to store environment variable values?
.env

### Task 10: Submit the flag located in the admin user's home directory.
9f5610c657f44776c417d0d9e83ab74d

### Task 11: What is the email address of the sender of the email sent to admin?
ch4p@2million.htb

### Task 12: What is the 2023 CVE ID for a vulnerability in that allows an attacker to move files in the Overlay file system while maintaining metadata like the owner and SetUID bits?
CVE-2023-0386

### Task 13: Submit the flag located in root's home directory.
1431fb0da4b48334a998a72a409cfba3

### Task 14: [Alternative Priv Esc] What is the version of the GLIBC library on TwoMillion?
2.35






## Attack Summary

Performed nmap scans
    Found two open ports (22, 80)

Performed baseline curl scans
    Found the IP redirects to http://2million.htb/
    Added to /etc/hosts

Performed Gobuster, Nikto, reconspider, wafw00f and whatweb scans

Browsed to site, found invite JS file
Found function names in inviteapi.js code
executed makeInviteCode in developer console 
    recieved ROT13 encrypted data.
    recieved url to post to for code
    posted and received base64 encoded data (ZYWVC-MS3EL-Z97AB-83QGH)
Registed for an account and logged in
Found connection pack link
executed dirb against http://2million.htb/api/v1/admin/ found auth endpoint
executed ffuf against http://2million.htb/api/v1/admin.
browsed to http://2million.htb/api/v1 and saw three end points under admin
logged in using postman (test:test123)
used PUT to promote to admin
generated a VPN cert with applicable api endpoint and found command injection flaw

started listening on port 4444 and injected bash php reverse shell
from shell, found .env with credentials
used creds to ssh in as admin
found user flag
read admin email in /var/mail/admin

from submitted CVE, found exploit on github: https://github.com/xkaneiki/CVE-2023-0386.git
uploaded to target via python http.server module

executed ldd --version to get glibc version
found GLIBC_TUNABLES exploit on github

