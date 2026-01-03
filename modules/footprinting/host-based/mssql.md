# Microsoft SQL Server (MSSQL)

### Architecture, Misconfiguration Risks, Enumeration, and Exploitation

---

## 1. Executive Overview

Microsoft SQL Server (MSSQL) is a **core enterprise database platform**, most commonly deployed in **Windows domain environments** and tightly integrated with **Active Directory** and the **.NET ecosystem**. Unlike MySQL, MSSQL is closed source and historically Windows-centric, which creates **unique attack paths tied directly to Windows authentication, domain trust, and service accounts**.

From a penetration-testing perspective, MSSQL is especially valuable because:

* It often runs with **domain-integrated authentication**
* It may execute commands **as Windows service accounts**
* It is frequently managed via **rich GUI clients with stored credentials**
* Misconfigurations can enable **direct OS command execution**
* Database compromise can quickly become **domain compromise**

---

## 2. MSSQL Fundamentals

### 2.1 Purpose and Design

MSSQL is Microsoft’s SQL-based relational database management system. It is commonly used for:

* Enterprise applications
* Internal business systems
* .NET-based services
* ERP and CRM platforms

While MSSQL now supports Linux and macOS, **Windows remains the dominant deployment target**, especially in corporate environments.

---

## 3. MSSQL Clients

### 3.1 SQL Server Management Studio (SSMS)

SSMS is the **primary administrative client** for MSSQL:

* Often installed directly on the database server
* Frequently installed on admin or developer workstations
* Supports saved connections and cached credentials

**Penetration-testing relevance:**

* Compromised endpoints may contain **saved MSSQL credentials**
* SSMS presence indicates **active database administration**
* Credentials stored here often have **high privilege**

The fact that SSMS is client-side—not server-side—means **credential exposure may occur far from the database itself**.

---

### 3.2 Alternative MSSQL Clients

Other MSSQL clients include:

* `mssql-cli`
* SQL Server PowerShell
* HeidiSQL
* SQLPro
* Impacket’s `mssqlclient.py`

For penetration testers, **Impacket’s `mssqlclient.py`** is especially valuable:

* Preinstalled on many pentesting distributions
* Supports Windows authentication
* Enables interactive T-SQL execution
* Integrates cleanly with domain credentials

---

## 4. MSSQL Databases

### 4.1 Default System Databases

MSSQL includes several **system databases** critical to both operations and attacks:

| Database   | Purpose                                               |
| ---------- | ----------------------------------------------------- |
| `master`   | Tracks system-level configuration and metadata        |
| `model`    | Template for all newly created databases              |
| `msdb`     | Used by SQL Server Agent for jobs, alerts, automation |
| `tempdb`   | Stores temporary objects and intermediate results     |
| `resource` | Read-only system objects shipped with SQL Server      |

**Security impact:**

* `msdb` often reveals scheduled jobs and credentials
* `model` misconfigurations propagate into all new databases
* `master` exposes server-wide configuration

---

## 5. Default Configuration & Authentication

### 5.1 Service Account Context

When initially installed:

* MSSQL typically runs as `NT SERVICE\MSSQLSERVER`
* This is a **virtual service account** with OS-level permissions

Misconfigurations here can allow:

* OS-level privilege escalation
* Lateral movement using service account context

---

### 5.2 Windows Authentication

By default, MSSQL supports **Windows Authentication**, meaning:

* Authentication is delegated to:

  * Local SAM database, or
  * Active Directory Domain Controller
* Database access is directly tied to **Windows user or domain credentials**

**Security implication:**

* Compromised domain accounts may grant database access
* Compromised MSSQL access may enable **domain reconnaissance**
* Trust flows both directions

By default, **encryption is not enforced** for client connections.

---

## 6. Dangerous Configuration Settings

MSSQL is highly configurable, and real-world deployments often include **dangerous shortcuts**.

### 6.1 Encryption Issues

* Clients connecting without encryption
* Use of self-signed certificates
* Susceptibility to certificate spoofing

This enables:

* Credential interception
* Man-in-the-middle attacks
* Session hijacking

---

### 6.2 Named Pipes

* Enables local or network IPC connections
* Often overlooked in firewall rules
* Can bypass TCP-only restrictions

Named pipes expand the attack surface beyond port 1433.

---

### 6.3 `sa` Account Misuse

* Weak or default passwords
* Account left enabled unnecessarily
* Frequently targeted by automated tools

