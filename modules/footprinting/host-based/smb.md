## 1. Overview of SMB

**Server Message Block (SMB)** is a client–server network protocol used to provide shared access to files, directories, printers, and other network resources. SMB also supports inter-process communication across a network.

Originally introduced broadly with **IBM OS/2 LAN Manager**, SMB became most prominent in **Microsoft Windows**, where it is deeply integrated into networking services. Modern Windows systems maintain backward compatibility, allowing newer hosts to communicate with older SMB implementations.

To enable cross-platform interoperability, **Samba** provides an open-source SMB implementation for Linux and Unix-like systems, allowing seamless integration with Windows networks.

---

## 2. SMB Communication Model

SMB operates over **TCP/IP** and requires a connection establishment before file or service access:

* Uses **TCP three-way handshake**
* Data transport is governed entirely by TCP
* SMB clients issue requests that are processed by an SMB server service

SMB servers expose parts of their local filesystem as **shares**, which appear as independent directory structures to clients. Access to these shares is controlled using **Access Control Lists (ACLs)**.

Key properties:

* ACLs apply at the **share level**
* Permissions may not mirror local filesystem permissions
* Granular access: read, write, execute, full control

---

## 3. SMB, CIFS, and Versioning

### CIFS and SMB Relationship

* **CIFS (Common Internet File System)** is a dialect of SMB
* CIFS aligns primarily with **SMB version 1**
* Commonly referred to as **SMB/CIFS** in Samba contexts

### Ports Used

* **NetBIOS-based SMB (legacy)**: TCP 137, 138, 139
* **Direct SMB over TCP**: TCP 445 (modern standard)

### SMB Version Matrix

| SMB Version | Supported OS             | Key Enhancements              |
| ----------- | ------------------------ | ----------------------------- |
| CIFS        | Windows NT 4.0           | NetBIOS-based communication   |
| SMB 1.0     | Windows 2000             | Direct TCP support            |
| SMB 2.0     | Vista / Server 2008      | Performance, caching, signing |
| SMB 2.1     | Windows 7 / 2008 R2      | Improved locking              |
| SMB 3.0     | Windows 8 / Server 2012  | Encryption, multichannel      |
| SMB 3.0.2   | Windows 8.1 / 2012 R2    | Minor enhancements            |
| SMB 3.1.1   | Windows 10 / Server 2016 | Integrity checking, AES-128   |

Modern environments should **disable SMBv1** due to severe security risks.

---

## 4. Samba Architecture and Role

Samba enables Linux/Unix hosts to participate in SMB networks.

### Capabilities by Version

* **Samba v3**: Active Directory domain *member*
* **Samba v4**: Full Active Directory *domain controller*

### Key Daemons

* **smbd** – File sharing, authentication
* **nmbd** – NetBIOS name services
* Controlled via the **SMB service**

---

## 5. Workgroups and NetBIOS

* A **workgroup** identifies a collection of SMB hosts
* Multiple workgroups can coexist on a network
* NetBIOS provides naming and discovery services
* Name resolution handled by:
  * Local registration
  * WINS (Windows Internet Name Service)
  * Broadcast queries on the local network

---

## 6. Samba Default Configuration

Samba is configured via `/etc/samba/smb.conf`.

The document demonstrates a default configuration including:

* Global server settings
* Printer shares (`[printers]`, `[print$]`)

### Important Global Options

* `workgroup`
* `server role`
* `unix password sync`
* `map to guest`
* Logging configuration

### Share-Level Overrides

Each share can override global defaults, which is a frequent source of **misconfiguration**.

---

## 7. Critical Samba Share Settings

### Common Share Parameters

| Setting          | Description                           |
| ---------------- | ------------------------------------- |
| `browseable`     | Whether the share appears in listings |
| `guest ok`       | Allow unauthenticated access          |
| `read only`      | Prevent write access                  |
| `create mask`    | File permissions                      |
| `directory mask` | Directory permissions                 |

### Dangerous Settings

These significantly increase attack surface:

* `guest ok = yes`
* `browseable = yes`
* `read only = no`
* `writable = yes`
* `create mask = 0777`
* `directory mask = 0777`
* `enable privileges = yes`
* `logon script`
* `magic script`

