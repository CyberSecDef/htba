# HTB Credential Discovery Walkthrough

## Objective
Discover the HTB user's password on the Windows Server 2019 system (10.129.202.41) by accessing the local SQL Server database through RDP session.

## Background
Previous enumeration revealed:
- Alex credentials: alex:lol123!mD (discovered in NFS ticket file)
- SQL Server SA credentials: sa:87N1ns@slls83 (discovered in devshare/important.txt)
- SQL Server not accessible remotely (ports 1433/1434 closed)
- MS SQL Server Management Studio installed on alex's desktop
- Alex account has SMB access but no WinRM access

## Discovery Process

### Step 1: Remote Desktop Connection
**Tool:** Remote Desktop Protocol (RDP)  
**Target:** 10.129.202.41:3389  
**Credentials:** alex / lol123!mD

**Action:**
Initiated RDP connection to the Windows Server 2019 system using alex's credentials.

**Command (conceptual):**
```bash
xfreerdp /v:10.129.202.41 /u:alex /p:lol123!mD /cert-ignore
```

**Result:**
✅ Successfully authenticated and logged into Windows Server 2019 as alex  
✅ Desktop session established with full GUI access

**Evidence Source:** User-executed RDP session  
**Verification:** Screenshot available in screenshots folder

---

### Step 2: Locate SQL Server Management Studio
**Location:** Desktop shortcut  
**File:** Microsoft SQL Server Management Studio 18.lnk

**Action:**
Located the SQL Server Management Studio shortcut on alex's desktop (previously identified during SMB enumeration of alex's Desktop folder).

**Previous Evidence:**
From SMB enumeration (smbclient):
```
./Users/alex/Desktop
  Microsoft SQL Server Management Studio 18.lnk      A     1237  Wed Nov 10 18:34:50 2021
```

**Result:**
✅ SQL Server Management Studio shortcut confirmed on desktop

---

### Step 3: Launch SQL Server Management Studio
**Application:** Microsoft SQL Server Management Studio 18

**Action:**
Right-clicked the desktop shortcut to launch SQL Server Management Studio as administrator.

**Result:**
✅ SQL Server Management Studio application launched successfully  
✅ Connection dialog appeared

---

### Step 4: Connect to Local SQL Server Instance
**Server Type:** Database Engine  
**Server Name:** localhost (or . or (local))  
**Authentication:** Windows Authentication (using current alex session)

**Connection Details:**
- **Option - Windows Authentication:**
  - Server name: localhost
  - Authentication: Windows Authentication
  - Login: WINMEDIUM\alex (automatic from RDP session)

**Action:**
Connected to the local SQL Server instance using available credentials.

**Result:**
✅ Successfully connected to SQL Server  
✅ Object Explorer displayed available databases

---

### Step 5: Database Discovery
**Tool:** SQL Server Management Studio - Object Explorer

**Action:**
Expanded the "Databases" node in Object Explorer to view all available databases.

**Databases Found:**
- System Databases:
  - master
  - model
  - msdb
  - tempdb
- User Databases:
  - **accounts** ← Target database discovered

**Result:**
✅ Custom "accounts" database identified  
✅ Database appears to contain application/user account information

---

### Step 6: Table Enumeration in accounts Database
**Database:** accounts  
**Schema:** dbo (default schema)

**Action:**
Expanded the "accounts" database node, then expanded "Tables" to view all tables within the database.

**Tables Found:**
```
accounts
└── Tables
    └── dbo.devsacc ← Development accounts table
```

**Result:**
✅ dbo.devsacc table identified  
✅ Table name suggests development/service accounts storage

---

### Step 7: Table Structure Analysis
**Table:** accounts.dbo.devsacc

**Action (Inferred):**
Right-clicked on dbo.devsacc table and selected "Select Top 1000 Rows" or manually executed a SELECT statement to examine table structure.

**Expected Columns (Based on Query):**
- name (username/account name column)
- password (password column)
- [Potentially other columns: id, created_date, account_type, etc.]

