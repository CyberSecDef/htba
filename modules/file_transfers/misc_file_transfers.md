# Miscellaneous File Transfer Methods

**Technical Report, Red Team Playbooks, and Blue Team Playbooks**

---

## Executive Summary

File transfer is a **critical enabling capability** in penetration testing. After gaining initial or partial access to a target system, an operator must reliably move tools, payloads, data, or exfiltrated files under a variety of constraints. This section focuses on **non-HTTP, non-SMB, and non-traditional transfer mechanisms** that become essential when standard enterprise protocols are blocked, monitored, or unavailable.

The document covers:

* Netcat and Ncat file transfers
* Firewall-aware connection direction choices
* Bash `/dev/tcp` fallback transfers
* PowerShell Remoting (WinRM) file transfers
* RDP-based file transfer techniques (copy/paste and drive mapping)

These methods are particularly relevant in **restricted enterprise environments**, segmented networks, and post-exploitation scenarios .

---

## Conceptual Overview

### Why Miscellaneous Transfer Methods Matter

In real environments:

* HTTP/S may be blocked or inspected
* SMB may be disabled or segmented
* Egress filtering may restrict outbound traffic
* Antivirus may flag common download utilities

As a result, **living-off-the-land (LOLBins)** and **native protocol abuse** become essential skills. Netcat, PowerShell Remoting, and RDP all exploit functionality that is often **already trusted and allowed** in enterprise networks.

---

## Netcat and Ncat File Transfers

### Tool Background

* **Netcat (nc)**: Original utility released in 1995; simple, powerful, but unmaintained
* **Ncat**: Modern Nmap-maintained reimplementation with:

  * SSL/TLS support
  * IPv6
  * Proxy support
  * Connection control flags (`--send-only`, `--recv-only`)

Hack The Box environments often alias `nc`, `netcat`, and `ncat` interchangeably .

---

### Netcat File Transfer Mechanics

Netcat transfers files by:

* Opening a TCP listener on one host
* Redirecting standard input/output to a file
* Sending raw byte streams over the socket

There is **no protocol awareness**, encryption, or integrity checking—just raw data.

---

### Compromised Host Listening (Inbound Transfer)

**Use case**: Firewall allows inbound connections to target.

Key mechanics:

* Listener redirects output to file
* Sender redirects file into Netcat stdin
* Connection termination signals completion

Important distinctions:

* Original Netcat requires `-q` to close
* Ncat requires `--recv-only` or `--send-only` to prevent hanging sessions .

---

### Attacker Listening (Outbound Transfer)

**Use case**: Inbound connections to target are blocked.

Technique:

* Attacker listens on a common port (e.g., 443)
* Target connects outbound to retrieve the file
* Mimics legitimate outbound HTTPS traffic patterns

This method is **far more realistic** in enterprise environments with strict ingress filtering .

---

## Bash `/dev/tcp` File Transfers

### Concept

Bash supports pseudo-device files:

```
/dev/tcp/<host>/<port>
```

Writing to or reading from this file implicitly opens a TCP socket.

### Why This Matters

* Works **without Netcat**
* Uses only Bash built-ins
* Extremely stealthy in minimal Linux environments

This is a **critical fallback technique** when binaries are unavailable or monitored .

---

## PowerShell Remoting (WinRM) File Transfers

### Overview

PowerShell Remoting (WinRM):

* Uses HTTP (5985) or HTTPS (5986)
* Commonly enabled in Active Directory environments
* Often implicitly trusted by firewalls

Requirements:

* Administrative privileges **or**
* Membership in *Remote Management Users* group

### File Transfer via PowerShell Sessions

PowerShell allows:

* Creating persistent sessions (`New-PSSession`)
* Transferring files using `Copy-Item`
* Bi-directional transfer between systems

This is a **high-fidelity administrative technique** that blends in with normal enterprise management activity .

---

## RDP File Transfer Methods

### Copy & Paste

* Simple clipboard-based transfer
* Often works but can be disabled by policy
* Less reliable in hardened environments

