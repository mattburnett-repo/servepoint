# Config and Datasource Flow

How server and application configuration and the PostgreSQL datasource are loaded.

```mermaid
flowchart TB
    subgraph ServerStart["Server start (CommandBox)"]
        A[box server start]
        B[CommandBox reads server.json]
        C[CFConfig runs]
        D[CFConfig reads cfconfig.file]
    end

    subgraph ConfigFiles["Config files"]
        serverJson[server.json]
        cfconfigJson[.cfconfig.json]
    end

    subgraph CFConfigApply["CFConfig applies to Adobe CF"]
        E[Write datasources to CF server config]
        F[servepoint: dbdriver, host, port, database, username, password]
    end

    subgraph AppLoad["First request / Application load"]
        G[Application.cfc]
        H[this.datasource = servepoint]
        I[this.ormEnabled = true]
        J[ORM looks up servepoint]
        K[config/Coldbox.cfc]
        L[moduleSettings.cborm.datasource = servepoint]
    end

    A --> B
    B --> C
    C --> D
    serverJson --> D
    D --> cfconfigJson
    cfconfigJson --> E
    E --> F
    G --> H
    G --> I
    J --> F
    K --> L
    L --> J
```

## Who reads what

| Consumer   | File / source        | Purpose |
|-----------|----------------------|--------|
| CommandBox | server.json         | Server name, engine (adobe@2025), JVM, web, **cfconfig.file**, scripts |
| CFConfig  | server.json → cfconfig.file | Path to config JSON (e.g. .cfconfig.json) |
| CFConfig  | .cfconfig.json      | Datasource `servepoint`, caches, other CF settings; applied to Adobe CF at startup |
| Adobe CF  | (in-memory after CFConfig) | Registered datasources (e.g. servepoint) |
| Application.cfc | (code)         | this.datasource = "servepoint", this.ormEnabled, this.ormSettings |
| Coldbox.cfc | (code)            | moduleSettings.cborm.datasource = "servepoint", orm options |

## Future: env/secrets

Values in `.cfconfig.json` can be replaced with placeholders (e.g. `${DB_HOST:localhost}`, `${DB_PASSWORD}`) and provided via `.env.dev` or container environment so no secrets are stored in the repo.
