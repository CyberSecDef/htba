# MySQL / MariaDB

### Architecture, Misconfiguration Risks, Enumeration, and Exploitation

---

## 1. Executive Overview

MySQL is one of the **most commonly deployed relational database management systems** and therefore one of the **highest-value targets** in penetration tests. It often sits behind applications, quietly storing credentials, personal data, and business-critical information. When misconfigured—or simply exposed—it can provide **direct access to sensitive data** or act as a **pivot point** for further compromise.

From an attacker’s perspective, MySQL is valuable because:

* It frequently contains **credentials and hashes**
* It often runs with **excessive privileges**
* It is commonly **exposed unintentionally**
* Errors and verbose output can enable **SQL injection exploitation**
* Configuration files may leak **plaintext credentials**

---

## 2. MySQL Fundamentals

### 2.1 Purpose and Design

MySQL is an **open-source SQL relational database management system**, developed and supported by Oracle. It stores structured data in tables composed of:

* Columns (data fields)
* Rows (records)
* Defined data types

The system is optimized for:

* High-performance querying
* Efficient storage
* Concurrent access by multiple clients

MySQL follows a **client–server architecture**, consisting of:

* **MySQL Server** – the database engine
* **MySQL Clients** – tools and applications issuing SQL queries

Databases are often backed up or distributed as `.sql` files, such as `wordpress.sql`.

---

## 3. MySQL Clients and Application Usage

### 3.1 Client Interaction Model

MySQL clients interact with the server using **Structured Query Language (SQL)** to:

* Insert data
* Delete data
* Modify records
* Retrieve information
* Manage users and permissions
* Alter database structure

Multiple clients can issue queries simultaneously, making MySQL suitable for **high-traffic applications**.

---

### 3.2 Real-World Example: WordPress

WordPress demonstrates a common MySQL deployment pattern:

* Database accessible only from `localhost`
* Stores:

  * Posts
  * Usernames
  * Password hashes
  * Metadata
* PHP scripts act as the intermediary

While passwords are usually hashed before storage, **database compromise still exposes authentication material** that can often be cracked or reused.

---

## 4. MySQL in Web Architectures

### 4.1 LAMP / LEMP Stacks

MySQL is commonly deployed as part of:

* **LAMP** (Linux, Apache, MySQL, PHP)
* **LEMP** (Linux, Nginx, MySQL, PHP)

In these architectures, MySQL acts as a **central data store** for:

* User accounts
* Permissions
* Email addresses
* Password hashes
* Business logic data
* Application configuration

This makes database compromise equivalent to **full application compromise**.

---

## 5. Data Stored in MySQL Databases

MySQL databases commonly contain:

* Authentication data (users, roles, permissions)
* Personally identifiable information (PII)
* Internal and external links
* Application secrets
* Configuration values
* Sensitive business records

While passwords are typically hashed, **misconfigured applications may still store plaintext or weakly encrypted secrets**.

---

## 6. MySQL Commands and Error Handling

### 6.1 SQL Command Capabilities

SQL allows:

* Data manipulation (SELECT, INSERT, UPDATE, DELETE)
* Schema changes (CREATE, ALTER, DROP)
* Relationship and index management
* User and privilege management

From an attacker’s perspective, **SQL errors are extremely valuable**. Error messages often:

* Reveal database structure
* Confirm backend database type
* Disclose query logic
* Enable SQL injection refinement

Verbose error handling is a common precursor to **successful SQL injection exploitation**.

---

## 7. MariaDB Relationship

MariaDB is a **fork of MySQL**, created after Oracle acquired MySQL AB. It is:

* Largely compatible with MySQL
* Frequently used as a drop-in replacement
* Common in Linux distributions

From a penetration-testing standpoint, **MySQL and MariaDB are treated identically** in most cases.

---

## 8. Default MySQL Configuration Analysis

The default configuration shows:

* Service running as the `mysql` user
* Listening on TCP port **3306**
* Local UNIX socket enabled
* Data stored in `/var/lib/mysql`
* Name resolution disabled (`skip-name-resolve`)
* Symbolic links disabled

While reasonable by default, **security depends heavily on file permissions, network exposure, and user management**.

---

## 9. Dangerous Configuration Settings

### 9.1 Credential Exposure Risks

Security-critical options include:

* `user`
* `password`
* `admin_address`

These values are often stored **in plaintext** within configuration files. If an attacker gains:

