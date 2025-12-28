# Post-Engagement Phase Summary

Post-Engagement closes the pentest: Cleanup, report, review, retest, and finalize. Contractually binding; ensures accountability. Activities vary but generally required.

## Cleanup

Remove tools/scripts, revert config changes. Use detailed notes for efficiency. If unable, alert client and note in report appendices.

**Additional Commands**:

- `rm -rf /path/to/artifacts` (Delete files).
- `shred -u file` (Secure delete).
- Windows: `del /f /q file` or `cipher /w:C:\path` (Overwrite free space).

## Documentation and Reporting

Compile report before disconnecting. Include:

- Attack chain (for compromise).
- Executive summary (non-technical).
- Detailed findings: Risk rating, impact, remediation, references.
- Reproduction steps.
- Near/medium/long-term recommendations.
- Appendices: Scope, OSINT, cracking analysis, ports/services, compromised hosts/accounts, files transferred, modifications, AD analysis, scan data.

Deliver draft first; client reviews/comments.

**Additional Tools**: Dradis or Faraday for report management; Markdown/Pandoc for formatting.

## Report Review Meeting

Walk through findings with client/technical experts. Explain perspectives; answer questions. Client may focus on high-risk items.

## Deliverable Acceptance

SoW defines process: Draft → feedback → Final. Some require no "DRAFT" marking.

## Post-Remediation Testing

Retest fixes (often included in cost). Review client remediation evidence. Issue report with before/after status (e.g., table of findings).

**Additional Tools**: Nessus/OpenVAS for re-scans.

## Role of the Pentester in Remediation

Remain impartial: Advise generally (e.g., "sanitize input" for SQLi), not implement. Maintain independence.

## Data Retention

Store data securely (encrypted) per contract/laws (e.g., PCI DSS recommends retention for evidence availability). Wipe tester systems post-assessment. Use client-specific VMs for follow-ups.

**Additional**: Encrypt with VeraCrypt; follow GDPR/PCI for PII.

## Close Out

Deliver final report; wipe/destroy systems; invoice. Send satisfaction survey for feedback/improvements. Potential for follow-on work.

**General Tips**: Self-reflect on soft skills/communication. For HTB, practice reporting on boxes. Always document thoroughly. If questions arise, retain data briefly. Focus on client value beyond technical exploits.
