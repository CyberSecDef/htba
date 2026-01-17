# Pre-Engagement Phase

## Overview

Pre-engagement is the **foundation of every penetration test**. This phase covers all preparation activities before any technical testing begins: client education, scoping, and contractual agreements. A poorly executed pre-engagement leads to scope creep, legal exposure, and failed assessments.

**Why It Matters:**
- Establishes legal authorization to test (without this, you're committing a crime)
- Defines clear boundaries to protect both tester and client
- Sets expectations for deliverables, timeline, and communication
- Identifies technical requirements and constraints upfront

**Key Outcome:** Signed agreements that clearly define what you can test, how you can test it, and what happens with the results.

---

## Key Terms

| Term | Definition |
|------|------------|
| **NDA** | Non-Disclosure Agreement - Legal contract ensuring confidentiality |
| **SoW** | Statement of Work - Detailed description of work to be performed |
| **RoE** | Rules of Engagement - Operational guidelines for the test |
| **OSSTMM** | Open Source Security Testing Methodology Manual |
| **OWASP** | Open Web Application Security Project |
| **PTES** | Penetration Testing Execution Standard |
| **NAC** | Network Access Control - Technology restricting network access |
| **POC** | Point of Contact - Designated person for communication |

---

## Pre-Engagement Workflow

The pre-engagement phase follows this sequence:

```
1. Initial Contact
       ↓
2. NDA Signing
       ↓
3. Scoping Questionnaire (Client completes)
       ↓
4. Pre-Engagement Meeting
       ↓
5. Contract/SoW Creation
       ↓
6. Rules of Engagement (RoE)
       ↓
7. Kick-Off Meeting
       ↓
8. Testing Begins
```

---

## Step 1: Initial Contact & NDA

### Non-Disclosure Agreement (NDA)

The NDA is signed **immediately after initial contact**, before any sensitive information is exchanged. This protects both parties.

**NDA Types:**

| Type | Description | Use Case |
|------|-------------|----------|
| **Unilateral** | One party keeps information confidential | Client shares info with tester only |
| **Bilateral** | Both parties maintain confidentiality | Most common - mutual protection |
| **Multilateral** | Three or more parties involved | Joint ventures, cooperative assessments |

### Verify Authorization

**Critical:** Only specific roles within an organization have the authority to contract penetration testers. Testing without proper authorization is illegal.

**Authorized Signatories (typically):**
- CEO (Chief Executive Officer)
- CTO (Chief Technology Officer)
- CISO (Chief Information Security Officer)
- CIO (Chief Information Officer)
- VP of Internal Audit
- VP of Information Technology

**Action Items:**
1. Confirm the person contacting you has signatory authority
2. Document the authorization chain
3. Identify all points of contact early

---

## Step 2: Scoping Questionnaire

Sent to the client after NDA signing. This questionnaire gathers the information needed to scope the engagement accurately.

### Assessment Types

| Assessment Type | Description | Typical Duration |
|-----------------|-------------|------------------|
| **External Vulnerability Assessment** | Automated scanning of internet-facing assets | Days |
| **Internal Vulnerability Assessment** | Automated scanning of internal network | Days |
| **External Penetration Test** | Manual exploitation of external assets | 1-2 weeks |
| **Internal Penetration Test** | Manual exploitation from inside the network | 1-2 weeks |
| **Web Application Assessment** | Testing web apps for OWASP Top 10 and beyond | 1-2 weeks per app |
| **Mobile Application Assessment** | Testing iOS/Android apps and their backends | 1-2 weeks per app |
| **Wireless Security Assessment** | Testing WiFi networks, rogue APs, segmentation | Days to 1 week |
| **Social Engineering** | Phishing, vishing, physical pretexting | 1-2 weeks |
| **Physical Security Assessment** | Testing physical access controls, badges, locks | Days to 1 week |
| **Red Team Assessment** | Full-scope adversary simulation with objectives | 2-6 weeks |
| **Active Directory Assessment** | Focused testing of AD security configurations | 1-2 weeks |
| **Secure Code Review** | Manual/automated source code analysis | Varies by codebase |

### Information Gathering

The questionnaire should collect:

**Scope Details:**
- Number of hosts/IP addresses/ranges
- Domain names and subdomains
- Wireless SSIDs
- Web/mobile applications (URLs, platforms)
- User accounts to test with
- Physical locations (for on-site work)

**Test Parameters:**
- Testing perspective (anonymous user, authenticated user, domain user)
- Network Access Control (NAC) bypass requirements
- Time windows and blackout periods
- Critical systems to avoid

### Disclosure Levels

| Level | Also Called | Information Provided | Realism | Efficiency |
|-------|-------------|---------------------|---------|------------|
| **Black Box** | Zero Knowledge | None - tester starts blind | High | Low |
| **Grey Box** | Partial Knowledge | IP ranges, URLs, limited docs | Medium | Medium |
| **White Box** | Full Knowledge | Architecture, source code, credentials | Low | High |

**Recommendation:** Grey box provides the best balance for most engagements. Black box wastes time on reconnaissance the client could provide. White box is ideal for code review or architecture assessment.

### Evasiveness Levels

| Level | Description | Use Case |
|-------|-------------|----------|
| **Non-Evasive** | No attempt to avoid detection | Vulnerability assessments, compliance tests |
| **Hybrid** | Start quietly, escalate if undetected | Standard pentests |
| **Fully Evasive** | Active evasion throughout | Red team engagements |

---

## Step 3: Pre-Engagement Meeting

Conducted via email, video conference, or in-person. Purpose: finalize scope, educate the client, and gather remaining details for the contract.

**For First-Time Clients:**
- Explain what penetration testing is (and isn't)
- Set realistic expectations about findings
- Clarify that testing may cause disruptions
- Explain the difference between vulnerability scanning and penetration testing

### Contract/SoW Checklist

Use this checklist during the pre-engagement meeting:

#### Administrative
- [ ] **NDA signed** - Confidentiality terms and penalties defined
- [ ] **Goals defined** - High-level objectives and specific milestones
- [ ] **Payment terms** - Pricing, schedule, invoicing process

#### Scope Definition
- [ ] **In-scope assets** - Specific domains, IPs, hosts, applications
- [ ] **Out-of-scope assets** - Systems to avoid (production databases, etc.)
- [ ] **User accounts** - Accounts provided for authenticated testing
- [ ] **Third-party systems** - Cloud providers, SaaS, managed services

#### Technical Parameters
- [ ] **Test type** - Black/Grey/White box
- [ ] **Methodologies** - OSSTMM, OWASP, PTES, custom
- [ ] **Testing location** - Remote, on-site, VPN access
- [ ] **Evasiveness** - Detection avoidance requirements
- [ ] **Automated vs. manual** - Tool usage and manual verification

#### Timing
- [ ] **Start and end dates** - Firm or flexible
- [ ] **Testing hours** - Business hours, after hours, weekends
- [ ] **Blackout periods** - Times when testing is prohibited
- [ ] **Phase scheduling** - When exploitation vs. reporting occurs

#### Risk Management
- [ ] **Potential impacts** - Service disruption, data exposure
- [ ] **Limitations** - Techniques that are off-limits (DoS, data destruction)
- [ ] **Critical system handling** - Extra caution requirements

#### Third-Party Authorization
- [ ] **Cloud providers notified** - AWS, Azure, GCP require notification
- [ ] **Managed service providers** - Written consent obtained
- [ ] **Verification** - Confirmation emails/documents saved

#### Communication
- [ ] **Points of contact** - Names, titles, emails, phone numbers
- [ ] **Escalation path** - Who to call for emergencies
- [ ] **Communication channels** - Encrypted email, Signal, phone
- [ ] **Status meeting schedule** - Frequency and attendees

#### Compliance
- [ ] **Data handling** - How sensitive data is handled during testing
- [ ] **Regulatory requirements** - HIPAA, PCI-DSS, SOC 2, GDPR
- [ ] **Evidence retention** - How long findings are kept

#### Deliverables
- [ ] **Report format** - Structure, detail level, audience
- [ ] **Presentation** - Executive briefing, technical walkthrough
- [ ] **Retesting** - Included or separate engagement

---

## Step 4: Rules of Engagement (RoE)

The RoE is the **operational playbook** for the engagement. It translates the contract into actionable guidelines for the testing team.

### RoE Checklist

#### Header Information
- [ ] **Document title and version**
- [ ] **Introduction** - Purpose of this document
- [ ] **Contractor information** - Company name, address
- [ ] **Tester names and roles** - Who is performing the test

#### Contact Information
- [ ] **Client contacts** - Primary, secondary, emergency
- [ ] **Tester contacts** - Lead tester, backup
- [ ] **Contact methods** - Phone, email, encrypted channels

#### Engagement Parameters
- [ ] **Purpose and goals** - What success looks like
- [ ] **Scope** - Complete list of in-scope assets (IPs, domains, URLs, ranges)
- [ ] **Out of scope** - Explicitly excluded assets
- [ ] **Test type and location** - Remote/on-site, black/grey/white box
- [ ] **Methodologies** - Standards being followed
- [ ] **Timeline** - Start date, end date, testing windows

#### Objectives (if applicable)
- [ ] **Flags/targets** - Specific files, systems, or data to obtain
- [ ] **Success criteria** - How objective completion is measured

#### Operational Procedures
- [ ] **Evidence handling** - Encryption requirements, transfer methods
- [ ] **Data handling** - What happens to sensitive data found
- [ ] **System backups** - Client responsibility before testing
- [ ] **Tool usage** - Approved/prohibited tools

#### Incident Handling
- [ ] **Critical finding protocol** - What triggers immediate notification
- [ ] **Pause conditions** - When to stop testing
- [ ] **Resume procedures** - How to restart after a pause
- [ ] **Emergency contacts** - 24/7 availability requirements

#### Reporting
- [ ] **Status updates** - Frequency and format
- [ ] **Draft report** - Delivery timeline
- [ ] **Final report** - Delivery timeline
- [ ] **Retesting** - Timeline and scope

#### Legal
- [ ] **Disclaimers** - Liability limitations
- [ ] **Permission to test** - Explicit signed authorization
- [ ] **Indemnification** - Protection from third-party claims

---

## Step 5: Kick-Off Meeting

Conducted in-person or via video after all documents are signed. This is the final checkpoint before testing begins.

### Attendees

**Client Side:**
- Points of contact
- IT/Security staff
- Audit representatives
- Management (optional)

**Tester Side:**
- Lead tester
- Testing team members
- Project manager (if applicable)

### Agenda

1. **Introductions** - Establish who's who
2. **Scope review** - Confirm everyone understands what's being tested
3. **Timeline review** - Confirm dates and testing windows
4. **Communication protocols** - How and when to communicate
5. **Incident procedures** - What happens if something breaks
6. **Q&A** - Address any remaining concerns

### Key Points to Cover

**Set Expectations:**
- Penetration testing is NOT denial of service (unless explicitly scoped)
- Testing may trigger alerts, lock accounts, or generate logs
- Findings are a starting point for improvement, not an indictment

**Critical Vulnerability Protocol:**
- Testing will pause for critical findings (e.g., active breach, RCE with sensitive data exposure)
- Emergency contacts will be notified immediately
- Client decides whether to continue or remediate first

**Technical Coordination:**
- Confirm tester IP addresses for whitelist/monitoring
- Verify VPN access or on-site arrangements
- Confirm account credentials work

---

## Step 6: Contractors Agreement (Physical Assessments)

Required for physical penetration testing and social engineering engagements. This document serves as a **"get out of jail free" card** if testers are detained by security or law enforcement.

### Contractors Agreement Checklist

#### Identification
- [ ] **Contractor company information**
- [ ] **Tester names with photos**
- [ ] **Tester contact information**

#### Authorization
- [ ] **Purpose and goals** - Why testers are on premises
- [ ] **Authorizing party** - Name and title of person who approved
- [ ] **Authorization signature** - Signed permission

#### Scope
- [ ] **Physical addresses** - Exact locations
- [ ] **Buildings and floors** - Specific areas authorized
- [ ] **Rooms and areas** - Server rooms, executive offices, etc.
- [ ] **Components** - Locks, badges, doors, safes

#### Timing
- [ ] **Valid dates** - When the agreement is active
- [ ] **Valid hours** - Time windows for testing

#### Legal
- [ ] **Notarization** - If required by jurisdiction
- [ ] **Emergency contacts** - Who to call to verify authorization

**Tip:** Testers should carry this document at all times during physical assessments. Consider laminated cards with QR codes linking to verification.

---

## Post-Agreement Setup

After all documents are signed, prepare for the engagement:

1. **Infrastructure** - Set up VMs, VPS, testing tools
2. **Access** - Verify VPN, credentials, network connectivity
3. **Documentation** - Prepare note-taking templates, evidence folders
4. **Communication** - Establish encrypted channels with client
5. **Schedule** - Block calendar, notify team

See the **Setting Up** module for detailed technical preparation.

---

## Common Mistakes to Avoid

| Mistake | Consequence | Prevention |
|---------|-------------|------------|
| Testing without signed authorization | Criminal liability | Never start without signed RoE |
| Unclear scope boundaries | Scope creep, legal issues | Document every asset explicitly |
| No emergency contacts | Unable to report critical findings | Require 24/7 contact before testing |
| Skipping third-party notification | AWS/Azure may block or report you | Always notify cloud providers |
| Verbal agreements only | No legal protection | Get everything in writing |
| Testing production without backups | Data loss liability | Confirm client has backups |
| Assuming authorization transfers | Legal exposure | Each subsidiary/provider needs authorization |

---

## Quick Reference: Document Timeline

| Document | When Created | When Signed |
|----------|--------------|-------------|
| NDA | After initial contact | Before sharing any details |
| Scoping Questionnaire | After NDA | Client completes before pre-engagement meeting |
| Scoping Document | During pre-engagement meeting | Internal document |
| Contract/SoW | After pre-engagement meeting | Before testing begins |
| Rules of Engagement | After contract | Before kick-off meeting |
| Contractors Agreement | Before physical testing | Before kick-off meeting |

---

## Resources

**Templates:**
- [OWASP Penetration Testing Contracts](https://owasp.org/www-community/controls/Penetration_Testing_Contracts)
- [PTES Pre-Engagement](http://www.pentest-standard.org/index.php/Pre-engagement)

**Legal Reference:**
- Computer Fraud and Abuse Act (CFAA) - United States
- Computer Misuse Act 1990 - United Kingdom
- Check local laws for your jurisdiction

**Tools:**
- Project management: Jira, Asana, Monday.com
- Secure document sharing: ShareFile, Tresorit
- Contract management: DocuSign, PandaDoc