Misuse of these settings often leads to:

* Anonymous file access
* Unauthorized uploads
* Script execution opportunities
* Lateral movement

---

## 8. Example Vulnerable Share

The document demonstrates a deliberately unsafe share:

```ini
[notes]
path = /mnt/notes/
browseable = yes
read only = no
guest ok = yes
create mask = 0777
directory mask = 0777
```

This configuration allows:

* Anonymous access
* Full read/write permissions
* Share enumeration
* File exfiltration

---

## 9. Service Management

After modifying configuration:

```bash
systemctl restart smbd
```

Restarting is required for changes to take effect.

---

## 10. SMB Enumeration via smbclient

### Share Listing (Null Session)

```bash
smbclient -N -L //<target>
```

Findings include:

* Default shares (`IPC$`, `print$`)
* Custom shares (`home`, `dev`, `notes`)

### Interactive Access

Once connected:

* `ls`, `get`, `put`
* Local command execution via `!`
* ACL inspection

---

## 11. Monitoring Active Connections

Administrators can monitor sessions using:

```bash
smbstatus
```

This reveals:

* Connected users
* Source IPs
* SMB dialects
* Encryption and signing status

---

## 12. SMB Footprinting with Nmap

Nmap can identify:

* Open SMB ports (139, 445)
* SMB version
* Signing requirements
* NetBIOS metadata

However:

* Output is **limited**
* Not sufficient for deep enumeration

---

## 13. RPC and rpcclient Enumeration

### RPC Fundamentals

Remote Procedure Call (RPC) allows remote function execution across the network.

### Null Session Access

```bash
rpcclient -U "" <target>
```

### High-Value RPC Queries

* `srvinfo`
* `enumdomains`
* `querydominfo`
* `netshareenumall`
* `enumdomusers`
* `queryuser <RID>`

This enables:

* User discovery
* Share mapping
* Permission analysis
* Domain structure insight

---

## 14. RID Enumeration and Brute Forcing

Even without credentials, **RID brute forcing** reveals users:

* Iterate through RID ranges
* Query each RID
* Identify valid accounts

This technique is extremely effective against misconfigured SMB servers.

---

## 15. Impacket: samrdump.py

Impacket automates RPC enumeration:

* Users
* Password metadata
* Group membership
* Account status

Provides cleaner output than manual RPC queries.

---

## 16. Additional Enumeration Tools

### SMBMap

* Quick share access check
* Permission visibility

### CrackMapExec

* Share enumeration
* Signing status
* SMB version detection

### enum4linux-ng

* Aggregates multiple techniques
* NetBIOS, RPC, SMB, policy enumeration
* Password policy discovery
* User and share testing

---

## 17. Security Implications

The document highlights systemic risks:

* Anonymous SMB access
* User enumeration
* Weak password policies
* Over-permissive shares
* Forgotten test configurations

Key insight:

> **Once anonymous access is allowed, a single misstep can expose the entire network.**

Humans make configuration mistakes; attackers exploit them.

---

## 18. Defensive Takeaways

Best practices implied by the document:

* Disable SMBv1
* Enforce SMB signing
* Eliminate guest access
* Restrict share visibility
* Apply least-privilege ACLs
* Audit Samba configs regularly
* Monitor SMB sessions
* Never rely solely on automated tools

---

## 19. Conclusion

This document demonstrates that **SMB is both powerful and dangerous** when misconfigured. Samba, while flexible, introduces substantial risk if defaults or test configurations persist into production.

Effective security requires:

* Deep protocol understanding
* Manual verification
* Layered enumeration
* Defensive discipline

In SMB environments, *visibility equals vulnerability*—and anonymous visibility is the most dangerous of all.

---

## Enumeration Techniques

Common tools for SMB enumeration:
- **smbclient** - Command-line SMB client
- **enum4linux** - SMB enumeration tool
- **nmap scripts** - smb-enum-shares, smb-os-discovery, etc.
- **CrackMapExec** - Advanced SMB enumeration and exploitation

> **TODO**: Add practical enumeration examples and command outputs
