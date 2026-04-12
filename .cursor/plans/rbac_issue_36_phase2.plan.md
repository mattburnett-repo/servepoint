---
name: ServePoint RBAC Issue 36 — Phase 2 (Authorization)
overview: "Milestone B: RBAC matrix, interceptor role gates, SecurityService role helpers, CaseService and related services for resource-level checks, replace admin@example.com, views, Core Feature RBAC link, authorization tests, full DEV_NOTES matrix. Prerequisite — Phase 1 plan implemented and accepted."
todos:
  - id: phase2-authz-matrix-enforce
    content: Matrix in DEV_NOTES; interceptor coarse role rules; CaseService + docs/reports resource checks; replace admin@example.com
    status: completed
  - id: phase2-authz-ui-nav-rbac-link
    content: Hide/disable by role; Core Feature RBAC href + help view; authorization integration tests
    status: completed
isProject: false
---

# Phase 2 — Authorization / RBAC (Milestone B)

**Prerequisite:** Complete and accept [`rbac_issue_36_phase1.plan.md`](rbac_issue_36_phase1.plan.md) (authentication) first.

**Parent:** [GitHub issue #36](https://github.com/mattburnett-repo/servepoint/issues/36).

## Reference

- [`models/constants/User_Role.cfc`](models/constants/User_Role.cfc), [`models/Users.cfc`](models/Users.cfc), [`services/SeedService.cfc`](services/SeedService.cfc).
- Handlers to refactor off `admin@example.com`: [`handlers/Cases.cfc`](handlers/Cases.cfc), [`handlers/Reports.cfc`](handlers/Reports.cfc), [`handlers/Documents.cfc`](handlers/Documents.cfc). [`handlers/Main.cfc`](handlers/Main.cfc): empty `href` for “Role-based access controls” — fill in this phase.

## Goal

Apply the **permission matrix** — **coarse** rules in the interceptor (extend Phase 1), **fine-grained** rules in services — and align handlers/views with server-side denial.

**Within Phase 2:** interceptor = role vs handler/action; services = resource-specific (e.g. assignment) next to [`CaseService`](services/CaseService.cfc) / document/report services.

## Implementation checklist

1. **Permission matrix** in [`docs/DEV_NOTES.md`](docs/DEV_NOTES.md): tag each rule **interceptor** vs **service**. Finalize MVP product rules, for example:
   - **Administrator:** full demo access including [`handlers/Reports.cfc`](handlers/Reports.cfc) and case flows.
   - **Case Manager:** mutate cases only when `assigned_to_id` matches (or per chosen rules); list/view scope explicit.
   - **Citizen:** at least one **denied** sensitive action per issue acceptance.
2. **Interceptor:** map events to **minimum roles**; consistent behavior for “authenticated but not allowed” (403 vs relocate + flash).
3. **Services:** [`CaseService`](services/CaseService.cfc) and document/upload/report flows — actor user id; `{ success: false, error: "..." }` when denied. Fix audit **`actorUserId`** in [`CaseService.updateCase`](services/CaseService.cfc) to use the **acting** user, not creator.
4. **Handlers:** replace `admin@example.com` with current user from `SecurityService`.
5. **Views:** hide/disable controls by permission; server remains authoritative.
6. **Core Feature:** “Role-based access controls” `href` in [`handlers/Main.cfc`](handlers/Main.cfc) → new `main` action + view (matrix summary, seed accounts, login link).

## Testing ([`tests/specs/integration/`](tests/specs/integration/))

- Role denial (e.g. Citizen vs `reports.index` or forbidden POST).
- Service-level denial (e.g. Case Manager vs unassigned case), if in matrix.
- New or extended specs for authorization; keep Phase 1 auth tests passing.

## Documentation

- Full matrix + demo notes in [`docs/DEV_NOTES.md`](docs/DEV_NOTES.md).
- Mermaid updates for RBAC if required per [mermaid-design-sync](../rules/mermaid-design-sync.mdc).

## Out of scope (per issue)

Production IdP, per-field ACLs, full user admin UI, formal ATO.
