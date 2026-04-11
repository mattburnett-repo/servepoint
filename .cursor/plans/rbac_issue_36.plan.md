---
name: ServePoint RBAC Issue 36 (index)
overview: "Issue #36 is implemented in two separate plan files — Phase 1 (authentication) first, then Phase 2 (authorization). Use the phase-specific file for Cursor Build to avoid pulling both milestones into one run."
todos: []
isProject: false
---

# ServePoint RBAC — Issue #36 (plan index)

GitHub: [Feature — Role-based access controls #36](https://github.com/mattburnett-repo/servepoint/issues/36)

- **[`rbac_issue_36_phase1.plan.md`](rbac_issue_36_phase1.plan.md)** — **Milestone A (authentication).** Build this first: session, login/logout, interceptor allowlist, return URL, Phase 1 tests, minimal docs.
- **[`rbac_issue_36_phase2.plan.md`](rbac_issue_36_phase2.plan.md)** — **Milestone B (authorization / RBAC).** After Phase 1 is accepted: matrix, role gates, services, replace hard-coded admin, UI, Phase 2 tests.

**Cursor Build:** Attach or open **only** [`rbac_issue_36_phase1.plan.md`](rbac_issue_36_phase1.plan.md) for the first pass; use [`rbac_issue_36_phase2.plan.md`](rbac_issue_36_phase2.plan.md) for the second pass.
