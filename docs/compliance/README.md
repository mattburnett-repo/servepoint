# Privacy and compliance posture (ServePoint)

**Reader in a hurry:** ServePoint is a **demo**; these pages are **honest disclosure**, not a claim of regulatory compliance. They summarize what data the app can hold, how a few technical controls relate (encryption, access, audit logs), and high-level GDPR / HIPAA / CCPA **topics**—plus what still belongs to **operators** (contracts like DPAs/BAAs, policies, real privacy-request processes). **Do not** put real PHI or unnecessary real PII in demo environments. Skim **Contents** below, then open the page that fits your question.

This folder describes a **demo-grade** engineering and documentation posture for ServePoint. It is **not** legal advice, **not** a certification, and **not** a guarantee that any deployment meets GDPR, HIPAA, CCPA/CPRA, or other laws. Operators of real systems need appropriate contracts (for example **DPAs**, **BAAs**), organizational policies, risk analysis, and jurisdiction-specific guidance.

## Demo vs production

| | This repository (demo) | Production use |
|---|------------------------|------------------|
| **Claim** | Transparency: what the app stores, what features relate to security/privacy, and honest gaps. | You must map obligations to **your** role, data, and jurisdiction. |
| **Evidence** | Code, migrations, env docs, these pages. | Signed agreements, audits, monitoring, incident response, training. |
| **PHI / sensitive PII** | **Do not** use real protected health information or unnecessary real personal data in demo environments. | Follow organizational policies; restrict access; minimize collection. |

## Contents

| Document | Purpose |
|----------|---------|
| [data-inventory.md](data-inventory.md) | Categories of data, main tables/fields, sensitivity notes. |
| [gdpr.md](gdpr.md) | High-level GDPR topics and what operators must do beyond this codebase. |
| [hipaa.md](hipaa.md) | HIPAA scope (who it applies to), safeguard mapping, gaps. |
| [ccpa.md](ccpa.md) | CCPA/CPRA-style rights in principle and demo limitations. |

## What this codebase touches (summary)

- **TLS / encryption:** See in-app **Data encryption** summary (`main.encryption`) and `docs/DEV_NOTES.md` for env (HTTPS at the edge, DB TLS options, document encryption at rest for uploads).
- **Access control:** Role-based access in the application model (`users.role`, handler/service checks).
- **Audit logging:** Structured `audit_events` and reporting (`reports.index`) — demo scope; not certified compliance reporting.

For deployment and where data may reside (hosting/subprocessors narrative), see `docs/RENDER_DATABASE.md`, `docs/DEV_NOTES.md`, and `docs/DESIGN_NOTES.md` (Deployment, User Privacy & Security).

## Official guidance (references)

Use regulator and official sources for requirements; this repo only maps features at a high level.

- **GDPR:** [EU GDPR text and summaries](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32016R0679) — your DPO or counsel interprets applicability.
- **HIPAA:** [HHS HIPAA](https://www.hhs.gov/hipaa/index.html) — applies to covered entities and business associates handling PHI, not automatically to every application.
- **CCPA/CPRA:** [California OAG — CCPA](https://oag.ca.gov/privacy/ccpa) — applies to qualifying businesses and California consumers as defined in law.