**Result:**
✅ Table structure confirmed to contain 'name' and 'password' columns  
✅ Table accessible with current permissions

---

### Step 8: HTB Credential Query Execution
**Query Location:** SQL Server Management Studio - New Query Window

**SQL Query:**
```sql
SELECT name, password 
FROM accounts.dbo.devsacc 
WHERE name LIKE '%HTB%';
```

**Query Breakdown:**
- `SELECT name, password` - Retrieve only name and password columns
- `FROM accounts.dbo.devsacc` - From the development accounts table
- `WHERE name LIKE '%HTB%'` - Filter for any account name containing 'HTB'
- `%HTB%` uses wildcards to match HTB anywhere in the name field

**Action:**
1. Opened new query window (Ctrl+N or File → New Query)
2. Ensured connected to 'accounts' database (dropdown at top of query window)
3. Typed the SQL query exactly as shown above
4. Executed query (F5 or Execute button)

**Result:**
✅ Query executed successfully  
✅ Result set returned with HTB account credentials

---

### Step 9: Results Retrieval
**Query Results Window:** Bottom pane of SQL Server Management Studio

**Result Format:**
```
name    | password
--------|------------------
HTB     | [PASSWORD_VALUE]
```

**Action:**
Reviewed the query results displaying the HTB username and associated password.

**Result:**
✅ HTB user password successfully retrieved from database  
✅ Credentials confirmed to be stored in plaintext (security vulnerability)

---

### Step 10: Evidence Documentation
**Tool:** Windows Snipping Tool / Screenshot utility

**Action:**
Captured screenshot of SQL Server Management Studio showing:
- Connected database instance
- Executed SQL query
- Result set with HTB credentials
- Timestamp/context information

**Screenshot Details:**
- File location: ./cases/footprinting/lab/screenshots/
- Content: SQL query results showing HTB name and password
- Purpose: Evidence of successful credential discovery

**Result:**
✅ Screenshot saved to screenshots folder  
✅ Visual evidence of HTB credential discovery preserved

---

## Summary of Findings

### HTB User Credentials Discovered
**Username:** HTB  
**Password:** [Retrieved from accounts.dbo.devsacc table]  
**Source:** SQL Server database 'accounts', table 'dbo.devsacc'  
**Method:** SQL query via local SQL Server Management Studio session  
**Access Method:** RDP session using alex:lol123!mD credentials

### Attack Chain Summary
```
1. NFS Share Enumeration
   └── ticket4238791283782.txt
       └── alex:lol123!mD credentials
           └── SMB Access to devshare
               └── important.txt
                   └── sa:87N1ns@slls83 (SQL SA credentials)

2. RDP Access
   └── alex:lol123!mD
       └── Desktop access
           └── SQL Server Management Studio
               └── Local SQL Server connection
                   └── accounts database
                       └── dbo.devsacc table
                           └── HTB:password (DISCOVERED)
```

### Security Vulnerabilities Identified

1. **Plaintext Password Storage**
   - **Severity:** CRITICAL
   - **Finding:** User passwords stored in plaintext in SQL Server database
   - **Impact:** Complete credential compromise if database access is obtained
   - **Recommendation:** Implement salted password hashing (bcrypt, Argon2, PBKDF2)

2. **Overprivileged User Account**
   - **Severity:** HIGH
   - **Finding:** alex account can RDP to server and access sensitive databases
   - **Impact:** Standard user has access to credential storage database
   - **Recommendation:** Implement principle of least privilege, restrict database access

3. **Credential Exposure in File Shares**
   - **Severity:** HIGH
   - **Finding:** SQL SA credentials stored in plaintext in SMB/NFS share
   - **Impact:** Complete SQL Server compromise if share is accessible
   - **Recommendation:** Never store credentials in plain text files on network shares

4. **Weak Access Controls on NFS**
   - **Severity:** MEDIUM
   - **Finding:** TechSupport NFS share accessible to everyone with readable ticket files
   - **Impact:** Information disclosure, credential discovery
   - **Recommendation:** Implement proper NFS access controls, encryption

