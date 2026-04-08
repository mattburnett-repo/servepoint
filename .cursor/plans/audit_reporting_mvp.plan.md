---
name: Audit Reporting MVP
overview: "Implement issue #35 with a minimal reporting entry point and stronger service-level audit detail, while keeping schema unchanged unless Phase 2 log-type granularity requires a constant update only."
todos:
  - id: add-reporting-mvp
    content: Implement minimal report service/handler/view and route entry
    status: completed
  - id: wire-home-link
    content: Make home Core Feature audit/reporting link actionable
    status: completed
  - id: phase1-audit-detail
    content: Enrich service-level log entryText for case/document/communication events
    status: completed
  - id: phase2-log-types
    content: Add and apply specific Log_Entry_Type values for granular events
    status: completed
  - id: service-owns-download-audit
    content: Move document download logging responsibility into DocumentService
    status: completed
  - id: update-tests
    content: Update/add integration specs for reports and audit detail/type assertions
    status: completed
  - id: sync-mermaid-docs
    content: Update design/mermaid docs for reporting and audit behavior changes
    status: completed
isProject: false
---

# Audit Trails and Reporting Plan

## Goal
Deliver the agreed MVP for issue #35 by using persisted `LogEntry` records as the in-app audit source, adding one lightweight aggregate report, and improving event detail at the service layer with test coverage.

## Implementation Principle (existing code first)
- Use existing repo code as the guide for all behavior, naming, and structure.
- Match current ColdBox/WireBox/TestBox patterns before introducing anything new.
- Prefer extending current services/handlers/views over creating new abstractions.
- Keep changes minimal and local to the agreed scope.
- Reuse established conventions for:
  - active vs archived case handling (`CaseService.listActive()`, `CaseService.getActiveCase()`),
  - audit writes (`LogEntryService.record()`),
  - view rendering and redirects in handlers,
  - integration test setup and rollback via `tests/specs/BaseIntegrationTestCase.cfc`.

## Confirmed Scope
- Keep database schema unchanged (no migrations planned).
- Use existing case-level audit trail UI as baseline (already present in case detail).
- Add reporting entry point and one aggregate report.
- Implement both detail phases:
  - Phase 1: richer `entryText` for existing events.
  - Phase 2: more specific log types via constants (no table changes).
- Update tests to remain accurate and passing.
- Keep `design/mermaid/` docs in sync with behavior changes.

## Implementation Steps
1. Add reporting read path (service + handler + view), following existing conventions
- Create a focused reporting service method for one aggregate report (recommended: log-entry counts by type with optional date range and clear default behavior), mirroring current service query style.
- Add a `Reports` handler action to parse filters and populate `prc`, matching existing handler patterns used in `Cases`, `Documents`, and `Communications`.
- Add a server-rendered report view with accessible filter controls and labeled output.
- File targets:
  - [services](services)
  - [handlers](handlers)
  - [views](views)

2. Wire homepage feature navigation using existing Main handler pattern
- Make “Audit trails and reporting” actionable from home page by linking to the new report entry point.
- File targets:
  - [handlers/Main.cfc](handlers/Main.cfc)
  - [views/main/index.cfm](views/main/index.cfm) (if needed for label/UX consistency)

3. Phase 1 audit detail improvements at service layer (no new architecture)
- Expand `entryText` for existing service events so logs contain actionable context (case identifiers/titles, status transitions where available, communication/document descriptors), while keeping current service ownership of those events.
- Keep current `type` values valid and stable during this phase.
- File targets:
  - [services/CaseService.cfc](services/CaseService.cfc)
  - [services/CommunicationService.cfc](services/CommunicationService.cfc)
  - [services/DocumentService.cfc](services/DocumentService.cfc)

4. Phase 2 event-type granularity, aligned with existing constants model
- Extend [models/constants/Log_Entry_Type.cfc](models/constants/Log_Entry_Type.cfc) with specific types needed by agreed events, using the same constants/getValues pattern already used across `models/constants`.
- Update service calls to use these explicit types.
- Ensure `LogEntry.validate()` remains aligned with allowed types.
- File targets:
  - [models/constants/Log_Entry_Type.cfc](models/constants/Log_Entry_Type.cfc)
  - [services/CaseService.cfc](services/CaseService.cfc)
  - [services/CommunicationService.cfc](services/CommunicationService.cfc)
  - [services/DocumentService.cfc](services/DocumentService.cfc)

5. Keep download audit behavior consistent with service-level ownership
- Move/centralize document-download audit logging so service layer is the canonical source for document audit events.
- Keep handler focused on request/response concerns.
- File targets:
  - [handlers/Documents.cfc](handlers/Documents.cfc)
  - [services/DocumentService.cfc](services/DocumentService.cfc)

6. Test coverage updates, based on existing integration spec style
- Add/update integration specs for:
  - report query results and filter behavior,
  - updated log message expectations,
  - new log type expectations,
  - primary report handler path.
- Maintain transaction rollback isolation via base integration test harness and follow current spec data-setup patterns (create only what each spec needs).
- File targets:
  - [tests/specs](tests/specs)

7. Documentation sync (required by project rule)
- Update mermaid docs to reflect new reporting flow and audit event semantics.
- Keep updates concise and contributor-oriented.
- File targets:
  - [design/mermaid/request-lifecycle.md](design/mermaid/request-lifecycle.md)
  - [design/mermaid/architecture.md](design/mermaid/architecture.md)
  - [design/mermaid/data-model.md](design/mermaid/data-model.md) (constants/behavior notes only unless schema truly changes)

## Delivery and Verification
- Run targeted integration tests for case/document/communication/logging/reporting paths.
- Confirm no persistent test residue (transaction rollback pattern remains in effect).
- Verify homepage link reaches report entry page and report output uses DB-driven values.
- Keep UI labels explicit that reporting is demo-scope, not certified compliance output.
- Verify changed code follows existing patterns before merge (service contracts, handler flow, view style, and constants usage).
