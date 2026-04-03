# Development Notes

Agent rules for Cursor (committed with the repo): [.cursor/rules/](.cursor/rules/).

## Development workflow (important)

For day‑to‑day development, **run the app inside Docker**, not via `box server start` on your host machine.

- **Preferred**: from the project root (`ServePoint` directory), start the full stack with:

  ```bash
  docker compose --env-file .env.dev -f docker/docker-compose.yml down
  rm -rf .db/postgres/data
  docker compose --env-file .env.dev -f docker/docker-compose.yml up --build
  ```

  This starts a fresh build of the app image, starts the app and Postgres containers, and wires all environment variables from `.env.dev`. The app is then started.

- **Not preferred**: running `box server start` directly on your host. That path is only for troubleshooting; it does not match the containerized production‑like environment, and may behave differently (Java, paths, CF packages, etc.).

### Local vs remote database

- **Docker Compose** (`docker/docker-compose.yml`) starts the app **and** a local PostgreSQL container. Use it with `.env.dev` when you want a **local, dev-only database** so migrations, seeds, and experiments don’t touch the remote Render database. This is the recommended setup for day‑to‑day development. The compose file maps the app to **host port 8081** (→ container 8080) so it does not conflict with other tools on your machine that use **8080** (for example nginx). Access the app at **`http://localhost:8081`** for local Compose.
- **Remote database (e.g. Render)**: For deployment or for testing against the live DB, run only the app container (e.g. `docker build -t servepoint -f docker/Dockerfile .` then `docker run --env-file .env.deploy -p 8080:8080 servepoint`). Render builds from the Dockerfile only and does not use docker-compose. You do **not** need docker-compose for Render deployment; you **do** need it (or another local Postgres) if you want an isolated local database for development.

## Config and secrets

This app uses:

- **commandbox-dotenv** (preinstalled in the Docker image) to load environment variables.
- A familiar **`.env.dev` file in the project root** for secrets and configuration (database credentials, etc.).

When you run the app via Docker (`docker compose --env-file .env.dev -f docker/docker-compose.yml up`), those `.env.dev` values are injected into the containers and used by CF/ColdBox; you should not commit `.env.dev` to version control.

### Document upload storage settings

Document uploads are configured in `config/Coldbox.cfc` under `moduleSettings.servepoint.documentUploads`, with environment variable overrides:

- `SERVEPOINT_DOCUMENT_STORAGE_ROOT`: persisted file storage root. For Docker, set this to `/app/uploads/documents` and bind mount host `./uploads/documents` to container `/app/uploads/documents` so files never stay container-only.
- `SERVEPOINT_DOCUMENT_TEMP_ROOT`: temp upload root used before validation/persist (default: `../tmp/uploads/documents` from `config/`).
- `SERVEPOINT_DOCUMENT_MAX_BYTES`: max upload size in bytes (default: `10485760`, i.e. 10 MB).
- `SERVEPOINT_STORAGE_PERSISTENT`: UI/documentation flag for storage mode messaging. Set `true` for local persistent mode; set `false` for ephemeral demo mode (for example on Render without a persistent disk).

The `DocumentService` persists files with unique UUID-based disk names and stores those names in `documents.fileName`. `documents.fileType` and `Document_File_Type` constants are used to enforce allowed extensions (`pdf`, `docx`, `png`, `jpeg`, `jpg`).
Upload flow is intentionally two-stage: files land in `SERVEPOINT_DOCUMENT_TEMP_ROOT` first, then are validated (active case, allowed type, max size) and moved into `SERVEPOINT_DOCUMENT_STORAGE_ROOT`. Invalid uploads are deleted from temp and never persisted to the final storage root.

### Document retention (policy / product design)

- **Accepted documents** (rows in `documents` plus files under `SERVEPOINT_DOCUMENT_STORAGE_ROOT`) are **retained** as part of the case record. There is **no in-app delete** from the documents workspace (upload / list / download only).
- **Removing** a document from normal use—DB row, file on disk, or both—is **not** implemented in routine UI flows; it belongs to **records disposition** handled **outside** upload/view (e.g. compliance-approved process, DBA/storage ops, future admin tooling), consistent with `DESIGN_NOTES.md` (Document retention).
- **Case archive** soft-hides the case (and thus document access through normal active-case flows) but **does not** delete document rows or files; see “Archive / restore” below.

#### Storage modes

- **Persistent mode (local dev default)**: `SERVEPOINT_DOCUMENT_STORAGE_ROOT=/app/uploads/documents` and `SERVEPOINT_STORAGE_PERSISTENT=true` with Docker bind mount `./uploads/documents -> /app/uploads/documents`.
- **Ephemeral demo mode (Render without disk)**: `SERVEPOINT_DOCUMENT_STORAGE_ROOT=/tmp/servepoint/uploads/documents` and `SERVEPOINT_STORAGE_PERSISTENT=false`. Files work during runtime but may be lost on restart/redeploy.

### Database seeding (`SERVEPOINT_AUTO_SEED`)

- On application startup, the ORM can automatically seed the database with an administrator user and sample demo data.
- This is controlled by the `SERVEPOINT_AUTO_SEED` environment variable:
  - If **unset or blank**, seeding **runs by default**.
  - If set to `1`, `true`, `yes`, or `on` (case-insensitive), seeding runs.
  - Any other value disables automatic seeding.
- For Docker workflows, add `SERVEPOINT_AUTO_SEED` to your `.env.dev` file so it is injected into the container.
- For local CommandBox workflows, set `SERVEPOINT_AUTO_SEED` in your shell environment before running `box server start`.

## Linting and formatting

