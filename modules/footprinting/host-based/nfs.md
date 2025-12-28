# Technical Report: Network File System (NFS) Enumeration, Configuration, and Security Implications

## 1. Overview of Network File System (NFS)

**Network File System (NFS)** is a distributed file system protocol originally developed by Sun Microsystems. Its purpose is to allow systems to access remote file systems over a network **as if they were local**, similar in intent to SMB but fundamentally different in protocol design and usage.

Key characteristics:

* Primarily used in **Linux and Unix environments**
* Incompatible with SMB at the protocol level
* Standardized Internet protocol
* Designed for transparent file sharing across systems

NFS plays a critical role in enterprise environments for:

* Centralized storage
* User home directories
* Application data sharing
* Backup and administrative workflows

---

## 2. NFS Protocol Versions and Capabilities

### 2.1 NFS Version Comparison

| Version     | Features                                                                           |
| ----------- | ---------------------------------------------------------------------------------- |
| **NFSv2**   | Legacy version, UDP-based, limited features                                        |
| **NFSv3**   | Improved error handling, variable file sizes, partial incompatibility with v2      |
| **NFSv4**   | Stateful protocol, Kerberos authentication, ACLs, firewall-friendly, no portmapper |
| **NFSv4.1** | Parallel NFS (pNFS), session trunking, clustering support, RFC 8881                |

A major security and operational improvement in **NFSv4+** is the use of a **single TCP/UDP port (2049)**, simplifying firewall traversal and reducing exposure.

---

## 3. Underlying Architecture and Authentication Model

NFS relies on:

* **ONC-RPC / SUN-RPC**
* TCP/UDP port **111** (rpcbind)
* External Data Representation (XDR)

### 3.1 Authentication and Authorization Model

* NFS itself has **no native authentication**
* Authentication is delegated to RPC
* Authorization is derived from filesystem permissions
* Commonly based on **UID/GID mappings**

### 3.2 Core Security Weakness

UID/GID values:

* Are trusted blindly by the server
* Do not need to match real users
* Can be recreated on an attacker’s system

This design makes NFS **unsafe outside trusted networks** unless Kerberos (NFSv4) is used.

---

## 4. Default NFS Configuration: `/etc/exports`

The `/etc/exports` file defines:

* Exported directories
* Allowed hosts or subnets
* Access permissions and behavior

Example configuration:

```bash
/mnt/nfs 10.129.14.0/24(sync,no_subtree_check)
```

This grants **all hosts in the subnet** access to the shared directory.

---

## 5. Common Export Options and Their Impact

| Option             | Description                 |
| ------------------ | --------------------------- |
| `rw`               | Read/write access           |
| `ro`               | Read-only access            |
| `sync`             | Safer, synchronous writes   |
| `async`            | Faster, riskier writes      |
| `secure`           | Only ports <1024 allowed    |
| `insecure`         | Allows ports >1024          |
| `no_subtree_check` | Disables subtree validation |
| `root_squash`      | Maps root to anonymous UID  |

---

## 6. Dangerous NFS Configuration Options

Certain options significantly weaken security:

| Option           | Risk                             |
| ---------------- | -------------------------------- |
| `rw`             | Allows file modification         |
| `insecure`       | Allows unprivileged client ports |
| `nohide`         | Exposes nested filesystems       |
| `no_root_squash` | Grants root full access          |

These misconfigurations frequently lead to:

* Credential leakage
* Unauthorized file modification
* Privilege escalation

---

## 7. Footprinting and Enumeration of NFS Services

### 7.1 Key Ports

* **111/tcp & udp** – rpcbind
* **2049/tcp & udp** – NFS

### 7.2 Nmap Enumeration

Using Nmap with NSE scripts reveals:

* Active RPC services
* NFS versions
* Exported shares
* File listings
* Permissions
* Storage statistics

The `rpcinfo` and `nfs-*` NSE scripts are particularly valuable for passive enumeration.

---

## 8. Discovering Exported Shares

The `showmount` utility reveals accessible exports:

```bash
showmount -e <target>
```

This confirms:

* Share paths
* Allowed subnets

---

## 9. Mounting and Inspecting NFS Shares

NFS shares can be mounted locally:

```bash
mount -t nfs <target>:/ ./target-NFS -o nolock
```

Once mounted:

* Files appear as local
* Ownership and permissions are preserved
* UID/GID values are exposed

---

## 10. UID/GID Manipulation and Access Control Bypass

By recreating matching UIDs/GIDs locally, an attacker can:

* Read protected files
* Modify writable content
* Bypass intended access restrictions

This is a **core NFS exploitation technique**.

---

## 11. Root Squash Behavior

If `root_squash` is enabled:

* Root UID (0) maps to anonymous
* File modification is restricted

If **disabled (`no_root_squash`)**:

* Root gains full access
* Privilege escalation becomes trivial

---

## 12. Sensitive Data Exposure via NFS

The document demonstrates discovery of:

* **SSH private keys**
* Public keys
* Backup scripts
* Configuration files

Exposed private keys allow:

* Passwordless SSH access
* Lateral movement
* Persistent compromise

---

## 13. NFS as a Privilege Escalation Vector

NFS can be used for:

* Dropping SUID binaries
* Executing code as higher-privileged users
* Cross-system privilege escalation

This is especially effective when:

* Combined with SSH access
* UID mappings are predictable
* Write permissions exist

---

## 14. Cleanup and Operational Hygiene

After enumeration or exploitation:

```bash
umount ./target-NFS
```

Unmounting:

