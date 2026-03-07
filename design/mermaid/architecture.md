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
        Router[Router]
        Handlers[Handlers]
        Views[Views]
        Layouts[Layouts]
    end

    subgraph Data["Data & ORM"]
        cborm[cborm Module]
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
    ColdBox --> Router
    Router --> Handlers
    Handlers --> Views
    Views --> Layouts
    Layouts --> Browser
    Handlers --> cborm
    cborm --> ORM
    ORM --> PG
```

## Layer summary

| Layer    | Components |
|----------|------------|
| Client   | Browser |
| Runtime  | CommandBox, Runwar, CFConfig, Adobe CF 2025 |
| App      | Application.cfc, ColdBox, Router, Handlers, Views, Layouts |
| Data     | cborm, CF ORM, PostgreSQL |
| Config   | server.json, .cfconfig.json |
