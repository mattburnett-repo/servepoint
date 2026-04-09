# Logging and Audit Strategy

ServePoint uses two distinct mechanisms:

- **Operational logging (LogBox):** runtime diagnostics and observability (`app.*`, `audit.*` categories).
- **Persisted audit events (`audit_events`):** structured application audit history for reporting and traceability.

Application audit instrumentation writes to `audit_events` through `AuditLoggerService`.

## Audit event contract (`audit_events`)

Core fields:

- `date_occurred`: event timestamp (DB default).
- `category`: audit domain (`security`, `case`, `document`, `report`, `admin`).
- `event_type`: normalized event label (`Case Create`, `Document Download`, `Report View`, etc.).
- `outcome`: `success`, `failure`, or `denied`.
- `user_id`: actor user when known (nullable for pre-auth/system paths).
- `case_id`, `document_id`: optional resource references.
- `reason_code`: optional short classifier for failures/denials.
- `message`: sanitized summary.
- `metadata_json`: redacted/truncated metadata payload.

## Redaction and safety rules

`AuditLoggerService` applies central redaction/truncation:

- Secrets are never stored in clear text (`password`, `token`, `secret`, `authorization`, `cookie` keys/segments).
- Complex metadata values are collapsed to a placeholder.
- Oversized values are truncated.
- Message text is trimmed and constrained to safe length.

## Event taxonomy

Current event categories:

- `security`
- `case`
- `document`
- `report`
- `admin`

Current event type constants:

- `Login Success`
- `Login Failure`
- `Logout`
- `Authorization Denied`
- `Case Create`
- `Case Update`
- `Case Archive`
- `Case Restore`
- `Communication Create`
- `Document Upload`
- `Document Download`
- `Report View`
- `Admin Action`

## LogBox categories

Operational category channels:

- `audit.security`
- `audit.case`
- `audit.document`
- `audit.report`
- `audit.admin`

Lifecycle/error categories remain:

- `app.startup`
- `app.error`
- `app.shutdown`

## Future auth integration

The audit schema/service is auth-ready:

- `user_id` remains nullable until authenticated principal context is available everywhere.
- Auth flows can add `Login Success`, `Login Failure`, `Logout`, and `Authorization Denied` events without schema changes.