* Prevents accidental modification
* Preserves system stability
* Maintains professional engagement standards

---

## 15. Defensive Lessons and Best Practices

From a defensive standpoint:

* Never expose NFS publicly
* Use NFSv4 with Kerberos
* Enforce `root_squash`
* Avoid `insecure` and `nohide`
* Audit exports regularly
* Monitor for exposed credentials

---

## 16. Conclusion

NFS is powerful but inherently **trust-based and fragile** when misconfigured. Enumeration of NFS services frequently yields **high-impact findings** such as credential exposure and privilege escalation paths.

When accessible, NFS often represents a **direct bridge from external access to internal compromise**, making it a high-priority service during enumeration and a high-risk service when improperly secured .




Below is a **clean, practitioner-ready checklist** distilled directly from the previous NFS report. It is designed for **use during an engagement** (enumeration → exploitation → documentation) and can also double as a **defensive audit checklist** if read bottom-up.

---

# NFS Enumeration & Security Checklist

## 1. Service Identification

* ⬜ Scan for RPC services

  * ⬜ TCP/UDP **111** (rpcbind)
  * ⬜ TCP/UDP **2049** (NFS)
* ⬜ Identify supported NFS versions (v2 / v3 / v4 / v4.1)
* ⬜ Confirm transport protocol (TCP vs UDP)

---

## 2. Initial Enumeration

* ⬜ Run `rpcinfo -p <target>`
* ⬜ Enumerate NFS exports with:

  ```bash
  showmount -e <target>
  ```
* ⬜ Record:

  * ⬜ Exported directories
  * ⬜ Allowed IP ranges / subnets
  * ⬜ Access mode (ro / rw)

---

## 3. Export Configuration Review (`/etc/exports` Logic)

For each discovered export, assess:

* ⬜ Access level

  * ⬜ `rw` (high risk)
  * ⬜ `ro`
* ⬜ Authentication assumptions

  * ⬜ UID/GID based only
* ⬜ Write behavior

  * ⬜ `sync`
  * ⬜ `async` (riskier)
* ⬜ Port restrictions

  * ⬜ `secure`
  * ⬜ `insecure` ⚠️
* ⬜ Filesystem exposure

  * ⬜ `no_subtree_check`
  * ⬜ `nohide` ⚠️
* ⬜ Root behavior

  * ⬜ `root_squash`
  * ⬜ `no_root_squash` ⚠️ **CRITICAL**

---

## 4. Mounting the Share

* ⬜ Create local mount directory
* ⬜ Mount NFS share:

  ```bash
  mount -t nfs <target>:/ ./target-NFS -o nolock
  ```
* ⬜ Verify mount success
* ⬜ Confirm file visibility

---

## 5. Permission & Ownership Analysis

* ⬜ List files with ownership:

  ```bash
  ls -la
  ```
* ⬜ Identify:

  * ⬜ UID values
  * ⬜ GID values
* ⬜ Note mismatches between server and local users
* ⬜ Check for writable directories or files

---

## 6. UID/GID Manipulation Testing

* ⬜ Identify target UID/GID of sensitive files
* ⬜ Create matching local user/group
* ⬜ Re-access files as mapped UID/GID
* ⬜ Validate access bypass success

---

## 7. Sensitive Data Discovery

Search mounted share for:

* ⬜ SSH keys

  * ⬜ `id_rsa`
  * ⬜ `id_rsa.pub`
* ⬜ Backup files
* ⬜ Configuration files
* ⬜ Scripts (cron, deployment, admin)
* ⬜ Credentials or secrets

---

## 8. SSH Key Impact Assessment

If private keys are found:

* ⬜ Confirm key validity
* ⬜ Check reuse across systems
* ⬜ Test SSH access (within engagement rules)
* ⬜ Document lateral movement potential

---

## 9. Privilege Escalation Potential

* ⬜ Check for `no_root_squash`
* ⬜ Attempt root-level file access (if allowed)
* ⬜ Identify possibility to:

  * ⬜ Drop SUID binaries
  * ⬜ Modify system files
  * ⬜ Backdoor authentication mechanisms

---

## 10. Post-Enumeration Cleanup

* ⬜ Unmount NFS share:

  ```bash
  umount ./target-NFS
  ```
* ⬜ Verify no lingering mounts
* ⬜ Remove temporary users/groups if created

---

## 11. Risk Classification

* ⬜ NFS exposed externally ⚠️
* ⬜ Writable exports ⚠️
* ⬜ `no_root_squash` ⚠️⚠️
* ⬜ Exposed credentials ⚠️⚠️⚠️
* ⬜ Lateral movement enabled ⚠️⚠️⚠️

---

## 12. Reporting Requirements

* ⬜ Document discovered exports
* ⬜ Record configuration weaknesses
* ⬜ Capture evidence (screenshots / listings)
* ⬜ Map findings to:

  * ⬜ Privilege escalation
  * ⬜ Credential compromise
  * ⬜ Lateral movement
* ⬜ Provide remediation guidance

---

## 13. Defensive Hardening Checklist (Optional)

* ⬜ Disable public NFS exposure
* ⬜ Enforce `root_squash`
* ⬜ Remove `insecure` and `nohide`
* ⬜ Use NFSv4 with Kerberos
* ⬜ Restrict exports to minimum hosts
* ⬜ Audit NFS exports regularly
* ⬜ Rotate exposed credentials immediately

---

### Final Note

If this checklist is followed end-to-end and yields **no findings**, NFS is likely **correctly restricted or hardened**. If even one critical box is checked, NFS often represents a **high-impact compromise path**.

