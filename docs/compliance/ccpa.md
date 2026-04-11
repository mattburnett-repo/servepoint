# CCPA / CPRA (high-level; not legal advice)

The **California Consumer Privacy Act** (CCPA), as amended by the **CPRA**, grants California consumers **rights** regarding personal information and imposes obligations on **qualifying businesses** (thresholds and definitions are in statute and regulations). Whether your organization or deployment qualifies is **not** determined here.

## Consumer rights (in principle)

Typical themes include:

- **Right to know** what personal information is collected and how it is used.
- **Right to delete** personal information, subject to exceptions.
- **Right to correct** inaccurate personal information (CPRA).
- **Right to opt out** of **sale** or **sharing** for cross-context behavioral advertising (where applicable).

Many internal or government case-management deployments **do not “sell”** personal information in the statutory sense; that is **fact-specific**. If sale does not occur, opt-out of sale may be **not applicable**—still document your analysis.

## Honoring requests in a real deployment

This demo **does not** automate intake or fulfillment of privacy requests. A production process might include:

1. **Intake** channel (web form, email, phone) with verification.
2. **Ticket** and **identity verification** appropriate to sensitivity.
3. **Data discovery** across application DB, files, backups, and logs.
4. **Response** within statutory timelines, with documented exceptions (for example where retention is required by law).

## What this repo does **not** provide

- A **Notice at Collection** or **privacy policy** text for your organization (legal/comms owns that).
- Automated **“Do Not Sell”** flows unless you build them for your product surface.
- Jurisdiction-specific contract templates.

See [README.md](README.md) and [data-inventory.md](data-inventory.md).
