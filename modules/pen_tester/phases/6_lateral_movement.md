# Lateral Movement Phase Summary

Lateral Movement follows successful Exploitation/Post-Exploitation. Test internal network traversal, access sensitive data, and demonstrate disruption potential (e.g., ransomware spread). Goal: Show attacker reach; highlight security gaps. CEOs may be liable for breaches. Phases within: Pivoting, Evasive Testing, Information Gathering, Vulnerability Assessment, (Privilege) Exploitation, Post-Exploitation.

## Pivoting

Use compromised host as proxy to access non-routable networks. Route scans/requests through it for deeper penetration.

**Additional Tools/Commands**:

- Proxychains: `proxychains nmap -sT targetInternalIP` (Proxy Nmap through host).
- SSH tunneling: `ssh -D 1080 user@compromisedHost` (Dynamic SOCKS proxy).
- Metasploit: `use auxiliary/server/socks4a; set SRVHOST 0.0.0.0; run` then `proxychains msfconsole`.

## Evasive Testing

Adapt to avoid detection by segmentation, monitoring, IPS/IDS, EDR. Understand defenses to bypass.

**Additional Tools**: Empire/Covenant for low-noise C2; custom scripts to mimic normal traffic.

## Information Gathering

Enumerate internal hosts/servers from compromised system. Build on Post-Exploitation data.

**Additional Tools/Commands**:

- `nmap -sn 192.168.1.0/24` (Internal ping sweep).
- `arp -a` (Local ARP table).
- BloodHound/SharpHound: Collect AD data for mapping.

## Vulnerability Assessment

Assess internal vulns: Misconfigs, shared resources, group rights. Prioritize based on access (e.g., developer group for code access).

**Additional Tools**: Nessus/OpenVAS scans via pivot.

## (Privilege) Exploitation

Exploit findings: Crack hashes, pass-the-hash, reuse creds.

**Additional Tools/Commands**:

- Hashcat/John: `hashcat -m 5600 hash.txt rockyou.txt` (Crack NTLM).
- Mimikatz: `sekurlsa::pth /user:admin /domain:corp /ntlm:hash` (Pass-the-hash).
- CrackMapExec: `cme smb targets.txt -u user -H hash` (SMB lateral with hash).

## Post-Exploitation

Repeat per new host: Gather info, pillage, escalate, persist. Handle data per contract.

**Additional Tools**: Mimikatz for creds; LinPEAS/WinPEAS for escalation.

**General Tips**: Iterative; document paths. For HTB, practice on multi-host labs. Use evasive techniques. If sensitive data found, consult client. End with Proof-of-Concept. Prevent real disruption.
