# Privilege Escalation Summary

Initial access often low-priv; escalate to root/admin/SYSTEM for full control. Enumerate thoroughly; use checklists/scripts. Methods: Kernel exploits, vuln software, user privs, scheduled tasks, exposed creds, SSH keys.

## PrivEsc Checklists

- HackTricks: Linux/Windows checklists.
- PayloadsAllTheThings: Repo with checks.

**Additional**: GTFOBins (Linux), LOLBAS (Windows).

## Enumeration Scripts

- Automate checks; may trigger AV/monitoring.
- Linux: LinEnum, linuxprivchecker, PEASS (LinPEAS).
- Windows: Seatbelt, JAWS, PEASS (WinPEAS).
- Run: `./linpeas.sh` (outputs report with findings, e.g., OS, user/groups).

**Additional**: Manual for stealth. Tools: pspy (process monitoring), lsof (open files).

## Kernel Exploits

- Old/unpatched OS vulns.
- Example: Linux 3.9.0-73 → DirtyCow (CVE-2016-5195).
- Search: Google, searchsploit.
- Caution: Instability; test in lab, get approval.

**Additional**: Windows: EternalBlue, etc. Tools: Kernel exploits from Exploit-DB.

## Vulnerable Software

- Check installed: `dpkg -l` (Linux), C:\Program Files (Windows).
- Search exploits for old versions.

**Additional**: rpm -qa (RPM-based), wmic product (Windows).

## User Privileges

### Sudo

- Check: `sudo -l`
- Full: `(ALL : ALL) ALL` → `sudo su -` (switch to root).
- NOPASSWD: Run without pass, e.g., `sudo -u user /bin/echo Hello World!`
- Exploit: GTFOBins for commands.

**Additional**: SUID: `find / -perm -4000 2>/dev/null` (Linux). Windows tokens: `whoami /priv`.

### Scheduled Tasks

- Cron (Linux): Check /etc/crontab, /etc/cron.d, /var/spool/cron/crontabs/.
- Add if write perms; write reverse shell script.

**Additional**: Windows: `schtasks /query`. At jobs: `at`.

## Exposed Credentials

- Files: Configs, logs, bash_history, PSReadLine.
- Reuse: su -, ssh.
- Example: DB creds in config.php.

**Additional**: Registry (Windows), env vars (`env`).

## SSH Keys

- Read private: /home/user/.ssh/id_rsa → `ssh -i key root@target`
- Set perms: `chmod 600 id_rsa`
- Add pub key: Generate `ssh-keygen -f key`, append key.pub to /root/.ssh/authorized_keys.

**Additional**: Authorized_keys perms: 600. For persistence.

**General Tips**: Start with scripts, then manual. Modules: Linux/Windows Priv Esc. Practice on HTB boxes. Document findings. If risky, consult client.
