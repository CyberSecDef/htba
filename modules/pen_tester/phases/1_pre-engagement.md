# Pre-Engagement Phase Summary

Pre-engagement is the preparation stage for a penetration test (pentest), involving client education, scoping, and contractual agreements. It ensures clarity on objectives, scope, and rules to avoid legal issues (e.g., breaching Computer Misuse Act). The process includes: Scoping Questionnaire, Pre-Engagement Meeting, and Kick-Off Meeting. Start with a Non-Disclosure Agreement (NDA).

## Non-Disclosure Agreement (NDA)

Signed after initial contact. Types:

- **Unilateral**: One party keeps info confidential.
- **Bilateral**: Both parties maintain confidentiality (most common).
- **Multilateral**: More than two parties (e.g., for cooperatives).

Verify authorization: Only specific roles can contract pentesters (e.g., CEO, CTO, CISO, CIO, VP of IT). Confirm signatory authority and points of contact early.

## Documents to Prepare

Create and sign before testing:

1. **NDA** (After Initial Contact)
2. **Scoping Questionnaire** (Before Pre-Engagement Meeting)
3. **Scoping Document** (During Pre-Engagement Meeting)
4. **Penetration Testing Proposal (Contract/SoW)** (During Pre-Engagement Meeting)
5. **Rules of Engagement (RoE)** (Before Kick-Off Meeting)
6. **Contractors Agreement** (For Physical Assessments, Before Kick-Off Meeting)
7. **Reports** (During/After Test)

**Note**: Review by lawyer. Client may provide scoping info; append to RoE.

## Scoping Questionnaire

Sent after initial contact to clarify services. Includes assessment types (check all applicable):

- ☐ Internal/External Vulnerability Assessment
- ☐ Internal/External Penetration Test
- ☐ Wireless Security Assessment
- ☐ Application Security Assessment (Web/Mobile)
- ☐ Physical Security Assessment
- ☐ Social Engineering Assessment (Phishing/Vishing)
- ☐ Red Team Assessment
- ☐ Web Application Security Assessment
- ☐ Secure Code Review
- ☐ Active Directory Security Assessment

Additional details:

- Expected hosts/IPs/domains/SSIDs/apps/roles/users/locations.
- Objectives (e.g., for Red Team).
- Testing from anonymous/domain user; bypass NAC?
- Disclosure level: Black Box (no info), Grey Box (IPs/URLs), White Box (full details).
- Evasiveness: Non-evasive, Hybrid (start quiet, escalate), Fully Evasive.

Use this to create Scoping Document, estimate timeline/cost (e.g., Vulnerability Assessment < Red Team).

## Pre-Engagement Meeting

Discuss components via email/conference/in-person. Educate first-time clients. Inputs for Contract/SoW.

### Contract Checklist

- ☐ **NDA**: Confidentiality, penalties.
- ☐ **Goals**: Milestones (high-level to detailed).
- ☐ **Scope**: Domains, IPs, hosts, accounts, systems. Prioritize legal basis.
- ☐ **Penetration Testing Type**: Recommend based on goals (e.g., Black/Grey/White Box).
- ☐ **Methodologies**: OSSTMM, OWASP, PTES; automated/manual analysis.
- ☐ **Locations**: External (remote/VPN), Internal (on-site/remote).
- ☐ **Time Estimation**: Start/end dates; phases (e.g., Exploitation outside hours).
- ☐ **Third Parties**: Obtain written consent from providers (e.g., AWS); verify.
- ☐ **Evasive Testing**: Techniques to bypass security (client approval).
- ☐ **Risks**: Inform on potential impacts; set limitations.
- ☐ **Scope Limitations & Restrictions**: Avoid critical systems.
- ☐ **Information Handling**: Compliance (HIPAA, PCI, etc.).
- ☐ **Contact Information**: Names, titles, emails, phones; escalation order.
- ☐ **Lines of Communication**: Email, calls, meetings.
- ☐ **Reporting**: Structure, requirements, presentation.
- ☐ **Payment Terms**: Prices, schedules.

Prioritize client wishes; adapt to unique infrastructure.

## Rules of Engagement (RoE) Checklist

Based on contract:

- ☐ **Introduction**: Document purpose.
- ☐ **Contractor/Pentesters**: Names, titles.
- ☐ **Contact Information**: Addresses, emails, phones.
- ☐ **Purpose/Goals**: Test objectives.
- ☐ **Scope**: IPs, domains, URLs, ranges.
- ☐ **Lines of Communication**: Channels.
- ☐ **Time Estimation**: Dates, testing hours.
- ☐ **Type/Locations/Methodologies**: Details.
- ☐ **Objectives/Flags**: Targets (e.g., files, users).
- ☐ **Evidence Handling**: Encryption, protocols.
- ☐ **System Backups/Information Handling**: Secure data.
- ☐ **Incident Handling/Reporting**: Cases for pauses, reports.
- ☐ **Status Meetings**: Frequency, attendees.
- ☐ **Reporting/Retesting**: Types, dates.
- ☐ **Disclaimers/Limitations**: Liability for damage/loss.
- ☐ **Permission to Test**: Signed docs.

## Kick-Off Meeting

Scheduled in-person/post-signing. Attendees: Client POCs (Audit, IT, Security), technical staff, pentest team. Cover:

- Pentest nature (no DoS unless specified).
- Pause for critical vulns (e.g., RCE); notify emergency contacts.
- Risks: Logs, alarms, account locks; immediate contact if issues.
- Explain process to all (technical/non-technical).
- Clarify expectations; adapt to client experience.

## Contractors Agreement (for Physical Assessments)

Required for physical/social engineering. Acts as legal protection if caught. Checklist:

- ☐ **Introduction/Contractor/Purpose/Goal/Pentesters/Contact Information**.
- ☐ **Physical Addresses/Buildings/Floors/Rooms/Components**.
- ☐ **Timeline/Notarization/Permission to Test**.

## Setting Up

Post-agreements: Plan approach, prepare VMs/VPS/tools. See Setting Up module for details.

**Additional Info/Tools**: Use templates from OWASP (e.g., RoE template) or custom docs in Google Docs/Microsoft Word. For NDAs, consider legal tools like Rocket Lawyer. Track with project management software (e.g., Jira). Always confirm third-party permissions to avoid legal risks. If urgent, skip to Kick-Off but ensure NDA.
