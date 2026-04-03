# ServePoint Architecture

High-level stack and component flow for the ServePoint ColdBox application.

```mermaid
flowchart TB
    subgraph Client["Client"]
        Browser[User Browser]
    end

    subgraph Runtime["Runtime (CommandBox)"]
        Runwar[Runwar / Undertow]
        CFConfig[CFConfig]
        ACF[Adobe ColdFusion 2025]
    end

    subgraph App["Application"]
        AppCfc[Application.cfc]
        ColdBox[ColdBox Framework]
        WireBox[WireBox DI]
        Router[Router]
        Handlers[Handlers]
        Services[Services]
        Views[Views]
        Layouts[Layouts]
    end

    subgraph Data["Data & ORM"]
        cborm[cborm Module]
        cfmigrations[cfmigrations Module]
        ORM[CF ORM / Hibernate]
        PG[(PostgreSQL)]
    end

    subgraph Config["Config Files"]
        serverJson[server.json]
        cfconfigJson[.cfconfig.json]
    end

    Browser --> Runwar
    Runwar --> ACF
    serverJson --> CFConfig
    CFConfig --> cfconfigJson
    CFConfig --> ACF
    ACF --> AppCfc
    AppCfc --> ColdBox
    ColdBox --> WireBox
    ColdBox --> Router
    Router --> Handlers
    Handlers --> Services
    Handlers --> Views
    Views --> Layouts
    Layouts --> Browser
    Services --> cborm
    Handlers --> cborm
    cborm --> ORM
    ORM --> PG
    AppCfc -.->|"onApplicationStart: migrations"| cfmigrations
    cfmigrations --> PG
```

## Layer summary

| Layer    | Components |
|----------|------------|
| Client   | Browser |
| Runtime  | CommandBox, Runwar, CFConfig, Adobe CF 2025 |
| App      | Application.cfc, ColdBox, WireBox, Router, Handlers, Services (e.g. CaseService, SeedService), Views, Layouts |
| Data     | cborm, cfmigrations (startup migrations), CF ORM, PostgreSQL |
| Config   | server.json, .cfconfig.json |

## Handlers and services (current)

| Handler | Injected / used services | Primary views |
|---------|---------------------------|----------------|
| `Main` | — | `main/index`, `main/underConstruction` |
| `Cases` | `CaseService` | `cases/index`, `cases/view`, `cases/new` |
| `Documents` | `DocumentService`, `CaseService` | `documents/index`; upload/download actions (no in-app document delete—retention policy; see `DESIGN_NOTES.md`) |

`SeedService` runs during `onApplicationStart` when `SERVEPOINT_AUTO_SEED` allows it (see Application.cfc).

**Documents:** Upload, list, and download are in scope for the case workspace; **deletion** of accepted documents is **out of band** (policy / separate process), not a handler action in the MVP.
