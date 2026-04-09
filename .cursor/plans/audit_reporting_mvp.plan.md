---
name: Audit Events Table Migration
overview: Implement comprehensive audit logging with a dedicated audit events datastore (`audit_events` / `AuditEvent`), migrate case-level audit writes to `AuditLoggerService`, and document/test/seed the flow while keeping operational LogBox logging distinct.
todos:
  - id: design-audit-schema
    content: Define and implement new audit_events schema + ORM model + constants/taxonomy
    status: completed
  - id: build-audit-service
    content: Add centralized AuditLogger service and wire via WireBox
    status: completed
  - id: migrate-event-writers
    content: Replace legacy case-activity audit writes in services with AuditLogger calls
    status: completed
  - id: update-seeding
    content: Add idempotent seed data for audit_events
    status: completed
  - id: add-tests
    content: Add/update TestBox coverage for migration, service behavior, and key integration flows
    status: completed
  - id: docs-and-home-link
    content: Document strategy in docs/logging.md + docs/DEV_NOTES pointer and wire homepage audit link
    status: completed
  - id: sync-mermaid
    content: Update design/mermaid architecture, request lifecycle, and data model docs
    status: completed
isProject: false
---

# Audit Events Migration Plan

## Goal
Implement Issue #39 by introducing a dedicated persisted audit events store (`audit_events`), migrating case/domain audit writes into that pipeline, and establishing structured audit that is ready for upcoming auth work.

## Confirmed Decisions
- Use existing services/handlers for instrumentation; do not introduce interceptors in this MVP.
- Create a new audit event taxonomy (categories/actions/outcomes/reason codes).
- Add a new database table + ORM entity for audit events.
- Migrate case mutation audit writes to the new audit table only (no dual-write to a second activity store).
- Keep docs in both a new logging doc and a concise pointer in DEV notes.

## Implementation Steps

1. Add persisted audit datastore and model
- Create migration under [/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/resources/database/migrations/](/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/resources/database/migrations/) for `audit_events` (append-only).
- Include columns for auth-readiness and traceability: timestamp, request id, actor user id (nullable), category, action, outcome, optional case/document/resource identifiers, reason code, sanitized message, optional redacted JSON metadata.
- Add indexes for expected query paths (occurred time, category/action, actor, case).
- Add ORM entity in [/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/models/](/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/models/) mapped to the new table.

2. Define audit taxonomy/constants
- Add constants for audit categories/actions/outcomes/reason codes under [/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/models/constants/](/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/models/constants/).
- Keep taxonomy separate from staff messaging (`Communication_Type`, etc.) so audit semantics stay explicit.

3. Build centralized audit writer service
- Add `AuditLoggerService` in [/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/services/](/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/services/).
- Responsibilities:
  - validate normalized event payload,
  - apply redaction/truncation (no passwords/tokens/secrets, no sensitive bodies/paths),
  - persist to `audit_events`,
  - emit structured LogBox line by category for ops/SIEM-readiness.
- Register in [/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/config/WireBox.cfc](/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/config/WireBox.cfc).

4. Configure LogBox categories for structured audit emission
- Update [/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/config/LogBox.cfc](/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/config/LogBox.cfc) with `audit.security`, `audit.case`, `audit.document`, `audit.report`, `audit.admin` categories.
- Keep existing `app.*` lifecycle/error categories unchanged.

5. Migrate existing producers to the new audit table
- Completed: services now call `AuditLoggerService` where case/document/communication flows need persisted audit (see `CaseService`, `CommunicationService`, `DocumentService`, reporting as applicable).
- Preserve existing actor fallback behavior until auth is implemented.

6. Seeding updates
- Extend [/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/services/SeedService.cfc](/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/services/SeedService.cfc) with idempotent seed rows in `audit_events` for demo visibility.
- Keep seed data minimal and realistic; avoid sensitive payloads.

7. Test coverage
- Add/adjust integration specs in [/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/tests/specs/integration/](/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/tests/specs/integration/) to verify:
  - audit rows persisted for core case/document/communication flows,
  - redaction and truncation behavior,
  - new writes go only through `AuditLoggerService` / `audit_events`.

8. Documentation + home page linkage
- Add [/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/docs/logging.md](/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/docs/logging.md) with:
  - distinction between operational LogBox logs and persisted audit events,
  - taxonomy and field contract,
  - redaction rules and sample safe outputs,
  - note on future auth integration.
- Add concise pointer/update in [docs/DEV_NOTES.md](../../docs/DEV_NOTES.md).
- Update homepage audit line/link in [/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/views/main/index.cfm](/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/views/main/index.cfm).

9. Required design sync
- Update:
  - [/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/design/mermaid/architecture.md](/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/design/mermaid/architecture.md)
  - [/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/design/mermaid/request-lifecycle.md](/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/design/mermaid/request-lifecycle.md)
  - [/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/design/mermaid/data-model.md](/Volumes/projectDrive/projects/webDev/coldFusion/demo_apps/ServePoint/design/mermaid/data-model.md)
- Reflect `audit_events` as the persisted audit store and align diagrams with the ORM model.

## Validation Checklist
- Migration applies cleanly on fresh startup.
- Core service actions create expected `audit_events` rows.
- No secrets/full sensitive text in persisted audit payloads or LogBox structured outputs.
- Seed runs idempotently.
- Updated integration tests pass.
- Home page audit link points to documentation.

## Future Auth Fit (explicit)
- Current schema/service contract must support additive auth events (`login_success`, `login_failure`, `logout`, `authz_denied`) without redesign.
- Actor can remain nullable until auth session context is available, then become populated by auth workflow.