* File read access
* Local shell access
* Backup file access

They may recover **database credentials directly**, bypassing authentication controls entirely.

---

### 9.2 Debugging and Verbosity Risks

Settings such as:

* `debug`
* `sql_warnings`

Increase verbosity and are useful for administrators—but dangerous when exposed to users or applications.

These settings:

* Leak internal behavior
* Aid SQL injection discovery
* Expose sensitive operational details

When error output reaches a web application, **SQL injection risk increases dramatically**.

---

## 10. Network Exposure and Footprinting

### 10.1 MySQL Exposure Risks

MySQL is sometimes exposed externally due to:

* Temporary troubleshooting
* Misunderstood requirements
* Poor firewall rules
* Forgotten test environments

Exposing MySQL to untrusted networks is **almost always a security failure**.

---

### 10.2 Nmap Enumeration

Using Nmap against TCP port 3306 can reveal:

* MySQL version
* Authentication plugins
* Supported capabilities
* User enumeration results
* Empty or weak password conditions

However, the document correctly emphasizes:

> **Scan results must be manually validated**

False positives—such as empty root passwords—are common and must be confirmed with direct interaction.

---

## 11. Authentication Validation

Manual testing confirms whether:

* Accounts truly have empty passwords
* Credentials are valid
* Network restrictions are in place

A failed login attempt demonstrates that **automated tools can mislead**, reinforcing the need for disciplined verification.

---

## 12. Authenticated MySQL Interaction

Once valid credentials are obtained, attackers can:

* List databases
* Identify MySQL version
* Access system schemas
* Enumerate users and privileges
* Extract sensitive data

The example shows access to:

* `mysql`
* `information_schema`
* `performance_schema`
* `sys`

These schemas provide **deep insight into server behavior and usage**.

---

## 13. System Schema (`sys`) and Information Schema

### 13.1 System Schema (`sys`)

Contains:

* Performance metrics
* Host summaries
* User connection statistics
* Query latency data

This information can reveal:

* Active hosts
* User behavior patterns
* Potential pivot targets

---

### 13.2 Information Schema

Contains standardized metadata required by ANSI/ISO SQL standards.

Together, these schemas provide:

* Visibility into internal structure
* Confirmation of privilege levels
* Insight into operational usage

---

## 14. Core MySQL Commands (Operational Knowledge)

Essential commands include:

* Connecting to the server
* Listing databases
* Selecting databases
* Enumerating tables and columns
* Querying records
* Filtering results

These commands form the **foundation of both legitimate administration and attacker data extraction**.

---

## 15. Attacker Workflow Summary

A realistic MySQL attack path:

1. Identify exposed MySQL service
2. Enumerate version and capabilities
3. Validate authentication weaknesses
4. Obtain credentials (brute force, reuse, config files)
5. Enumerate databases and schemas
6. Extract sensitive data
7. Pivot to application or OS compromise

Databases are rarely isolated—they are **integration hubs**.

---

## 16. Defensive Implications (Contextual)

The document implicitly highlights key defensive failures:

* External database exposure
* Weak or reused credentials
* Excessive verbosity
* Insecure configuration file permissions
* Over-privileged database users

Any one of these can lead to **full data compromise**.

---

## 17. Key Takeaways

* MySQL is a **high-impact target**
* Configuration mistakes are common
* Errors and verbosity are exploitable
* Credential exposure often bypasses application security
* Database compromise usually means **application compromise**

---

## 18. Conclusion

MySQL sits at the center of most modern application stacks, quietly holding the keys to authentication, identity, and sensitive data. While robust when properly secured, it is unforgiving when misconfigured. Penetration testers should treat MySQL as both a **primary intelligence source** and a **potential initial access vector**, while defenders must treat it as **critical infrastructure**, not just backend plumbing.

---


Below is a **Red-Team MySQL Exploitation Playbook**, written for **real-world penetration tests, red-team operations, and exam readiness**. It is fully aligned with the MySQL material you provided and assumes proper authorization. 

---

# Red Team Playbook

## MySQL / MariaDB Exploitation

---

## 1. Objectives

Primary red-team objectives when targeting MySQL:

* Identify **exposed or weakly protected MySQL services**
* Obtain **valid database credentials**
* Extract **sensitive data** (users, hashes, PII, secrets)
* Abuse **database privileges** for persistence or escalation
* Leverage MySQL as a **pivot point** into applications or the OS