The `sa` account represents **full administrative control** of SQL Server.

---

## 7. Footprinting the MSSQL Service

### 7.1 Nmap MSSQL Script Scanning

Nmap provides extensive MSSQL-specific scripts that can reveal:

* Hostname and instance name
* MSSQL version and patch level
* Named pipes configuration
* NTLM information
* Whether DAC (Dedicated Admin Connection) is enabled

The sample scan demonstrates:

* SQL Server 2019 RTM
* Named pipes enabled
* Instance name `MSSQLSERVER`
* Host metadata via NTLM

This information significantly **reduces attacker uncertainty**.

---

### 7.2 Metasploit MSSQL Ping

Metasploit’s `mssql_ping` auxiliary module provides:

* Instance name
* Version
* Cluster status
* Transport mechanisms (TCP / named pipes)

It is fast, reliable, and often **less noisy than full scans**.

---

## 8. Authentication & Remote Interaction

### 8.1 Connecting via Impacket `mssqlclient.py`

If valid credentials are obtained:

* Attackers can authenticate using **Windows Authentication**
* TLS may be automatically negotiated
* Full T-SQL interaction becomes possible

Once connected, attackers can:

* Enumerate databases
* Query system metadata
* Execute administrative functions (depending on privilege)

The example shows successful enumeration of:

* `master`
* `tempdb`
* `model`
* `msdb`
* Custom application database (`Transactions`)

---

## 9. T-SQL Interaction & Enumeration

After authentication, attackers typically:

* Identify accessible databases
* Enumerate tables and schemas
* Inspect jobs, users, and permissions
* Query configuration and security settings

MSSQL metadata is **rich, verbose, and highly informative**.

---

## 10. Attacker Workflow Summary

A realistic MSSQL attack chain:

1. Discover MSSQL service (1433 / named pipes)
2. Enumerate instance details
3. Identify authentication methods
4. Obtain credentials (reuse, dump, brute force, endpoint compromise)
5. Authenticate via Windows or SQL auth
6. Enumerate system databases
7. Abuse privileges or pivot to OS/domain
8. Escalate impact via jobs, command execution, or AD trust

MSSQL is often **not the end goal**, but a **gateway to deeper compromise**.

---

## 11. Defensive Implications (Contextual)

The document implicitly highlights common MSSQL failures:

* Lack of enforced encryption
* Weak service account hygiene
* Over-trusted Windows authentication
* Insufficient monitoring of database access
* Exposure of metadata via scanning

In Windows environments, **MSSQL compromise frequently cascades**.

---

## 12. Key Takeaways

* MSSQL is tightly coupled to Windows security
* Database access often equals domain visibility
* Misconfigurations are common under operational pressure
* GUI tools introduce credential-storage risk
* Enumeration alone can yield high-value intelligence

---

## 13. Conclusion

Microsoft SQL Server is not merely a database—it is a **first-class Windows service** embedded in enterprise identity, automation, and trust models. When misconfigured or accessed improperly, MSSQL provides attackers with visibility, leverage, and execution pathways that extend far beyond data theft.

For penetration testers, MSSQL should be treated as both a **primary target** and a **strategic pivot point**. For defenders, it must be treated as **Tier-0 infrastructure**, deserving the same scrutiny as domain controllers and identity systems.

---

# Red Team Playbook

## Microsoft SQL Server (MSSQL) Exploitation

---

## 1. Objectives

Primary red-team objectives when targeting MSSQL:

* Identify **exposed or weakly protected MSSQL instances**
* Obtain **database or Windows-authenticated access**
* Abuse **SQL Server privileges** for command execution
* Pivot from MSSQL into the **underlying Windows OS or Active Directory**
* Establish **persistence** through jobs, credentials, or configuration abuse

In Windows environments, MSSQL is often a **stepping stone to domain compromise**.

---

## 2. Threat Model Overview

### Why MSSQL Is High Value

* Deep integration with Windows & Active Directory
* Supports Windows Authentication (Kerberos/NTLM)
* Can execute OS commands under service account context
* Often managed via GUI tools with saved credentials
* Frequently over-privileged “for convenience”

### Common Red-Team Wins

* Command execution via `xp_cmdshell`
* Credential harvesting from SQL Agent jobs
* Lateral movement using domain trust
* Persistence via scheduled jobs
* Data exfiltration + OS compromise

---

## 3. Phase 1 – Discovery & Footprinting

### 3.1 Service Identification

