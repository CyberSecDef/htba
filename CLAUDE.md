# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains penetration testing notes, case studies, and lab work from the HackTheBox Academy (HTBA) penetration testing course. It is organized into two main areas:

- **modules/**: Course module notes organized by topic (theory and methodology)
- **cases/**: Hands-on penetration testing lab work and case studies (practical application)

## Repository Structure

```
├── modules/              # Course module notes
│   ├── getting_started/  # Basic tools and foundational concepts
│   ├── nmap/            # Network scanning and enumeration
│   ├── footprinting/    # Infrastructure and host-based enumeration
│   │   ├── infrastructure/  # Domain info, cloud resources, staff recon
│   │   └── host-based/      # Service-specific enumeration (FTP, SMB, DNS, etc.)
│   ├── pen_tester/      # Professional penetration testing methodology
│   │   ├── background_prep/ # Laws, regulations, overview
│   │   └── phases/          # 8 phases of pentest process
│   └── info_gathering_web/  # Web reconnaissance techniques
│
├── cases/               # Practical lab work and case studies
│   ├── nibbles/         # Easy Linux box (web exploitation, privesc)
│   ├── footprinting/    # Service enumeration exercises
│   │   ├── ftp/, smb/, dns/, nfs/, smtp/, imap_pop3/
│   │   ├── mysql/, mssql/, oracle/, snmp/, ipmi/
│   │   └── lab/         # Comprehensive multi-service lab
│   └── info_gathering_web/  # Web reconnaissance exercises
│
├── media/               # Screenshots, diagrams, media files
└── .mcp-kali/          # MCP server configuration (Kali Linux integration)
```

## Document Organization Patterns

### Module Structure
Module notes follow a consistent pattern:
- Core concept files (e.g., `intro.md`, `methodology.md`, `principles.md`)
- Technical implementation files (e.g., `host_discovery.md`, `enumeration.md`)
- `cheatsheet.md` - Quick reference commands for the module
- `README.md` - Module overview and navigation

### Case Study Structure
Each case typically includes:
- `tasks.md` - Lab questions and objectives
- `*_pentest_report.md` - Findings and methodology writeup
- `logs/` - Command outputs, enumeration results, walkthroughs
- `scans/` - Nmap scans and other tool outputs
- `screenshots/` - Visual evidence and proof

The footprinting lab (`cases/footprinting/lab/`) is the most comprehensive, containing:
- Multi-server scenario (DNS, internal server, MX/management)
- Walkthroughs documenting discovery processes
- Flag capturing and credential extraction exercises

## Penetration Testing Methodology

This repository follows the 8-phase penetration testing process documented in `modules/pen_tester/phases/`:

1. **Pre-Engagement** - Scoping, contracts, NDA, Rules of Engagement
2. **Information Gathering** - OSINT, infrastructure enumeration
3. **Vulnerability Assessment** - Identifying weaknesses
4. **Exploitation** - Gaining initial access
5. **Post-Exploitation** - Privilege escalation, data gathering
6. **Lateral Movement** - Moving through the network
7. **Proof of Concept** - Demonstrating impact
8. **Post-Engagement** - Reporting, cleanup, remediation guidance

## Key Concepts

### Enumeration Philosophy
The repository emphasizes thorough enumeration before exploitation:
- Infrastructure enumeration (DNS, domains, cloud resources, staff)
- Host-based service enumeration (FTP, SMB, NFS, DNS, SMTP, databases)
- Web enumeration (WHOIS, DNS, subdomains, fingerprinting, virtual hosts)

### Service Coverage
Host-based services covered extensively:
- File services: FTP, SMB, NFS
- Email: SMTP, IMAP, POP3
- Databases: MySQL, MSSQL, Oracle
- Infrastructure: DNS, SNMP, IPMI
- Remote management: SSH, RDP, WinRM (in footprinting module)

### Documentation Standards
Based on existing case work, documentation includes:
- Clear task/question tracking
- Command outputs preserved in `logs/`
- Walkthrough files showing discovery process
- Pentest reports with findings and methodology

## Important File Locations

- **Cheatsheets**: Quick command references in `modules/*/cheatsheet.md`
- **Glossary**: Common terms and acronyms in `GLOSSARY.md`
- **Report Template**: Base template in `media/pentest_report_template.md`

## Working with Cases

When working on lab exercises or case studies:

1. Check `tasks.md` for objectives and questions
2. Document enumeration in `logs/` directory
3. Save tool outputs to `scans/` directory
4. Create walkthroughs showing the discovery process (see `cases/footprinting/lab/logs/*_walkthrough.md`)
5. Write findings to `*_pentest_report.md`

## Notes on Content

This is a learning repository containing:
- Personal notes from educational security training
- Lab exercises from HackTheBox Academy
- No actual production systems or sensitive data
- IP addresses are placeholders (X.X.X.X) or lab environment addresses (10.x.x.x)
- Credentials mentioned are for lab environments only

The `.mcp-kali/` directory contains MCP (Model Context Protocol) server integration for Kali Linux tooling.
