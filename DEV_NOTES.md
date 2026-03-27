# Development Notes

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

### Database seeding (`SERVEPOINT_AUTO_SEED`)

- On application startup, the ORM can automatically seed the database with an administrator user and sample demo data.
- This is controlled by the `SERVEPOINT_AUTO_SEED` environment variable:
  - If **unset or blank**, seeding **runs by default**.
  - If set to `1`, `true`, `yes`, or `on` (case-insensitive), seeding runs.
  - Any other value disables automatic seeding.
- For Docker workflows, add `SERVEPOINT_AUTO_SEED` to your `.env.dev` file so it is injected into the container.
- For local CommandBox workflows, set `SERVEPOINT_AUTO_SEED` in your shell environment before running `box server start`.

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
- **Archive and restore**: Use `CaseService.archiveCase( caseId, userId, reason )` and `CaseService.restoreCase( caseId, userId )`. These optionally create a `LogEntry` for audit. Documents and log entries have no separate archive state; visibility follows the case’s archive flag.
- A future **hard** archive (separate archive tables or export to storage) is out of scope for this phase.

## Known issues

- **"graphqlclient not found" with CF 2025**:
  - When starting the app with ColdFusion 2025, the first request (when the app first loads) can trigger a `ModuleNotAvailableException: The graphqlclient package is not installed` error.
  - **Cause**: CF 2025's `ApplicationSettings.loadAppDatasources()` calls `ServiceFactory.getGraphQLClientService()` when resolving application scope; if the optional graphqlclient package is not installed, it throws.
  - This app does not use GraphQL; it appears that the error originates within ColdFusion 2025 itself.
  - **Workaround**: In `Application.cfc` `onError()`, we detect this exception and issue a 302 redirect to the same URL. The second request succeeds because the application scope is already resolved. See [GitHub issue #10](https://github.com/mattburnett-repo/servepoint/issues/10).