**Targets:**

* TCP **1433** (default MSSQL)
* Named pipes (`\\host\pipe\sql\query`)
* DAC (Dedicated Admin Connection)

Actions:

* Identify MSSQL version and patch level
* Detect named pipes usage
* Determine authentication methods enabled
* Identify instance names

**High-value findings:**

* MSSQL version (exploit compatibility)
* Instance name
* Whether encryption is enforced
* Whether named pipes are enabled

---

### 3.2 Metadata & NTLM Enumeration

Gather:

* Hostname
* Domain membership
* NetBIOS and DNS names
* OS version

This data supports:

* Kerberos abuse
* Lateral movement planning
* Target prioritization

---

## 4. Phase 2 – Authentication Attacks

### 4.1 SQL Authentication (High Risk, High Reward)

Test for:

* `sa` account enabled
* Weak or default passwords
* Password reuse from other services

Notes:

* Many admins forget to disable `sa`
* `sa` = full SQL Server control

---

### 4.2 Windows Authentication Abuse

Authenticate using:

* Compromised domain credentials
* Local admin accounts
* Service accounts

If Windows Auth succeeds:

* Database trust is already broken
* Domain trust may follow shortly

---

### 4.3 Credential Sources

Common credential sources:

* SSMS saved connections
* Configuration files on app servers
* Service account passwords
* Domain credential reuse
* Memory dumps from compromised hosts

---

## 5. Phase 3 – Authenticated Enumeration

Once authenticated, immediately determine **privilege level**.

### 5.1 Database Enumeration

Enumerate:

* User databases
* System databases (`master`, `msdb`, `model`)
* Application-specific schemas

High-value targets:

* `msdb` (jobs, credentials)
* Application databases
* Legacy or test databases

---

### 5.2 User & Role Enumeration

Determine:

* Server roles (`sysadmin`, `db_owner`)
* Database-level permissions
* Linked servers

If `sysadmin` is present, **assume OS execution is possible**.

---

## 6. Phase 4 – Command Execution

### 6.1 xp_cmdshell Abuse (Classic)

If enabled (or enable-able):

* Execute OS commands
* Enumerate filesystem
* Launch payloads
* Dump credentials

Execution context:

* MSSQL service account
* Often a domain account in enterprise environments

---

### 6.2 SQL Server Agent Jobs

Abuse job creation to:

* Execute PowerShell or CMD
* Schedule persistence
* Run under higher privilege contexts

Jobs are:

* Trusted
* Persistent
* Often under-monitored

---

### 6.3 Linked Server Abuse

If linked servers exist:

* Execute queries on remote servers
* Chain trust across SQL instances
* Move laterally inside database tiers

Linked servers often inherit **excessive trust**.

---

## 7. Phase 5 – Credential Harvesting

### 7.1 msdb Secrets

Extract from `msdb`:

* Job credentials
* Proxy accounts
* Connection strings
* Passwords for external services

This often yields:

* Domain credentials
* Service accounts
* Backup admin accounts

---

### 7.2 Memory & OS Credential Theft

If OS command execution exists:

* Dump LSASS (where possible)
* Extract cached credentials
* Enumerate Kerberos tickets

MSSQL is frequently a **credential bridge**.

---

## 8. Phase 6 – Lateral Movement

Use MSSQL-derived access to:

* Pivot to other SQL servers
* Access file shares
* Compromise application servers
* Move toward domain controllers

MSSQL service accounts are often **over-privileged**.

---

## 9. Phase 7 – Persistence

### 9.1 Database-Level Persistence

Techniques:

* Create new SQL logins
* Grant `sysadmin` quietly
* Embed credentials in jobs
* Modify existing jobs subtly

---

### 9.2 OS-Level Persistence

If OS access exists:

* Scheduled tasks
* Services
* Registry persistence
* Credential reuse elsewhere

Persistence should survive **password changes** if possible.

---

## 10. OPSEC Considerations

### 10.1 Noise Reduction

Best practices:

* Avoid enabling xp_cmdshell unless required
* Prefer existing jobs over new ones
* Limit brute forcing
* Query selectively

---

### 10.2 Indicators to Avoid Triggering

Avoid:

* Repeated login failures
* Dropping databases
* Obvious admin user creation
* Large data dumps during business hours

Quiet SQL attackers last longer.

---

## 11. Reporting Guidance

Document clearly:

