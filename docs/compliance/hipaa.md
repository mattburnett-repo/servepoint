# HIPAA (high-level; not legal advice)

**HIPAA** rules apply to **covered entities** (for example certain health plans and providers) and, where applicable, **business associates** handling **PHI** on their behalf—not to every web application by default. Whether your deployment is in scope is a **legal and contractual** determination.

## Administrative, physical, and technical safeguards (mapping)

HIPAA Security Rule expectations are often grouped into **administrative**, **physical**, and **technical** safeguards. This repository is **software**; it can support **some** technical measures **if** the surrounding environment implements them.

| Area | What this codebase can help with (when configured) | What is organizational / environmental |
|------|---------------------------------------------------|----------------------------------------|
| **Access control** | Application-level **roles** (`users.role`) and handler/service checks | Account provisioning, offboarding, least-privilege policy, **unique user IDs**, emergency access procedures |
| **Audit controls** | `audit_events` table and reporting surface | Log review procedures, retention, alerting, SIEM—not “certified” by this demo |
| **Integrity** | ORM-layer validation, controlled document pipeline | Change management, integrity monitoring beyond the app |
| **Transmission security** | **HTTPS** at reverse proxy / platform; **DB TLS** via JDBC/`DB_SSL_MODE` (see `.cfconfig.json` / env docs) | Network architecture, VPNs, HSTS, certificate management |
| **Encryption** | **AES-256-GCM** for uploaded document files at rest (key via env) | Full-disk encryption, DB-at-rest encryption, key management (HSM/KMS), **key rotation** policy |

## Administrative examples (not implemented as app features)

- **Security management process**, **risk analysis**, **sanction policy**, **workforce training**
- **Contingency plan**, **business associate agreements**, **incident** and **breach** procedures

## Gap honesty

ServePoint is a **demo**. It does **not** replace a HIPAA compliance program, **BAA**, **risk analysis**, or **HIPAA Security Rule** implementation checklist for production PHI. Do **not** use real PHI in demo environments.

See [data-inventory.md](data-inventory.md) and [README.md](README.md).
