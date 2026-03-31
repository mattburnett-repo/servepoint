# ServePoint Request Lifecycle

Flow of an HTTP request from the browser through ColdBox and back.

```mermaid
sequenceDiagram
    participant Browser
    participant Runwar
    participant AppCfc as Application.cfc
    participant ColdBox
    participant Router
    participant Handler
    participant Service as CaseService and DocumentService
    participant View
    participant Layout

    Browser->>Runwar: HTTP Request
    Runwar->>AppCfc: onRequestStart(targetPage)
    AppCfc->>ColdBox: cbBootstrap.onRequestStart()
    ColdBox->>Router: Route request
    Router->>Handler: Dispatch (e.g. cases.view or documents.upload)
    Handler->>Handler: Set prc, call services / ORM
    Handler->>Service: e.g. listActive(), createCase(), uploadFromForm(), listForCase()
    Service-->>Handler: entities / result struct
    Handler->>View: event.setView("cases/index", "cases/view", or "documents/index")
    View->>Layout: Render view in layout
    Layout->>Browser: HTML Response
```

Note: handlers that do not use a service (for example `Main.index`) skip the service participant.

## Application startup (once)

`onApplicationStart` runs migrations before ORM init and optional seeding.

```mermaid
flowchart LR
    A[onApplicationStart] --> B[loadColdbox]
    B --> C[runMigrations via cfmigrations]
    C --> D[ormGetSessionFactory fail fast]
    D --> E{SERVEPOINT_AUTO_SEED?}
    E -->|yes| F[SeedService.runAll]
    E -->|no| G[App ready]
    F --> G
```

## Key files

- **Application.cfc**: `onRequestStart` delegates to ColdBox; `onApplicationStart` loads ColdBox, runs DB migrations, initializes ORM, optionally runs `SeedService`.
- **config/Router.cfc**: `/healthcheck`, `/api/echo`, convention route `:handler/:action?`.
- **handlers/Main.cfc**: Home, under construction, sample `data` JSON.
- **handlers/Cases.cfc**: Case list, detail/edit, create, archive.
- **handlers/Documents.cfc**: Document upload and download actions, scoped to active cases.
- **views/documents/index.cfm**: Standalone document workspace (select case, upload, list, download).
- **services/CaseService.cfc**: Active-case queries, create/update/archive.
- **services/DocumentService.cfc**: Upload validation/storage, document listing by case, download resolution.
- **views/cases/\*.cfm**, **views/main/\*.cfm**, **layouts/Main.cfm**: View and layout rendering.