A compromised database often equals **full application compromise**.

---

## 2. Threat Model Overview

### Why MySQL Is a Prime Target

* Stores credentials and authentication material
* Often runs with excessive privileges
* Frequently exposed unintentionally
* Relies on application-layer trust
* Verbose errors enable SQL injection abuse

### Common Red-Team Outcomes

* Credential harvesting
* Password hash extraction
* Business data exfiltration
* Application impersonation
* OS-level command execution (in some configs)

---

## 3. Phase 1 – Discovery & Footprinting

### 3.1 Service Identification

**Target:**

* TCP **3306** (default MySQL)

Actions:

* Scan for MySQL service
* Identify version and authentication plugin
* Determine whether TLS is required or optional

Key indicators:

* MySQL banner
* Version string
* Auth plugin (e.g., `caching_sha2_password`)
* External accessibility (high risk)

---

### 3.2 Exposure Validation

Confirm:

* Is MySQL reachable externally?
* Is access limited by IP?
* Is name resolution disabled?
* Is TLS enforced?

Externally reachable MySQL is usually **misconfiguration, not design**.

---

## 4. Phase 2 – Authentication Attacks

### 4.1 Default & Weak Credential Testing

Test common accounts:

* `root`
* `admin`
* `dbadmin`
* `web`
* `test`
* `guest`

Test for:

* Empty passwords
* Password = username
* Known weak patterns

Automated results **must be manually validated**.

---

### 4.2 Credential Brute Forcing (Selective)

If allowed by scope:

* Use small, targeted wordlists
* Focus on high-value accounts
* Monitor for lockout behavior

Avoid blind brute forcing—MySQL often logs aggressively.

---

### 4.3 Credential Reuse

Test credentials obtained from:

* Web apps
* CMS configs
* Environment files
* SSH / VPN leaks
* Prior breaches

Database credentials are **frequently reused elsewhere**.

---

## 5. Phase 3 – Authenticated Enumeration

Once authenticated, immediately establish **privilege context**.

### 5.1 Server & Version Confirmation

* Confirm exact MySQL/MariaDB version
* Identify OS via metadata
* Confirm architecture and features

---

### 5.2 Database Enumeration

Enumerate:

* All databases
* Application-specific schemas
* Backup or legacy databases

High-value targets:

* CMS databases
* Auth/user databases
* Forgotten dev or test schemas

---

### 5.3 Table & Column Enumeration

Focus on tables containing:

* Users
* Passwords / hashes
* Tokens
* API keys
* Session data
* Permissions / roles

Column names often reveal **exact application logic**.

---

## 6. Phase 4 – Data Extraction

### 6.1 Credential Harvesting

Extract:

* Usernames
* Password hashes
* Password reset tokens
* Email addresses

Operational value:

* Offline cracking
* Credential reuse
* Phishing enablement
* Direct impersonation

---

### 6.2 Sensitive Business Data

Extract:

* Customer data
* Financial records
* Internal documentation
* Application secrets

Even read-only access can cause **catastrophic impact**.

---

## 7. Phase 5 – Privilege Escalation Inside MySQL

### 7.1 Privilege Enumeration

Check for:

* `SUPER`
* `FILE`
* `PROCESS`
* `EVENT`
* `GRANT OPTION`

These privileges enable **advanced abuse paths**.

---

### 7.2 File System Interaction (If Permitted)

With `FILE` privilege:

* Read local files
* Write files (web shells, cron abuse)

This can bridge **database compromise → OS compromise**.

---

### 7.3 User & Permission Abuse

If privileged:

* Create new database users
* Grant excessive permissions
* Establish persistence accounts
* Hide malicious access under “service” users

---

## 8. Phase 6 – Exploitation via SQL Injection (Chained)

### 8.1 SQL Injection as Entry Vector

Common paths:

* Login forms
* Search fields
* API endpoints
* CMS plugins

Indicators:

* Verbose SQL errors
* Application crashes
* Unexpected query behavior

---

### 8.2 Injection → Database Takeover

Once injection is reliable:

* Dump entire databases
* Enumerate users and hashes
* Modify application logic
* Create backdoor accounts

Injection often yields **database admin access indirectly**.

---

## 9. Phase 7 – Persistence Strategies

### 9.1 Database-Level Persistence

Options:

* Create stealth users
* Embed credentials in tables
* Modify application config values
* Abuse scheduled events