* Entry vector (auth method)
* Privileges obtained
* OS execution capability
* Credentials harvested
* Domain impact
* Persistence paths

MSSQL findings often justify **critical severity**.

---

## 12. Common Defender Failures (Observed)

* Leaving `sa` enabled
* Not enforcing TLS
* Over-privileged service accounts
* Ignoring named pipes
* Poor monitoring of SQL jobs

MSSQL compromise is usually **predictable in hindsight**.

---

## 13. Red-Team Success Criteria

* Authenticated MSSQL access achieved
* Privilege escalation demonstrated
* OS or domain interaction enabled
* Sensitive data or credentials extracted
* Minimal detection footprint

---

## 14. Final Takeaway

MSSQL is not just a database—it is a **Windows-integrated execution platform**. When compromised, it often grants attackers command execution, credential access, and lateral movement paths that rival domain controllers in impact.

A disciplined red team treats MSSQL as:

* A **primary target**
* A **credential aggregation point**
* A **pivot into Active Directory**

---

Below is a **Blue-Team MSSQL Detection & Hardening Guide**, written to **directly counter real-world MSSQL exploitation techniques**, support **SOC detection engineering**, and provide **clear, actionable hardening steps** suitable for audits, incident response, and production environments. It aligns with the MSSQL material you provided and completes the red/blue playbook pair.

---

# Blue Team Guide

## Microsoft SQL Server (MSSQL) Detection, Hardening, and Incident Response

---

## 1. Defensive Objectives

Primary blue-team objectives for MSSQL:

* **Detect unauthorized or anomalous database access early**
* **Prevent MSSQL from becoming an OS or domain pivot**
* **Eliminate high-risk configurations and legacy access paths**
* **Protect credentials, jobs, and service accounts**
* **Reduce blast radius if MSSQL is compromised**
* **Treat MSSQL as Tier-0 infrastructure**

In Windows environments, MSSQL is not just a database—it is an **execution-capable, identity-integrated service**.

---

## 2. Threat Model Summary

### Common MSSQL Attack Paths

* Exposed TCP 1433 or named pipes
* Weak or enabled `sa` account
* Windows Authentication abuse via AD credentials
* Command execution via `xp_cmdshell`
* Credential exposure in SQL Agent jobs
* Excessive service account privileges
* Linked server trust abuse

### Why MSSQL Is High Risk

* Runs under Windows service accounts
* Integrates directly with Active Directory
* Supports scheduled execution and automation
* Often over-privileged for “operational convenience”
* Rich metadata enables attacker situational awareness

---

## 3. Detection Strategy

### 3.1 Network-Level Detection (Critical)

**Monitor and alert on:**

* Inbound connections to **TCP 1433** from non-application networks
* MSSQL traffic originating from user workstations
* External IPs attempting MSSQL connections
* Use of named pipes from unexpected hosts
* DAC (Dedicated Admin Connection) attempts

**Best practice:**

* MSSQL should never be reachable from the internet.
* Any external MSSQL exposure is a **high-severity incident**.

---

### 3.2 Authentication & Access Monitoring

Log and alert on:

* Failed login attempts (SQL and Windows auth)
* Successful logins from new or unusual hosts
* Use of privileged roles (`sysadmin`, `db_owner`)
* Logins using `sa`
* Windows-auth logins by service accounts or non-DB admins

**High-risk indicators:**

* Multiple failures followed by success
* Login activity outside maintenance windows
* New AD users accessing MSSQL

---

### 3.3 Privilege & Configuration Change Monitoring

Alert on:

* Enabling `xp_cmdshell`
* Changes to server roles
* Creation of new SQL logins
* Permission grants to `sysadmin`
* Changes to linked servers
* SQL Server Agent job creation or modification

These actions often indicate **post-compromise activity**.

---

### 3.4 SQL Agent & Job Monitoring

SQL Agent jobs are a **prime persistence mechanism**.

Monitor for:

* New or modified jobs
* Jobs executing PowerShell or CMD
* Jobs running under high-privilege proxy accounts
* Jobs scheduled at odd hours

If attackers persist in MSSQL, they often do it here.

---

## 4. Hardening Strategy (Authoritative)

### 4.1 Network Exposure Hardening (Top Priority)

* Bind MSSQL to **private IPs only**
* Enforce firewall rules allowing only application servers
* Block TCP 1433 at network boundaries
* Restrict named pipes access
* Use bastion hosts or jump servers for admin access

**Rule:**
If an attacker can scan MSSQL, defense has already failed.