The app runs in **Docker**; **linting and formatting** run on your **dev machine** (editor + CLI), not inside the container.

| Concern | Tool | Where it lives |
|--------|------|----------------|
| **Format** `.cfc` / `.cfm` | **cfformat** (CommandBox module) | Install: `box install commandbox-cfformat` from the repo root. Run: `box cfformat run path/or/glob.cfc --overwrite`. Optional project-wide rules: `.cfformat.json` at the repo root (add when the team wants shared formatting defaults). |
| **Lint** CFML | **CFLint** via the **CFLint** VS Code / Cursor extension | Needs a **JDK** and the JAR path in [`.vscode/settings.json`](.vscode/settings.json) (`cflint.jarPath`). Fetch the JAR with [`tools/cflint/download.sh`](tools/cflint/download.sh) (output is gitignored) or point `cflint.jarPath` at any `CFLint-*-all.jar` on disk. Rules: [`.cflintrc`](.cflintrc). Rule catalog: [CFLint `RULES.md`](https://github.com/cflint/CFLint/blob/master/RULES.md). |
| **Format** Markdown, JSON, YAML, etc. | **Prettier** | [`.prettierrc`](.prettierrc), [`.prettierignore`](.prettierignore). **Prettier does not support CFML** — `*.cfc` / `*.cfm` are ignored so the default formatter does not corrupt them. |

**CFLint config notes:** Empty `includes` in `.cflintrc` means all built-in rules apply (see [CFLint README](https://github.com/cflint/CFLint/blob/master/README.md)). Excludes and `parameters` in `.cflintrc` tune noisy rules and length limits for this stack; see `RULES.md` for codes and checker options.

## ORM model expectations (source of truth)

- All persistent entities (`Users`, `Cases`, `Document`, `LogEntry`) extend `cborm.models.ActiveEntity` and are mapped according to `design/mermaid/data-model.md`.
- Required vs optional fields, uniqueness rules (e.g., `Users.email` unique), and high-level index expectations are documented in `design/mermaid/data-model.md` and should be treated as the contract for migrations and DB schema.

## Database & migrations

- The database schema is managed **only by cfmigrations**. ORM is used to **validate** that the existing schema matches the entity mappings; it does not create or alter tables. All schema changes (new columns, tables, indexes, etc.) go in new migration files under `resources/database/migrations/`.
- **ORM_DBCREATE**: The value is read from the `ORM_DBCREATE` environment variable (in both `Application.cfc` and `config/Coldbox.cfc`). Allowed values: `validate`, `update`, `dropcreate`, `none`. Default is `validate`. Use `validate` for production and for Render so ORM only checks the schema; use migrations for any schema changes.
- **Startup order** (`Application.cfc` `onApplicationStart`):
  1. ColdBox is bootstrapped.
  2. `runMigrations()` runs: `migrationService.install()` (ensures the `cfmigrations` tracking table exists), then `migrationService.up()` (runs any pending migrations).
  3. ORM is initialized (`ormGetSessionFactory()`), so the schema is in place before validation.
  4. Optional seeding via `SeedService` when `SERVEPOINT_AUTO_SEED` indicates seeding should run.
- **cfmigrations**:
  - Migrations live under `resources/database/migrations/` as timestamped CFCs with `up()`/`down()` methods.
  - The default manager is configured in `config/Coldbox.cfc` to target the `servepoint` datasource with a Postgres grammar.
- **Developer workflow**:
  - For local work, ensure CommandBox dependencies are installed (`box install`), then start the stack via Docker as usual; migrations will run automatically on first request/startup.
  - Any schema-changing feature (new columns, indexes, archive flags, etc.) must add a new migration in `resources/database/migrations/` rather than relying on `dbcreate`.
- **Render database reset**: To wipe the Render Postgres database and run the single bootstrap migration from a clean state, follow the steps in [RENDER_DATABASE.md](RENDER_DATABASE.md).

### Archive / restore (data retention)

- **Soft archive only**: Cases can be archived at the business level. Data stays in the main tables; the case’s `archived_at` (and optional `archived_by`, `archive_reason`) mark it as archived.
- **Default query behavior**: Case lists used by the app return **only active cases** by default (`archived_at IS NULL`). Use `CaseService.listActive()` for the default list and `CaseService.listAll( includeArchived = true )` when archived cases should be included (e.g. admin or reporting).
- **Archive and restore**: Use `CaseService.archiveCase( caseId, userId, reason )` and `CaseService.restoreCase( caseId, userId )`. These optionally create a `LogEntry` for audit. Documents and log entries have no separate archive state; visibility follows the case’s archive flag. Archiving is **not** document deletion; stored files and `documents` rows remain until an explicit out-of-band disposition process removes them (see **Document retention** above).
- A future **hard** archive (separate archive tables or export to storage) is out of scope for this phase.

## Known issues

- **"graphqlclient not found" with CF 2025**:
  - When starting the app with ColdFusion 2025, the first request (when the app first loads) can trigger a `ModuleNotAvailableException: The graphqlclient package is not installed` error.
  - **Cause**: CF 2025's `ApplicationSettings.loadAppDatasources()` calls `ServiceFactory.getGraphQLClientService()` when resolving application scope; if the optional graphqlclient package is not installed, it throws.
  - This app does not use GraphQL; it appears that the error originates within ColdFusion 2025 itself.
  - **Workaround**: In `Application.cfc` `onError()`, we detect this exception and issue a 302 redirect to the same URL. The second request succeeds because the application scope is already resolved. See [GitHub issue #10](https://github.com/mattburnett-repo/servepoint/issues/10).
