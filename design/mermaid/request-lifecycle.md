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
    participant View
    participant Layout

    Browser->>Runwar: HTTP Request
    Runwar->>AppCfc: onRequestStart(targetPage)
    AppCfc->>ColdBox: cbBootstrap.onRequestStart()
    ColdBox->>Router: Route request
    Router->>Handler: Dispatch (e.g. main.index)
    Handler->>Handler: Set prc, business logic
    Handler->>View: event.setView("main/index")
    View->>Layout: Render view in layout
    Layout->>Browser: HTML Response
```

## Application startup (once)

```mermaid
flowchart LR
    A[First request] --> B[Application.cfc loaded]
    B --> C[ORM init / beforeApplicationStart]
    C --> D[onApplicationStart]
    D --> E[ColdBox Bootstrap]
    E --> F[loadColdbox]
    F --> G[ormGetSessionFactory - fail fast]
    G --> H[App ready]
```

## Key files

- **Application.cfc**: `onRequestStart` delegates to ColdBox; `onApplicationStart` boots ColdBox and forces ORM init.
- **config/Router.cfc**: Routes (e.g. `/healthcheck`, `/api/echo`, `:handler/:action?`).
- **handlers/Main.cfc**: Default handler (index, underConstruction, data, etc.).
- **views/main/*.cfm**, **layouts/Main.cfm**: View and layout rendering.