---

### 4.2 Authentication Hardening

#### SQL Authentication

* Disable the `sa` account entirely
* Enforce strong password policies
* Remove unused SQL logins
* Prefer Windows Authentication where possible

#### Windows Authentication

* Restrict MSSQL access to dedicated AD groups
* Use separate accounts for:

  * DB admins
  * Service accounts
  * Applications
* Enforce MFA for admin access paths

Windows Auth improves auditing—but increases blast radius if misused.

---

### 4.3 Encryption Enforcement

* Enforce TLS for all MSSQL connections
* Disable unencrypted client connections
* Use certificates from trusted internal CAs
* Avoid self-signed certificates
* Monitor for TLS downgrade attempts

Unencrypted MSSQL enables **credential interception and MITM**.

---

### 4.4 Service Account Hardening

* Use **managed service accounts** where possible
* Avoid domain admin or excessive privileges
* Deny interactive logon for service accounts
* Rotate service account credentials regularly

Over-privileged service accounts turn MSSQL into a **domain attack platform**.

---

### 4.5 Feature Reduction (Critical)

Disable unless explicitly required:

* `xp_cmdshell`
* OLE Automation Procedures
* CLR integration (if not needed)
* Ad Hoc Distributed Queries
* Unnecessary linked servers

Every enabled feature is a potential execution path.

---

## 5. Least-Privilege Database Design

### 5.1 Role & Permission Management

* Grant only required permissions per application
* Avoid `sysadmin` for applications
* Restrict access to system databases
* Separate read/write roles

### 5.2 Linked Server Controls

* Remove unused linked servers
* Restrict credentials used for linked servers
* Avoid trust delegation across servers
* Monitor linked server usage

Linked servers often enable **silent lateral movement**.

---

## 6. Logging & SIEM Integration

### Required Logs

* Login success/failure
* Source IP and authentication type
* Role and permission changes
* Job execution logs
* Configuration changes

### SIEM Use Cases

* MSSQL login from new host
* `xp_cmdshell` enablement
* Job creation or modification
* `sa` account usage
* Large or unusual query activity

MSSQL logs are **high-fidelity signals** when properly collected.

---

## 7. Incident Response Playbook (MSSQL)

### 7.1 Triage

1. Identify affected SQL instance and host
2. Determine access method (SQL auth, Windows auth)
3. Identify accounts used
4. Check for command execution or job abuse
5. Assess OS and AD impact

---

### 7.2 Containment

* Block attacker IPs
* Disable compromised SQL logins
* Reset service account credentials
* Disable SQL Agent jobs if necessary
* Temporarily restrict database access

Speed matters—MSSQL compromise escalates fast.

---

### 7.3 Eradication

* Remove unauthorized logins and jobs
* Disable dangerous features
* Harden service account privileges
* Audit linked servers
* Review all system databases (`master`, `msdb`)

---

### 7.4 Recovery

* Restore clean configurations
* Re-enable only required features
* Validate application functionality
* Increase monitoring temporarily
* Conduct post-incident review

---

## 8. Architecture & Strategic Controls

### 8.1 Segmentation & Trust Boundaries

* Separate MSSQL from application tiers
* Enforce one-way trust (apps → DB)
* Restrict admin paths
* Monitor east–west traffic

### 8.2 Backup & Data Protection

* Encrypt database backups
* Restrict backup access
* Audit backup locations regularly

Backups are frequently overlooked **exfiltration targets**.

---

## 9. Metrics & Continuous Improvement

Track:

* Number of MSSQL instances exposed
* `sa` account status across environment
* `xp_cmdshell` enablement count
* SQL Agent job changes per quarter
* Mean time to detect MSSQL abuse

If you don’t measure it, attackers will use it.

---

## 10. Common Blue-Team Failures

* Leaving `sa` enabled “just in case”
* Allowing MSSQL to listen broadly
* Over-privileged service accounts
* Ignoring SQL Agent jobs
* Treating MSSQL as “just a database”

MSSQL failures are rarely subtle—just unmonitored.

---

## 11. Executive Takeaway

Microsoft SQL Server is a **Windows-integrated execution environment**, not merely a data store. When compromised, it provides attackers with:

* Command execution
* Credential access
* Lateral movement paths
* Domain visibility

A mature blue team treats MSSQL as **Tier-0 infrastructure**, applies least privilege relentlessly, and monitors it with the same seriousness as identity systems.