Persistence should survive **application restarts**.

---

### 9.2 Application Persistence

Leverage database access to:

* Add admin users
* Reset passwords silently
* Disable security checks
* Modify feature flags

Applications trust databases implicitly.

---

## 10. Phase 8 – Lateral Movement Enablement

Use MySQL-derived data to:

* Compromise application servers
* Move into admin panels
* Access cloud services
* Pivot to internal networks

Databases are **identity aggregation points**.

---

## 11. OPSEC Considerations

### 11.1 Noise Reduction

* Avoid mass table dumps at once
* Query selectively
* Minimize write operations
* Avoid schema changes unless required

---

### 11.2 Indicators to Avoid Triggering

* Excessive failed logins
* Dropping or altering tables
* Creating obvious admin users
* Triggering application errors

A quiet database attacker lives long.

---

## 12. Reporting Guidance

Document clearly:

* Exposure vector
* Credentials obtained
* Databases accessed
* Data sensitivity
* Privileges abused
* Business impact
* Exploitation potential (even if not executed)

Database findings are usually **high-severity**.

---

## 13. Common Defender Failures (Observed)

* Exposing MySQL externally
* Weak or reused credentials
* Over-privileged database users
* Verbose SQL errors in production
* Insecure config file permissions

Databases fail silently—and expensively.

---

## 14. Red-Team Success Criteria

* Valid database credentials obtained
* Sensitive data extracted
* Privilege escalation demonstrated
* Application compromise enabled
* Minimal detection footprint

---

## 15. Final Takeaway

MySQL is not “just backend storage.” It is the **authoritative source of truth** for most applications. When compromised, it provides attackers with credentials, identities, logic, and leverage—often without touching the operating system.

A disciplined red team treats MySQL as both a **primary target** and a **strategic pivot**, exploiting misconfiguration and trust relationships rather than relying solely on vulnerabilities.

---

Below is a **Blue-Team MySQL Detection & Hardening Guide**, written to **directly counter real-world MySQL/MariaDB attack techniques**, support **SOC detection engineering**, and provide **clear hardening actions** suitable for audits, IR, and production environments. It fully aligns with the MySQL material you provided. 

---

# Blue Team Guide

## MySQL / MariaDB Detection, Hardening, and Incident Response

---

## 1. Defensive Objectives

Blue-team priorities for MySQL:

* **Detect unauthorized database access quickly**
* **Prevent external exposure of MySQL services**
* **Protect credentials, hashes, and sensitive records**
* **Eliminate dangerous configurations and privileges**
* **Reduce blast radius if a database is compromised**
* **Ensure MySQL is monitored like a Tier-0 asset**

A compromised database is not a backend issue—it is a **business-impact event**.

---

## 2. Threat Model Summary

### Common MySQL Attack Paths

* Exposed TCP 3306 to untrusted networks
* Weak or reused database credentials
* Verbose SQL errors aiding SQL injection
* Over-privileged database users
* Credential leakage via config files or backups
* SQL injection → database takeover

### Why MySQL Is a High-Value Target

* Central store of credentials and identities
* Trusted implicitly by applications
* Often poorly monitored
* Frequently misconfigured “temporarily”
* Errors leak meaningful intelligence

---

## 3. Detection Strategy

### 3.1 Network-Level Detection (Critical)

**Monitor and alert on:**

* Any inbound connection to TCP **3306** from non-application networks
* External IPs attempting MySQL connections
* New source IPs accessing MySQL
* Connections outside expected maintenance windows

**Best practice:**

* MySQL should **never** be directly reachable from the internet.

If 3306 is internet-accessible, treat it as **high-severity** immediately.

---

### 3.2 Authentication Monitoring

Log and alert on:

* Failed login attempts
* Successful logins from new IPs
* Use of high-privilege accounts (`root`, admin users)
* Logins without TLS (if TLS is supported)

**High-risk indicators:**

* Multiple failed attempts followed by success
* Access by unused or legacy accounts
* Connections from user workstations instead of application servers

---

### 3.3 Query & Behavior Monitoring

Enable logging for:

* Schema enumeration (`SHOW DATABASES`, `SHOW TABLES`)
* Access to system schemas (`mysql`, `information_schema`, `sys`)
* Large `SELECT *` operations
* Bulk data extraction patterns

These behaviors are **human-unlikely** but attacker-common.

---