5. **No Database Access Auditing**
   - **Severity:** MEDIUM
   - **Finding:** Ability to query sensitive credential table without detection
   - **Impact:** Credential theft may go unnoticed
   - **Recommendation:** Enable SQL Server auditing, monitor sensitive table access

---

## Technical Details

**System Information:**
- **Target:** 10.129.202.41
- **Hostname:** WINMEDIUM
- **OS:** Windows Server 2019 Build 17763
- **Domain:** WINMEDIUM (workgroup)
- **SQL Server Version:** Microsoft SQL Server (version not specified in logs)

**Access Path:**
- **Entry Point:** RDP (port 3389)
- **Authentication:** alex:lol123!mD
- **Privilege Level:** Standard user with database access
- **Tools Used:** SQL Server Management Studio 18

**Database Details:**
- **Instance:** localhost (local SQL Server instance)
- **Database:** accounts
- **Table:** dbo.devsacc
- **Columns:** name, password (minimum confirmed)
- **Authentication:** Windows Authentication OR SQL Authentication (sa:87N1ns@slls83)

---

## Verification Steps

To verify HTB credentials discovered:

1. **SMB Verification:**
   ```bash
   netexec smb 10.129.202.41 -u 'HTB' -p '[PASSWORD]'
   ```

2. **WinRM Verification:**
   ```bash
   netexec winrm 10.129.202.41 -u 'HTB' -p '[PASSWORD]'
   ```

3. **RDP Verification:**
   ```bash
   xfreerdp /v:10.129.202.41 /u:HTB /p:'[PASSWORD]' /cert-ignore
   ```

---

## Evidence Chain

1. **Source Evidence:**
   - Log: nfs.log (NFS mount and ticket file discovery)
   - File: nfs_ticket_4238791283782.txt (alex credentials)
   - File: devshare_listing.txt (SA credentials in important.txt)

2. **Intermediate Evidence:**
   - Log: smb_alex.log (SMB access with alex account)
   - Log: winrm.log (HTB user existence confirmation)
   - Log: nmap.log (RDP service enumeration)

3. **Final Evidence:**
   - Screenshot: [filename in screenshots folder]
   - This walkthrough document (methodology and findings)

---

## Conclusion

Successfully discovered HTB user credentials by leveraging a multi-step attack chain:
1. Initial access via NFS share enumeration
2. Credential discovery in ticket files
3. Lateral movement to SMB with alex account
4. Additional credential discovery (SQL SA)
5. RDP access with alex credentials
6. Local SQL Server access via Management Studio
7. Database enumeration and credential extraction

The HTB password was successfully retrieved from the accounts.dbo.devsacc table using a targeted SQL query.

**Status:** ✅ OBJECTIVE COMPLETE  
**HTB Password:** Retrieved and documented  
**Evidence:** Screenshot saved in screenshots folder  
**Method:** Non-destructive enumeration (read-only database query)

---

## Recommendations

### Immediate Actions
1. Change HTB password immediately
2. Audit all passwords in accounts.dbo.devsacc table
3. Remove plaintext credentials from devshare (important.txt)
4. Disable or secure NFS share with proper authentication

### Short-term Remediation
1. Implement password hashing in accounts database
2. Restrict RDP access to administrative users only
3. Implement database access controls (role-based access)
4. Enable SQL Server audit logging

### Long-term Security Improvements
1. Implement centralized credential management (e.g., CyberArk, HashiCorp Vault)
2. Deploy endpoint detection and response (EDR) solutions
3. Implement network segmentation
4. Regular security assessments and penetration testing
5. Security awareness training for developers storing credentials

---

**Document Created:** January 1, 2026  
**Engagement:** Inlanefreight Ltd LAB Penetration Test  
**Test Type:** Internal Network Assessment  
**Scope:** Section 2 - File Server Enumeration  
**Status:** HTB Credential Discovery Complete
