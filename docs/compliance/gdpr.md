# GDPR (high-level; not legal advice)

The **General Data Protection Regulation** (EU/EEA) applies when processing personal data in scope of the regulation. Whether ServePoint or a specific deployment falls in scope is a **legal and factual** question for the **controller** and counsel—not something this repository decides.

## Typical themes (for product owners)

- **Lawful basis:** Controllers must identify a valid basis (for example contract, legal obligation, legitimate interests—each with conditions). ServePoint does not hard-code a lawful basis; operators document it for their use case.
- **Data minimization:** Store what you need for the case-management purpose; the design notes emphasize minimal collection.
- **Security of processing:** Technical and organizational measures—this codebase contributes **some** technical controls (access control, TLS options, encryption for uploaded files, audit events) if configured and operated correctly.

## Data subject rights (process checklist)

Regulations grant individuals rights such as access, rectification, erasure, restriction, portability, and objection in defined circumstances. **This demo does not provide** a self-service portal for all requests. A real deployment would typically:

1. **Identify** the data subject and scope of the request (with identity assurance appropriate to risk).
2. **Locate** data across DB tables, files, backups, and logs (may require DBA and ops runbooks).
3. **Respond** within statutory timelines, including exceptions where law allows refusal or extension.
4. **Document** decisions for accountability.

## What this repo does **not** provide

- Legal interpretation, DPO appointment, or **international transfer** mechanisms (for example SCCs) beyond noting they exist for cross-border scenarios.
- Automated **export** packaged as “Article 20 portability” without operator review.
- Erasure that ignores **legal holds** or **backup** realities—those are operational policies.

See [README.md](README.md) for the demo vs production disclaimer and links to deployment docs.