---

### RDP Drive Mapping (Preferred)

Using:

* `rdesktop`
* `xfreerdp`
* `mstsc.exe`

Attackers can:

* Mount local directories into the RDP session
* Access them via `\\tsclient\`
* Transfer files interactively

Security note:

* Mounted drives are **session-scoped**
* Other users cannot access them even if the session is hijacked .

---

## Operational Considerations

* Choose connection direction based on firewall rules
* Prefer outbound connections from compromised hosts
* Use common ports (443, 5985) to blend traffic
* Avoid repeated failed transfers (telemetry goldmine for defenders)
* Encrypt sensitive data when possible (covered in next module)

---

# Red Team Playbooks

## Playbook 1: Netcat File Transfer (Firewall-Aware)

**Objective**
Transfer payloads when HTTP/SMB are unavailable.

**Prerequisites**

* Netcat or Ncat available on at least one host
* TCP connectivity on any port

**Attack Flow**

1. Identify allowed ingress/egress direction
2. Choose listener location accordingly
3. Redirect file via stdin/stdout
4. Verify file integrity (hash check)

**OPSEC Notes**

* Prefer outbound target connections
* Avoid unusual ports unless necessary
* Clean up artifacts after transfer

---

## Playbook 2: Bash-Only File Transfer

**Objective**
Transfer files without dropping binaries.

**Prerequisites**

* Bash shell access
* TCP connectivity

**Attack Flow**

1. Attacker opens listener
2. Target reads from `/dev/tcp`
3. Redirect output to file
4. Validate transfer

**Why This Is Powerful**

* Leaves almost no forensic footprint
* No external tools required

---

## Playbook 3: PowerShell Remoting Transfer

**Objective**
Leverage trusted administrative channels.

**Prerequisites**

* Admin or WinRM permissions
* WinRM ports reachable

**Attack Flow**

1. Validate WinRM connectivity
2. Establish PSSession
3. Transfer tools via `Copy-Item`
4. Execute post-transfer operations

---

## Playbook 4: RDP Drive Mapping

**Objective**
Transfer tools interactively in GUI environments.

**Prerequisites**

* RDP credentials
* RDP allowed

**Attack Flow**

1. Connect via RDP with drive mapping enabled
2. Access `\\tsclient\`
3. Move tools into target filesystem
4. Execute or stage payloads

---

# Blue Team Playbooks

## Detection: Netcat & Raw TCP Transfers

**Indicators**

* Unexpected listeners on non-service ports
* Long-lived TCP sessions with raw data streams
* High-entropy traffic on uncommon ports

**Defensive Actions**

* Alert on `nc`, `ncat` execution
* Monitor outbound connections to attacker-controlled IPs
* Apply egress filtering where possible

---

## Detection: `/dev/tcp` Abuse

**Indicators**

* Bash accessing `/dev/tcp/*`
* Unexpected outbound TCP sessions from shell processes

**Defensive Actions**

* Shell command logging
* EDR detection rules for `/dev/tcp` usage

---

## Detection: PowerShell Remoting Abuse

**Indicators**

* Unusual WinRM session creation
* Lateral file transfers via `Copy-Item`
* Admin sessions outside normal admin work hours

**Defensive Actions**

* Constrain WinRM permissions
* Log and alert on PSSession creation
* Enforce Just-Enough-Administration (JEA)

---

## Detection: RDP Drive Mapping

**Indicators**

* RDP sessions with redirected drives
* File creation sourced from `\\tsclient\`

**Defensive Actions**

* Disable drive redirection where possible
* Alert on RDP sessions with local resource sharing
* Enforce MFA on RDP

---

## Final Notes

This section emphasizes **adaptability**. Attackers who rely on a single transfer method fail quickly in real environments. Defenders who monitor only HTTP downloads miss everything that actually matters.

In short:

* Red teams: master alternatives
* Blue teams: assume attackers already have options

And yes—Netcat is still ruining people’s day, nearly 30 years later.
