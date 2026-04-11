# Data inventory (demo scope)

This inventory describes **categories** of data the ServePoint demo may store. **Residency** (where bytes live) depends entirely on **where you deploy** (for example local Docker vs [Render](https://render.com/)); this repo does not pin a single jurisdiction.

## Categories

| Category | Purpose in the app | Typical sensitivity |
|----------|-------------------|---------------------|
| **User accounts** | Login, display name, role-based access | **PII** (names, email); **authentication secrets** (password hashes in `users.password`) |
| **Cases** | Case management workflow | May include **PII** in `title`, `description`; operational metadata (`status`, `creator_id`, assignment, archive fields) |
| **Documents** | File metadata and encrypted file blobs on disk | Content may be **highly sensitive**; treat as **confidential**; do not use real PHI in demo |
| **Communications** | Staff notes tied to cases | **PII** and operational content in `message` |
| **Audit events** | Security and operational audit stream | May include user/case/document references; `message` / `metadata_json` should follow logging discipline (avoid secrets) |

## Major tables (PostgreSQL)

Aligned with `resources/database/migrations` and `design/mermaid/data-model.md`.

| Table | Notes |
|-------|--------|
| `users` | `firstName`, `lastName`, `email`, `password` (hashed), `role` |
| `cases` | `title`, `description`, `status`, `creator_id`, `assigned_to_id`, archive columns |
| `documents` | `title`, `fileName`, `fileSize`, `fileType`, `case_id`, `date_uploaded` — files on disk under configured storage root |
| `communications` | `message`, `type`, `case_id`, `user_id`, `updated_by`, timestamps |
| `audit_events` | `category`, `event_type`, `outcome`, `reason_code`, `message`, `metadata_json`, optional FKs to user/case/document, `date_occurred` |

## PII and PHI

- **PII:** Assume names, emails, case text, communications, and document content can identify individuals depending on content.
- **PHI:** If a production deployment handled **protected health information** under HIPAA, that would require **organizational** HIPAA programs, **BAAs**, and technical controls beyond what this demo documents. **Do not** seed or upload real PHI for this demo repository.

## Retention and deletion

Document **retention** and disposition are **not** fully automated in routine UI flows; see `docs/DESIGN_NOTES.md` and `docs/DEV_NOTES.md`. Any **data subject** or **consumer** request workflow in production is an **operator process** (export, delete, restrict), not an in-app DSAR portal in this repo.