### 3.4 SQL Error & Injection Detection

Monitor applications and database logs for:

* SQL syntax errors
* Repeated malformed queries
* Error-based injection indicators
* Time-based query anomalies

Verbose errors are often the **first sign of SQL injection probing**.

---

## 4. Hardening Strategy (Authoritative)

### 4.1 Network Exposure Hardening (Top Priority)

* Bind MySQL to **localhost** or private IP only
* Enforce firewall rules allowing only application servers
* Block MySQL traffic at network borders
* Use VPN or bastion hosts for admin access

**Rule:**
If an attacker can see MySQL, it is already a failure.

---

### 4.2 Authentication & Credential Security

#### Enforce:

* Strong, unique passwords for all DB users
* TLS for all client connections
* Password rotation for service accounts
* Separate credentials per application

#### Disable:

* Empty passwords
* Password reuse across environments
* Shared database accounts
* Anonymous users

Database credentials must be treated like **root-level secrets**.

---

### 4.3 User & Privilege Hardening

Apply **least privilege** strictly:

* Remove unnecessary users
* Restrict users to required databases only
* Eliminate excessive privileges:

  * `SUPER`
  * `FILE`
  * `PROCESS`
  * `EVENT`
  * `GRANT OPTION`

**Never grant more privileges “just in case.”**

---

### 4.4 Configuration File Protection

Critical protections:

* Restrict permissions on MySQL config files
* Protect files containing:

  * Usernames
  * Passwords
  * Admin addresses
* Audit backups for credential leakage

If attackers can read config files, authentication is already bypassed.

---

### 4.5 Error & Verbosity Reduction

Disable or restrict:

* Excessive debugging
* Verbose SQL warnings in production
* Detailed error messages returned to applications

**Applications should log errors—not display them.**

Verbose errors dramatically increase SQL injection success.

---

### 4.6 SQL Injection Mitigation (Application Layer)

Enforce:

* Parameterized queries
* Prepared statements
* Input validation
* ORM safety features

The database cannot defend against unsafe application logic alone.

---

## 5. Logging & SIEM Integration

### Required Logs

* Authentication success/failure
* Source IP and user
* Database and schema accessed
* Privilege changes
* Query errors

### SIEM Use Cases

* New MySQL client sources
* Credential brute forcing
* Schema enumeration detection
* Large or unusual data reads
* Privilege escalation attempts

Database logs are **high-signal when monitored correctly**.

---

## 6. Incident Response Playbook (MySQL)

### 6.1 Triage

1. Identify affected database and host
2. Confirm access method (direct, application, injection)
3. Determine accounts used
4. Identify data accessed or modified

---

### 6.2 Containment

* Block attacker IPs
* Disable affected DB accounts
* Rotate database credentials
* Temporarily restrict DB access if needed

Containment should be **fast and decisive**.

---

### 6.3 Eradication

* Remove unauthorized users
* Reset all application DB credentials
* Fix SQL injection vectors
* Harden configuration and privileges
* Review all schemas for tampering

---

### 6.4 Recovery

* Restore clean state if needed
* Validate application functionality
* Increase monitoring sensitivity temporarily
* Document findings and lessons learned

---

## 7. Architecture & Strategic Controls

### 7.1 Segmentation & Trust Boundaries

* Separate database tier from application tier
* Enforce one-way trust (apps → DB)
* Restrict admin access paths

---

### 7.2 Backup & Data Protection

* Encrypt database backups
* Restrict backup access
* Audit backup locations regularly

Backups are a **favorite exfiltration target**.

---

## 8. Metrics & Continuous Improvement

Track:

* Number of exposed MySQL instances
* Privileged DB accounts count
* SQL injection incidents
* Mean time to detect DB abuse
* Percentage of TLS-protected DB connections

What you measure is what attackers exploit.

---

## 9. Common Blue-Team Failures

* Exposing MySQL “temporarily”
* Leaving default or legacy users
* Over-privileging application accounts
* Logging too little—or too late
* Treating SQL injection as “just a dev issue”

Databases fail quietly until damage is done.

---

## 10. Executive Takeaway

MySQL is **core infrastructure**, not a background service.
If compromised, it exposes identities, credentials, and business logic in one move.

A mature blue team:

* Eliminates unnecessary exposure
* Enforces least privilege ruthlessly
* Monitors database access continuously
* Treats database incidents as **enterprise-level security events**
